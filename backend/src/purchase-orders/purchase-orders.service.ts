import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PurchaseOrder, PurchaseOrderStatus } from './purchase-order.entity';
import { PurchaseOrderItem } from './purchase-order-item.entity';
import { CreatePurchaseOrderDto } from './dto/create-purchase-order.dto';
import { ReceivePurchaseOrderDto } from './dto/receive-purchase-order.dto';
import { InventoryService } from '../inventory/inventory.service';

@Injectable()
export class PurchaseOrdersService {
  constructor(
    @InjectRepository(PurchaseOrder)
    private readonly purchaseOrdersRepository: Repository<PurchaseOrder>,
    private readonly inventoryService: InventoryService,
  ) {}

  async create(dto: CreatePurchaseOrderDto): Promise<PurchaseOrder> {
    const items = dto.items.map((item) => {
      const poItem = new PurchaseOrderItem();
      poItem.productId = item.productId;
      poItem.quantityOrdered = item.quantity;
      poItem.unitCost = item.unitCost;
      return poItem;
    });

    const purchaseOrder = this.purchaseOrdersRepository.create({
      branchId: dto.branchId,
      vendorId: dto.vendorId,
      items,
      status: PurchaseOrderStatus.ORDERED,
    });

    return this.purchaseOrdersRepository.save(purchaseOrder);
  }

  async findAll(branchId?: string): Promise<PurchaseOrder[]> {
    return this.purchaseOrdersRepository.find({
      where: branchId ? { branchId } : {},
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string): Promise<PurchaseOrder> {
    const purchaseOrder = await this.purchaseOrdersRepository.findOne({ where: { id } });
    if (!purchaseOrder) {
      throw new NotFoundException(`Purchase order ${id} not found`);
    }
    return purchaseOrder;
  }

  async receive(
    id: string,
    dto: ReceivePurchaseOrderDto,
    performedByUserId: string,
  ): Promise<PurchaseOrder> {
    const purchaseOrder = await this.findById(id);
    if (purchaseOrder.status !== PurchaseOrderStatus.ORDERED) {
      throw new BadRequestException(
        `Only an ordered purchase order can be received (current status: ${purchaseOrder.status})`,
      );
    }

    const overridesByProduct = new Map(
      (dto.items ?? []).map((override) => [override.productId, override]),
    );

    for (const item of purchaseOrder.items) {
      const override = overridesByProduct.get(item.productId);
      await this.inventoryService.receiveStock(
        {
          branchId: purchaseOrder.branchId,
          productId: item.productId,
          quantity: item.quantityOrdered,
          unitCost: item.unitCost,
          vendorId: purchaseOrder.vendorId,
          batchNumber: override?.batchNumber,
          expiryDate: override?.expiryDate,
        },
        performedByUserId,
      );
      item.quantityReceived = item.quantityOrdered;
    }

    purchaseOrder.status = PurchaseOrderStatus.RECEIVED;
    purchaseOrder.receivedAt = new Date();

    return this.purchaseOrdersRepository.save(purchaseOrder);
  }

  async cancel(id: string): Promise<PurchaseOrder> {
    const purchaseOrder = await this.findById(id);
    if (purchaseOrder.status !== PurchaseOrderStatus.ORDERED) {
      throw new BadRequestException(
        `Only an ordered purchase order can be cancelled (current status: ${purchaseOrder.status})`,
      );
    }
    purchaseOrder.status = PurchaseOrderStatus.CANCELLED;
    return this.purchaseOrdersRepository.save(purchaseOrder);
  }
}
