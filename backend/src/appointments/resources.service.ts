import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Resource } from './resource.entity';
import { CreateResourceDto } from './dto/create-resource.dto';

@Injectable()
export class ResourcesService {
  constructor(
    @InjectRepository(Resource)
    private readonly resourcesRepository: Repository<Resource>,
  ) {}

  create(dto: CreateResourceDto): Promise<Resource> {
    const resource = this.resourcesRepository.create(dto);
    return this.resourcesRepository.save(resource);
  }

  findAllForBranch(branchId: string): Promise<Resource[]> {
    return this.resourcesRepository.find({
      where: { branchId, isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findById(id: string): Promise<Resource> {
    const resource = await this.resourcesRepository.findOne({ where: { id } });
    if (!resource) {
      throw new NotFoundException(`Resource ${id} not found`);
    }
    return resource;
  }
}
