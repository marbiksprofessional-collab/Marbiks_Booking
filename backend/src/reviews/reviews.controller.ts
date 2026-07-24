import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '../common/enums/role.enum';
import { CurrentUser } from '../common/decorators/current-user.decorator';

interface RequestUser {
  id: string;
}

@Controller('reviews')
@UseGuards(JwtAuthGuard)
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles(Role.CUSTOMER)
  create(@Body() dto: CreateReviewDto, @CurrentUser() user: RequestUser) {
    return this.reviewsService.create(dto, user.id);
  }

  @Get()
  findMany(@Query('branchId') branchId?: string, @Query('technicianId') technicianId?: string) {
    if (technicianId) {
      return this.reviewsService.findForTechnician(technicianId);
    }
    return this.reviewsService.findForBranch(branchId ?? '');
  }
}
