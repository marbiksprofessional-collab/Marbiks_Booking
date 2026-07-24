import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Product } from '../products/product.entity';
import { Branch } from '../branches/branch.entity';
import { StockBatch } from './stock-batch.entity';

export enum StockMovementType {
  RECEIVE = 'RECEIVE',
  CONSUME = 'CONSUME',
  TRANSFER_OUT = 'TRANSFER_OUT',
  TRANSFER_IN = 'TRANSFER_IN',
  ADJUSTMENT = 'ADJUSTMENT',
}

@Entity('stock_movements')
export class StockMovement {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Product, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'productId' })
  product: Product;

  @Column()
  productId: string;

  @ManyToOne(() => Branch, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'branchId' })
  branch: Branch;

  @Column()
  branchId: string;

  @ManyToOne(() => StockBatch, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'batchId' })
  batch: StockBatch | null;

  @Column({ nullable: true })
  batchId: string | null;

  @Column({ type: 'enum', enum: StockMovementType })
  type: StockMovementType;

  /** Always positive; direction is implied by `type`. */
  @Column({ type: 'int' })
  quantity: number;

  @Column({ type: 'varchar', nullable: true })
  note: string | null;

  @Column({ type: 'uuid', nullable: true })
  performedByUserId: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
