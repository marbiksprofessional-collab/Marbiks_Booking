import * as bcrypt from 'bcrypt';
import { AppDataSource } from '../data-source';
import { Branch } from '../../branches/branch.entity';
import { User } from '../../users/user.entity';
import { ServiceItem } from '../../services/service-item.entity';
import { Resource, ResourceType } from '../../appointments/resource.entity';
import { Role } from '../../common/enums/role.enum';
import { Vendor } from '../../vendors/vendor.entity';
import { Product } from '../../products/product.entity';
import { StockBatch } from '../../inventory/stock-batch.entity';
import { StockMovement, StockMovementType } from '../../inventory/stock-movement.entity';

async function seed() {
  await AppDataSource.initialize();

  const branchRepo = AppDataSource.getRepository(Branch);
  const userRepo = AppDataSource.getRepository(User);
  const serviceRepo = AppDataSource.getRepository(ServiceItem);
  const resourceRepo = AppDataSource.getRepository(Resource);
  const vendorRepo = AppDataSource.getRepository(Vendor);
  const productRepo = AppDataSource.getRepository(Product);
  const stockBatchRepo = AppDataSource.getRepository(StockBatch);
  const stockMovementRepo = AppDataSource.getRepository(StockMovement);

  let branch = await branchRepo.findOne({ where: { code: 'HQ' } });
  if (!branch) {
    branch = await branchRepo.save(
      branchRepo.create({
        code: 'HQ',
        name: 'Marbiks Professional - Flagship Branch',
        city: 'Bengaluru',
        state: 'Karnataka',
      }),
    );
    console.log(`Created branch ${branch.name}`);
  }

  const superAdminEmail = 'admin@marbiks.com';
  const existingAdmin = await userRepo.findOne({ where: { email: superAdminEmail } });
  if (!existingAdmin) {
    await userRepo.save(
      userRepo.create({
        fullName: 'Marbiks Super Admin',
        email: superAdminEmail,
        passwordHash: await bcrypt.hash('ChangeMe123!', 10),
        role: Role.SUPER_ADMIN,
        branchId: null,
      }),
    );
    console.log(`Created super admin user (${superAdminEmail} / ChangeMe123!) - change this password immediately`);
  }

  const receptionistEmail = 'reception@marbiks.com';
  const existingReceptionist = await userRepo.findOne({ where: { email: receptionistEmail } });
  if (!existingReceptionist) {
    await userRepo.save(
      userRepo.create({
        fullName: 'Front Desk Receptionist',
        email: receptionistEmail,
        passwordHash: await bcrypt.hash('ChangeMe123!', 10),
        role: Role.RECEPTIONIST,
        branchId: branch.id,
      }),
    );
    console.log(`Created receptionist user (${receptionistEmail} / ChangeMe123!)`);
  }

  const technicianEmail = 'technician@marbiks.com';
  const existingTechnician = await userRepo.findOne({ where: { email: technicianEmail } });
  if (!existingTechnician) {
    await userRepo.save(
      userRepo.create({
        fullName: 'Demo Technician',
        email: technicianEmail,
        passwordHash: await bcrypt.hash('ChangeMe123!', 10),
        role: Role.TECHNICIAN,
        branchId: branch.id,
      }),
    );
    console.log(`Created technician user (${technicianEmail} / ChangeMe123!)`);
  }

  const storeManagerEmail = 'store@marbiks.com';
  const existingStoreManager = await userRepo.findOne({ where: { email: storeManagerEmail } });
  if (!existingStoreManager) {
    await userRepo.save(
      userRepo.create({
        fullName: 'Demo Store Manager',
        email: storeManagerEmail,
        passwordHash: await bcrypt.hash('ChangeMe123!', 10),
        role: Role.STORE_MANAGER,
        branchId: branch.id,
      }),
    );
    console.log(`Created store manager user (${storeManagerEmail} / ChangeMe123!)`);
  }

  const serviceCount = await serviceRepo.count();
  if (serviceCount === 0) {
    await serviceRepo.save([
      serviceRepo.create({ name: 'Classic Facial', category: 'Skin', durationMinutes: 45, price: '1500.00', commissionPercent: '10.00' }),
      serviceRepo.create({ name: 'Haircut & Styling', category: 'Hair', durationMinutes: 30, price: '800.00', commissionPercent: '10.00' }),
      serviceRepo.create({ name: 'Full Body Massage', category: 'Wellness', durationMinutes: 60, price: '2500.00', commissionPercent: '15.00' }),
    ]);
    console.log('Seeded default service catalog');
  }

  const resourceCount = await resourceRepo.count({ where: { branchId: branch.id } });
  if (resourceCount === 0) {
    await resourceRepo.save([
      resourceRepo.create({ name: 'Chair 1', type: ResourceType.CHAIR, branchId: branch.id }),
      resourceRepo.create({ name: 'Chair 2', type: ResourceType.CHAIR, branchId: branch.id }),
      resourceRepo.create({ name: 'Treatment Room 1', type: ResourceType.ROOM, branchId: branch.id }),
    ]);
    console.log('Seeded default chairs and rooms');
  }

  let vendor = await vendorRepo.findOne({ where: { name: 'Lakme Distributors' } });
  if (!vendor) {
    vendor = await vendorRepo.save(
      vendorRepo.create({ name: 'Lakme Distributors', phone: '9988776655' }),
    );
    console.log('Seeded default vendor');
  }

  const productCount = await productRepo.count();
  if (productCount === 0) {
    const products = await productRepo.save([
      productRepo.create({
        name: 'Keratin Shampoo 500ml',
        sku: 'SH-KER-500',
        category: 'Hair care',
        unit: 'bottle',
        reorderLevel: 10,
      }),
      productRepo.create({
        name: 'Hair Serum 100ml',
        sku: 'SR-100',
        category: 'Hair care',
        unit: 'bottle',
        reorderLevel: 15,
      }),
    ]);
    console.log('Seeded default product catalog');

    for (const product of products) {
      const batch = await stockBatchRepo.save(
        stockBatchRepo.create({
          productId: product.id,
          branchId: branch.id,
          vendorId: vendor.id,
          quantityReceived: 25,
          quantityRemaining: 25,
          unitCost: '250.00',
        }),
      );
      await stockMovementRepo.save(
        stockMovementRepo.create({
          productId: product.id,
          branchId: branch.id,
          batchId: batch.id,
          type: StockMovementType.RECEIVE,
          quantity: 25,
        }),
      );
    }
    console.log('Seeded opening stock for the flagship branch');
  }

  await AppDataSource.destroy();
  console.log('Seed complete');
}

seed().catch((error) => {
  console.error('Seed failed', error);
  process.exit(1);
});
