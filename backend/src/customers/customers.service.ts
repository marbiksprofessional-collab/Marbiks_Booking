import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';
import { Customer } from './customer.entity';
import { CreateCustomerDto } from './dto/create-customer.dto';

@Injectable()
export class CustomersService {
  constructor(
    @InjectRepository(Customer)
    private readonly customersRepository: Repository<Customer>,
  ) {}

  async create(dto: CreateCustomerDto): Promise<Customer> {
    const existing = await this.customersRepository.findOne({ where: { phone: dto.phone } });
    if (existing) {
      throw new ConflictException(`A customer with phone ${dto.phone} already exists`);
    }
    const customer = this.customersRepository.create(dto);
    return this.customersRepository.save(customer);
  }

  findAll(search?: string): Promise<Customer[]> {
    if (search) {
      return this.customersRepository.find({
        where: [{ fullName: ILike(`%${search}%`) }, { phone: ILike(`%${search}%`) }],
        order: { fullName: 'ASC' },
      });
    }
    return this.customersRepository.find({ order: { fullName: 'ASC' } });
  }

  async findById(id: string): Promise<Customer> {
    const customer = await this.customersRepository.findOne({ where: { id } });
    if (!customer) {
      throw new NotFoundException(`Customer ${id} not found`);
    }
    return customer;
  }

  async addLoyaltyPoints(id: string, points: number): Promise<Customer> {
    const customer = await this.findById(id);
    customer.loyaltyPoints += points;
    return this.customersRepository.save(customer);
  }
}
