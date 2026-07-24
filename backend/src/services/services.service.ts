import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ServiceItem } from './service-item.entity';
import { CreateServiceItemDto } from './dto/create-service-item.dto';

@Injectable()
export class ServicesService {
  constructor(
    @InjectRepository(ServiceItem)
    private readonly servicesRepository: Repository<ServiceItem>,
  ) {}

  create(dto: CreateServiceItemDto): Promise<ServiceItem> {
    const service = this.servicesRepository.create(dto);
    return this.servicesRepository.save(service);
  }

  findAll(): Promise<ServiceItem[]> {
    return this.servicesRepository.find({ where: { isActive: true }, order: { name: 'ASC' } });
  }

  async findById(id: string): Promise<ServiceItem> {
    const service = await this.servicesRepository.findOne({ where: { id } });
    if (!service) {
      throw new NotFoundException(`Service ${id} not found`);
    }
    return service;
  }
}
