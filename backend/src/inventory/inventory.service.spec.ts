import { BadRequestException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getDataSourceToken, getRepositoryToken } from '@nestjs/typeorm';
import { InventoryService } from './inventory.service';
import { StockBatch } from './stock-batch.entity';
import { StockMovement, StockMovementType } from './stock-movement.entity';

describe('InventoryService', () => {
  let service: InventoryService;
  let stockBatchesRepositoryMock: any;
  let managerMock: any;
  let dataSourceMock: any;

  beforeEach(async () => {
    stockBatchesRepositoryMock = {
      createQueryBuilder: jest.fn(),
    };

    managerMock = {
      create: jest.fn((_entity, data) => ({ ...data })),
      save: jest.fn((data) => (Array.isArray(data) ? data : Promise.resolve(data))),
      createQueryBuilder: jest.fn(),
    };

    dataSourceMock = {
      transaction: jest.fn((cb) => cb(managerMock)),
      query: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InventoryService,
        { provide: getRepositoryToken(StockBatch), useValue: stockBatchesRepositoryMock },
        { provide: getDataSourceToken(), useValue: dataSourceMock },
      ],
    }).compile();

    service = module.get(InventoryService);
  });

  function mockBatchQuery(batches: Partial<StockBatch>[]) {
    const qb = {
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn().mockReturnThis(),
      orderBy: jest.fn().mockReturnThis(),
      addOrderBy: jest.fn().mockReturnThis(),
      setLock: jest.fn().mockReturnThis(),
      getMany: jest.fn().mockResolvedValue(batches),
    };
    managerMock.createQueryBuilder.mockReturnValue(qb);
    return qb;
  }

  it('consumes from a single batch when it has enough stock', async () => {
    mockBatchQuery([{ id: 'batch-1', quantityRemaining: 10 }]);

    const movements = await service.consumeStock(
      { branchId: 'branch-1', productId: 'product-1', quantity: 4 },
      'user-1',
    );

    expect(movements).toHaveLength(1);
    expect(movements[0].quantity).toBe(4);
    expect(movements[0].type).toBe(StockMovementType.CONSUME);
  });

  it('consumes across multiple batches in FIFO (expiry) order, oldest first', async () => {
    mockBatchQuery([
      { id: 'batch-old', quantityRemaining: 3 },
      { id: 'batch-new', quantityRemaining: 10 },
    ]);

    const movements = await service.consumeStock(
      { branchId: 'branch-1', productId: 'product-1', quantity: 5 },
      'user-1',
    );

    expect(movements).toHaveLength(2);
    expect(movements[0]).toMatchObject({ batchId: 'batch-old', quantity: 3 });
    expect(movements[1]).toMatchObject({ batchId: 'batch-new', quantity: 2 });
  });

  it('rejects consumption when total remaining stock is insufficient', async () => {
    mockBatchQuery([{ id: 'batch-1', quantityRemaining: 2 }]);

    await expect(
      service.consumeStock({ branchId: 'branch-1', productId: 'product-1', quantity: 5 }, 'user-1'),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('flags products at or below their reorder level as low stock', async () => {
    dataSourceMock.query.mockResolvedValue([
      { productId: 'p1', name: 'Shampoo', sku: 'SH-1', unit: 'ml', reorderLevel: 10, quantityOnHand: 5 },
      { productId: 'p2', name: 'Wax', sku: 'WX-1', unit: 'pcs', reorderLevel: 10, quantityOnHand: 50 },
    ]);

    const lowStock = await service.getLowStock('branch-1');

    expect(lowStock).toHaveLength(1);
    expect(lowStock[0].productId).toBe('p1');
  });
});
