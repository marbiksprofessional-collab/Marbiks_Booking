import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Product } from '../products/product.entity';
import { Branch } from '../branches/branch.entity';
import { Vendor } from '../vendors/vendor.entity';

@Entity('stock_batches')
@Index(['branchId', 'productId'])
export class StockBatch {
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

  @ManyToOne(() => Vendor, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'vendorId' })
  vendor: Vendor | null;

  @Column({ nullable: true })
  vendorId: string | null;

  @Column({ type: 'varchar', nullable: true })
  batchNumber: string | null;

  @Column({ type: 'timestamptz', nullable: true })
  expiryDate: Date | null;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  unitCost: string | null;

  @Column({ type: 'int' })
  quantityReceived: number;

  @Column({ type: 'int' })
  quantityRemaining: number;

  @CreateDateColumn()
  receivedAt: Date;
}
