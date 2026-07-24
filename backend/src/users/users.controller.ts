import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '../common/enums/role.enum';

@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @Roles(Role.SUPER_ADMIN, Role.HR_MANAGER, Role.BRANCH_MANAGER)
  create(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto);
  }

  @Get()
  @Roles(Role.SUPER_ADMIN, Role.HR_MANAGER, Role.BRANCH_MANAGER, Role.GENERAL_MANAGER)
  findAll(@Query('branchId') branchId?: string) {
    return this.usersService.findAll(branchId);
  }

  @Get(':id')
  @Roles(Role.SUPER_ADMIN, Role.HR_MANAGER, Role.BRANCH_MANAGER, Role.GENERAL_MANAGER)
  findOne(@Param('id') id: string) {
    return this.usersService.findById(id);
  }
}
