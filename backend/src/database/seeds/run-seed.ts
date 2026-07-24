import * as bcrypt from 'bcrypt';
import { AppDataSource } from '../data-source';
import { Branch } from '../../branches/branch.entity';
import { User } from '../../users/user.entity';
import { ServiceItem } from '../../services/service-item.entity';
import { Resource, ResourceType } from '../../appointments/resource.entity';
import { Role } from '../../common/enums/role.enum';

async function seed() {
  await AppDataSource.initialize();

  const branchRepo = AppDataSource.getRepository(Branch);
  const userRepo = AppDataSource.getRepository(User);
  const serviceRepo = AppDataSource.getRepository(ServiceItem);
  const resourceRepo = AppDataSource.getRepository(Resource);

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

  const serviceCount = await serviceRepo.count();
  if (serviceCount === 0) {
    await serviceRepo.save([
      serviceRepo.create({ name: 'Classic Facial', category: 'Skin', durationMinutes: 45, price: '1500.00' }),
      serviceRepo.create({ name: 'Haircut & Styling', category: 'Hair', durationMinutes: 30, price: '800.00' }),
      serviceRepo.create({ name: 'Full Body Massage', category: 'Wellness', durationMinutes: 60, price: '2500.00' }),
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

  await AppDataSource.destroy();
  console.log('Seed complete');
}

seed().catch((error) => {
  console.error('Seed failed', error);
  process.exit(1);
});
