import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Vendor } from './vendor.entity';
import { CreateVendorDto } from './dto/create-vendor.dto';

@Injectable()
export class VendorsService {
  constructor(
    @InjectRepository(Vendor)
    private readonly vendorsRepository: Repository<Vendor>,
  ) {}

  create(dto: CreateVendorDto): Promise<Vendor> {
    const vendor = this.vendorsRepository.create(dto);
    return this.vendorsRepository.save(vendor);
  }

  findAll(): Promise<Vendor[]> {
    return this.vendorsRepository.find({ where: { isActive: true }, order: { name: 'ASC' } });
  }

  async findById(id: string): Promise<Vendor> {
    const vendor = await this.vendorsRepository.findOne({ where: { id } });
    if (!vendor) {
      throw new NotFoundException(`Vendor ${id} not found`);
    }
    return vendor;
  }
}
