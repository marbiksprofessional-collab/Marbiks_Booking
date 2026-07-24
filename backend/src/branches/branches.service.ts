import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Branch } from './branch.entity';
import { CreateBranchDto } from './dto/create-branch.dto';

@Injectable()
export class BranchesService {
  constructor(
    @InjectRepository(Branch)
    private readonly branchesRepository: Repository<Branch>,
  ) {}

  create(dto: CreateBranchDto): Promise<Branch> {
    const branch = this.branchesRepository.create(dto);
    return this.branchesRepository.save(branch);
  }

  findAll(): Promise<Branch[]> {
    return this.branchesRepository.find({ order: { name: 'ASC' } });
  }

  async findById(id: string): Promise<Branch> {
    const branch = await this.branchesRepository.findOne({ where: { id } });
    if (!branch) {
      throw new NotFoundException(`Branch ${id} not found`);
    }
    return branch;
  }
}
