import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { StockBatch } from './stock-batch.entity';
import { StockMovement, StockMovementType } from './stock-movement.entity';
import { ReceiveStockDto } from './dto/receive-stock.dto';
import { ConsumeStockDto } from './dto/consume-stock.dto';
import { TransferStockDto } from './dto/transfer-stock.dto';
import { AdjustStockDto } from './dto/adjust-stock.dto';

export interface StockLevel {
  productId: string;
  name: string;
  sku: string;
  unit: string;
  reorderLevel: number;
  quantityOnHand: number;
}

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(StockBatch)
    private readonly stockBatchesRepository: Repository<StockBatch>,
    @InjectDataSource()
    private readonly dataSource: DataSource,
  ) {}

  async receiveStock(dto: ReceiveStockDto, performedByUserId: string): Promise<StockBatch> {
    return this.dataSource.transaction(async (manager) => {
      const batch = manager.create(StockBatch, {
        productId: dto.productId,
        branchId: dto.branchId,
        vendorId: dto.vendorId ?? null,
        batchNumber: dto.batchNumber ?? null,
        expiryDate: dto.expiryDate ? new Date(dto.expiryDate) : null,
        unitCost: dto.unitCost ?? null,
        quantityReceived: dto.quantity,
        quantityRemaining: dto.quantity,
      });
      const savedBatch = await manager.save(batch);

      const movement = manager.create(StockMovement, {
        productId: dto.productId,
        branchId: dto.branchId,
        batchId: savedBatch.id,
        type: StockMovementType.RECEIVE,
        quantity: dto.quantity,
        note: null,
        performedByUserId,
      });
      await manager.save(movement);

      return savedBatch;
    });
  }

  async consumeStock(dto: ConsumeStockDto, performedByUserId: string): Promise<StockMovement[]> {
    return this.dataSource.transaction((manager) =>
      this.consumeFifo(
        manager,
        dto.branchId,
        dto.productId,
        dto.quantity,
        StockMovementType.CONSUME,
        dto.note ?? null,
        performedByUserId,
      ),
    );
  }

  async transferStock(dto: TransferStockDto, performedByUserId: string): Promise<void> {
    await this.dataSource.transaction(async (manager) => {
      await this.consumeFifo(
        manager,
        dto.fromBranchId,
        dto.productId,
        dto.quantity,
        StockMovementType.TRANSFER_OUT,
        `Transfer to branch ${dto.toBranchId}`,
        performedByUserId,
      );

      const batch = manager.create(StockBatch, {
        productId: dto.productId,
        branchId: dto.toBranchId,
        vendorId: null,
        batchNumber: null,
        expiryDate: null,
        unitCost: null,
        quantityReceived: dto.quantity,
        quantityRemaining: dto.quantity,
      });
      const savedBatch = await manager.save(batch);

      const movement = manager.create(StockMovement, {
        productId: dto.productId,
        branchId: dto.toBranchId,
        batchId: savedBatch.id,
        type: StockMovementType.TRANSFER_IN,
        quantity: dto.quantity,
        note: `Transfer from branch ${dto.fromBranchId}`,
        performedByUserId,
      });
      await manager.save(movement);
    });
  }

  async adjustStock(dto: AdjustStockDto, performedByUserId: string): Promise<StockMovement[]> {
    if (dto.quantityDelta > 0) {
      return this.dataSource.transaction(async (manager) => {
        const batch = manager.create(StockBatch, {
          productId: dto.productId,
          branchId: dto.branchId,
          vendorId: null,
          batchNumber: null,
          expiryDate: null,
          unitCost: null,
          quantityReceived: dto.quantityDelta,
          quantityRemaining: dto.quantityDelta,
        });
        const savedBatch = await manager.save(batch);

        const movement = manager.create(StockMovement, {
          productId: dto.productId,
          branchId: dto.branchId,
          batchId: savedBatch.id,
          type: StockMovementType.ADJUSTMENT,
          quantity: dto.quantityDelta,
          note: dto.reason,
          performedByUserId,
        });
        await manager.save(movement);
        return [movement];
      });
    }

    return this.dataSource.transaction((manager) =>
      this.consumeFifo(
        manager,
        dto.branchId,
        dto.productId,
        Math.abs(dto.quantityDelta),
        StockMovementType.ADJUSTMENT,
        dto.reason,
        performedByUserId,
      ),
    );
  }

  private async consumeFifo(
    manager: EntityManager,
    branchId: string,
    productId: string,
    quantity: number,
    type: StockMovementType,
    note: string | null,
    performedByUserId: string,
  ): Promise<StockMovement[]> {
    const batches = await manager
      .createQueryBuilder(StockBatch, 'b')
      .where('b.branchId = :branchId', { branchId })
      .andWhere('b.productId = :productId', { productId })
      .andWhere('b.quantityRemaining > 0')
      .orderBy('b.expiryDate', 'ASC', 'NULLS LAST')
      .addOrderBy('b.receivedAt', 'ASC')
      .setLock('pessimistic_write')
      .getMany();

    const available = batches.reduce((sum, batch) => sum + batch.quantityRemaining, 0);
    if (available < quantity) {
      throw new BadRequestException(
        `Insufficient stock: requested ${quantity}, only ${available} available`,
      );
    }

    let remaining = quantity;
    const movements: StockMovement[] = [];

    for (const batch of batches) {
      if (remaining <= 0) break;
      const take = Math.min(batch.quantityRemaining, remaining);
      batch.quantityRemaining -= take;
      remaining -= take;
      await manager.save(batch);

      movements.push(
        manager.create(StockMovement, {
          productId,
          branchId,
          batchId: batch.id,
          type,
          quantity: take,
          note,
          performedByUserId,
        }),
      );
    }

    return manager.save(movements);
  }

  async getStockForBranch(branchId: string): Promise<StockLevel[]> {
    return this.dataSource.query(
      `SELECT p.id AS "productId", p.name, p.sku, p.unit, p."reorderLevel" AS "reorderLevel",
              COALESCE(SUM(b."quantityRemaining"), 0)::int AS "quantityOnHand"
       FROM products p
       LEFT JOIN stock_batches b
         ON b."productId" = p.id AND b."branchId" = $1 AND b."quantityRemaining" > 0
       WHERE p."isActive" = true
       GROUP BY p.id, p.name, p.sku, p.unit, p."reorderLevel"
       ORDER BY p.name ASC`,
      [branchId],
    );
  }

  async getLowStock(branchId: string): Promise<StockLevel[]> {
    const stock = await this.getStockForBranch(branchId);
    return stock.filter((item) => item.quantityOnHand <= item.reorderLevel);
  }

  async getExpiringBatches(branchId: string, withinDays: number): Promise<StockBatch[]> {
    const cutoff = new Date(Date.now() + withinDays * 24 * 60 * 60 * 1000);
    return this.stockBatchesRepository
      .createQueryBuilder('b')
      .leftJoinAndSelect('b.product', 'product')
      .where('b.branchId = :branchId', { branchId })
      .andWhere('b.quantityRemaining > 0')
      .andWhere('b.expiryDate IS NOT NULL')
      .andWhere('b.expiryDate <= :cutoff', { cutoff })
      .orderBy('b.expiryDate', 'ASC')
      .getMany();
  }
}
