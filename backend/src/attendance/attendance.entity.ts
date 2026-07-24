import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { User } from '../users/user.entity';
import { Branch } from '../branches/branch.entity';

@Entity('attendance_records')
@Index(['userId', 'clockInAt'])
export class AttendanceRecord {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @ManyToOne(() => Branch, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'branchId' })
  branch: Branch;

  @Column()
  branchId: string;

  @Column({ type: 'timestamptz' })
  clockInAt: Date;

  @Column({ type: 'timestamptz', nullable: true })
  clockOutAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;
}
