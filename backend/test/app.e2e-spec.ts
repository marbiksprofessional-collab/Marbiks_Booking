import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import * as request from 'supertest';
import * as bcrypt from 'bcrypt';
import { getRepositoryToken } from '@nestjs/typeorm';
import { AuthModule } from '../src/auth/auth.module';
import { UsersModule } from '../src/users/users.module';
import { User } from '../src/users/user.entity';
import { Branch } from '../src/branches/branch.entity';
import { Customer } from '../src/customers/customer.entity';
import { ServiceItem } from '../src/services/service-item.entity';
import { Resource } from '../src/appointments/resource.entity';
import { Appointment } from '../src/appointments/appointment.entity';
import { Invoice } from '../src/billing/invoice.entity';
import { InvoiceItem } from '../src/billing/invoice-item.entity';
import { Role } from '../src/common/enums/role.enum';

describe('Auth (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          envFilePath: '.env',
        }),
        TypeOrmModule.forRoot({
          type: 'postgres',
          host: process.env.DB_HOST || 'localhost',
          port: parseInt(process.env.DB_PORT || '5432', 10),
          username: process.env.DB_USERNAME || 'marbiks',
          password: process.env.DB_PASSWORD || 'marbiks',
          database: process.env.DB_DATABASE_TEST || 'marbiks_erp_test',
          entities: [Branch, User, Customer, ServiceItem, Resource, Appointment, Invoice, InvoiceItem],
          synchronize: true,
          dropSchema: true,
        }),
        AuthModule,
        UsersModule,
      ],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();

    const usersRepository = moduleFixture.get(getRepositoryToken(User));
    await usersRepository.save(
      usersRepository.create({
        fullName: 'Test Receptionist',
        email: 'e2e-reception@marbiks.com',
        passwordHash: await bcrypt.hash('Password123!', 10),
        role: Role.RECEPTIONIST,
      }),
    );
  });

  afterAll(async () => {
    await app.close();
  });

  it('rejects invalid credentials', () => {
    return request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'e2e-reception@marbiks.com', password: 'wrong-password' })
      .expect(401);
  });

  it('logs in with valid credentials and returns a usable JWT', async () => {
    const loginResponse = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'e2e-reception@marbiks.com', password: 'Password123!' })
      .expect(200);

    expect(loginResponse.body.accessToken).toBeDefined();
    expect(loginResponse.body.user.role).toBe(Role.RECEPTIONIST);

    await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${loginResponse.body.accessToken}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.email).toBe('e2e-reception@marbiks.com');
      });
  });

  it('rejects requests without a token', () => {
    return request(app.getHttpServer()).get('/auth/me').expect(401);
  });
});
