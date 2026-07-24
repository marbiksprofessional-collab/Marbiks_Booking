import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Branch } from '../branches/branch.entity';
import { Customer } from '../customers/customer.entity';
import { User } from '../users/user.entity';
import { ServiceItem } from '../services/service-item.entity';
import { Resource } from './resource.entity';

export enum AppointmentStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
  NO_SHOW = 'NO_SHOW',
}

@Entity('appointments')
@Index(['technicianId', 'startTime', 'endTime'])
@Index(['resourceId', 'startTime', 'endTime'])
export class Appointment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Branch, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'branchId' })
  branch: Branch;

  @Column()
  branchId: string;

  @ManyToOne(() => Customer, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'customerId' })
  customer: Customer;

  @Column()
  customerId: string;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'technicianId' })
  technician: User | null;

  @Column({ nullable: true })
  technicianId: string | null;

  @ManyToOne(() => Resource, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'resourceId' })
  resource: Resource | null;

  @Column({ nullable: true })
  resourceId: string | null;

  @ManyToOne(() => ServiceItem, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'serviceId' })
  service: ServiceItem;

  @Column()
  serviceId: string;

  @Column({ type: 'timestamptz' })
  startTime: Date;

  @Column({ type: 'timestamptz' })
  endTime: Date;

  @Column({ type: 'enum', enum: AppointmentStatus, default: AppointmentStatus.PENDING })
  status: AppointmentStatus;

  @Column({ nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
