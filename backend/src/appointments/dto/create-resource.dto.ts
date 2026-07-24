import { IsEnum, IsString } from 'class-validator';
import { ResourceType } from '../resource.entity';

export class CreateResourceDto {
  @IsString()
  name: string;

  @IsEnum(ResourceType)
  type: ResourceType;

  @IsString()
  branchId: string;
}
