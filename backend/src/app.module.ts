import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { BranchesModule } from './branches/branches.module';
import { CustomersModule } from './customers/customers.module';
import { ServicesModule } from './services/services.module';
import { AppointmentsModule } from './appointments/appointments.module';
import { BillingModule } from './billing/billing.module';
import { AttendanceModule } from './attendance/attendance.module';
import { CommissionsModule } from './commissions/commissions.module';
import { ProductsModule } from './products/products.module';
import { VendorsModule } from './vendors/vendors.module';
import { InventoryModule } from './inventory/inventory.module';
import { PurchaseOrdersModule } from './purchase-orders/purchase-orders.module';
import { CustomerAuthModule } from './customer-auth/customer-auth.module';
import { ReviewsModule } from './reviews/reviews.module';
import { CustomerPortalModule } from './customer-portal/customer-portal.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get<string>('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get<string>('DB_USERNAME', 'marbiks'),
        password: config.get<string>('DB_PASSWORD', 'marbiks'),
        database: config.get<string>('DB_DATABASE', 'marbiks_erp'),
        autoLoadEntities: true,
        synchronize: false,
      }),
    }),
    AuthModule,
    UsersModule,
    BranchesModule,
    CustomersModule,
    ServicesModule,
    AppointmentsModule,
    BillingModule,
    AttendanceModule,
    CommissionsModule,
    ProductsModule,
    VendorsModule,
    InventoryModule,
    PurchaseOrdersModule,
    CustomerAuthModule,
    ReviewsModule,
    CustomerPortalModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
