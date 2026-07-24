import { IsEmail, IsOptional, IsString, Length } from 'class-validator';

export class VerifyOtpDto {
  @IsString()
  @Length(6, 20)
  phone: string;

  @IsString()
  @Length(6, 6)
  code: string;

  @IsOptional()
  @IsString()
  fullName?: string;

  @IsOptional()
  @IsEmail()
  email?: string;
}
