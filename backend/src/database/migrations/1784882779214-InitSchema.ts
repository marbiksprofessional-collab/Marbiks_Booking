import { MigrationInterface, QueryRunner } from "typeorm";

export class InitSchema1784882779214 implements MigrationInterface {
    name = 'InitSchema1784882779214'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "branches" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "code" character varying NOT NULL, "name" character varying NOT NULL, "address" character varying, "city" character varying, "state" character varying, "phone" character varying, "isActive" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_9c06cbb83feb2f0be6263bd47ee" UNIQUE ("code"), CONSTRAINT "PK_7f37d3b42defea97f1df0d19535" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TYPE "public"."users_role_enum" AS ENUM('SUPER_ADMIN', 'DIRECTOR', 'GENERAL_MANAGER', 'HR_MANAGER', 'BRANCH_MANAGER', 'FLOOR_MANAGER', 'RECEPTIONIST', 'TECHNICIAN', 'STORE_MANAGER', 'ACCOUNTANT', 'MARKETING_MANAGER', 'DIGITAL_MARKETING', 'TRAINER', 'ACADEMY_STUDENT', 'FRANCHISE_OWNER', 'CUSTOMER')`);
        await queryRunner.query(`CREATE TABLE "users" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "fullName" character varying NOT NULL, "email" character varying NOT NULL, "phone" character varying, "passwordHash" character varying NOT NULL, "role" "public"."users_role_enum" NOT NULL, "branchId" uuid, "isActive" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE UNIQUE INDEX "IDX_97672ac88f789774dd47f7c8be" ON "users" ("email") `);
        await queryRunner.query(`CREATE TABLE "service_items" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying NOT NULL, "category" character varying, "durationMinutes" integer NOT NULL, "price" numeric(10,2) NOT NULL, "isActive" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_7383c18e3c8e4956860b117728a" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "customers" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "fullName" character varying NOT NULL, "phone" character varying NOT NULL, "email" character varying, "notes" character varying, "loyaltyPoints" integer NOT NULL DEFAULT '0', "isActive" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_133ec679a801fab5e070f73d3ea" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE UNIQUE INDEX "IDX_88acd889fbe17d0e16cc4bc917" ON "customers" ("phone") `);
        await queryRunner.query(`CREATE TYPE "public"."resources_type_enum" AS ENUM('CHAIR', 'ROOM', 'BED', 'MACHINE')`);
        await queryRunner.query(`CREATE TABLE "resources" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying NOT NULL, "type" "public"."resources_type_enum" NOT NULL, "branchId" uuid NOT NULL, "isActive" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_632484ab9dff41bba94f9b7c85e" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TYPE "public"."appointments_status_enum" AS ENUM('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW')`);
        await queryRunner.query(`CREATE TABLE "appointments" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "branchId" uuid NOT NULL, "customerId" uuid NOT NULL, "technicianId" uuid, "resourceId" uuid, "serviceId" uuid NOT NULL, "startTime" TIMESTAMP WITH TIME ZONE NOT NULL, "endTime" TIMESTAMP WITH TIME ZONE NOT NULL, "status" "public"."appointments_status_enum" NOT NULL DEFAULT 'PENDING', "notes" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_4a437a9a27e948726b8bb3e36ad" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_e7a983e9dd5fa2d04a2acb117b" ON "appointments" ("resourceId", "startTime", "endTime") `);
        await queryRunner.query(`CREATE INDEX "IDX_ea4bceef7744d868522764602a" ON "appointments" ("technicianId", "startTime", "endTime") `);
        await queryRunner.query(`CREATE TABLE "invoice_items" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "invoiceId" uuid NOT NULL, "description" character varying NOT NULL, "quantity" integer NOT NULL DEFAULT '1', "unitPrice" numeric(10,2) NOT NULL, "total" numeric(10,2) NOT NULL, CONSTRAINT "PK_53b99f9e0e2945e69de1a12b75a" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TYPE "public"."invoices_paymentstatus_enum" AS ENUM('UNPAID', 'PARTIAL', 'PAID')`);
        await queryRunner.query(`CREATE TYPE "public"."invoices_paymentmethod_enum" AS ENUM('CASH', 'CARD', 'UPI', 'WALLET', 'OTHER')`);
        await queryRunner.query(`CREATE TABLE "invoices" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "invoiceNumber" character varying NOT NULL, "branchId" uuid NOT NULL, "customerId" uuid NOT NULL, "appointmentId" uuid, "subtotal" numeric(10,2) NOT NULL DEFAULT '0', "discountAmount" numeric(10,2) NOT NULL DEFAULT '0', "taxAmount" numeric(10,2) NOT NULL DEFAULT '0', "total" numeric(10,2) NOT NULL DEFAULT '0', "paymentStatus" "public"."invoices_paymentstatus_enum" NOT NULL DEFAULT 'UNPAID', "paymentMethod" "public"."invoices_paymentmethod_enum", "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_bf8e0f9dd4558ef209ec111782d" UNIQUE ("invoiceNumber"), CONSTRAINT "PK_668cef7c22a427fd822cc1be3ce" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "users" ADD CONSTRAINT "FK_246426dfd001466a1d5e47322f4" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "resources" ADD CONSTRAINT "FK_19f5b7f4e3768f2db2b4b642bbc" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "appointments" ADD CONSTRAINT "FK_299d8147ef59909b1e6531e791c" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "appointments" ADD CONSTRAINT "FK_60dbcf20669c096d319e20fca8a" FOREIGN KEY ("customerId") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "appointments" ADD CONSTRAINT "FK_53053b49389dd5925e06570c853" FOREIGN KEY ("technicianId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "appointments" ADD CONSTRAINT "FK_9b623fcf3c04296ffbdf658bc31" FOREIGN KEY ("resourceId") REFERENCES "resources"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "appointments" ADD CONSTRAINT "FK_f77953c373efb8ab146d98e90c3" FOREIGN KEY ("serviceId") REFERENCES "service_items"("id") ON DELETE RESTRICT ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "invoice_items" ADD CONSTRAINT "FK_7fb6895fc8fad9f5200e91abb59" FOREIGN KEY ("invoiceId") REFERENCES "invoices"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "invoices" ADD CONSTRAINT "FK_1e60c34407bf8d83ae612cc079d" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "invoices" ADD CONSTRAINT "FK_1df049f8943c6be0c1115541efb" FOREIGN KEY ("customerId") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "invoices" ADD CONSTRAINT "FK_c38619b9c5659db0a6cef729b38" FOREIGN KEY ("appointmentId") REFERENCES "appointments"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "invoices" DROP CONSTRAINT "FK_c38619b9c5659db0a6cef729b38"`);
        await queryRunner.query(`ALTER TABLE "invoices" DROP CONSTRAINT "FK_1df049f8943c6be0c1115541efb"`);
        await queryRunner.query(`ALTER TABLE "invoices" DROP CONSTRAINT "FK_1e60c34407bf8d83ae612cc079d"`);
        await queryRunner.query(`ALTER TABLE "invoice_items" DROP CONSTRAINT "FK_7fb6895fc8fad9f5200e91abb59"`);
        await queryRunner.query(`ALTER TABLE "appointments" DROP CONSTRAINT "FK_f77953c373efb8ab146d98e90c3"`);
        await queryRunner.query(`ALTER TABLE "appointments" DROP CONSTRAINT "FK_9b623fcf3c04296ffbdf658bc31"`);
        await queryRunner.query(`ALTER TABLE "appointments" DROP CONSTRAINT "FK_53053b49389dd5925e06570c853"`);
        await queryRunner.query(`ALTER TABLE "appointments" DROP CONSTRAINT "FK_60dbcf20669c096d319e20fca8a"`);
        await queryRunner.query(`ALTER TABLE "appointments" DROP CONSTRAINT "FK_299d8147ef59909b1e6531e791c"`);
        await queryRunner.query(`ALTER TABLE "resources" DROP CONSTRAINT "FK_19f5b7f4e3768f2db2b4b642bbc"`);
        await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "FK_246426dfd001466a1d5e47322f4"`);
        await queryRunner.query(`DROP TABLE "invoices"`);
        await queryRunner.query(`DROP TYPE "public"."invoices_paymentmethod_enum"`);
        await queryRunner.query(`DROP TYPE "public"."invoices_paymentstatus_enum"`);
        await queryRunner.query(`DROP TABLE "invoice_items"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_ea4bceef7744d868522764602a"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_e7a983e9dd5fa2d04a2acb117b"`);
        await queryRunner.query(`DROP TABLE "appointments"`);
        await queryRunner.query(`DROP TYPE "public"."appointments_status_enum"`);
        await queryRunner.query(`DROP TABLE "resources"`);
        await queryRunner.query(`DROP TYPE "public"."resources_type_enum"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_88acd889fbe17d0e16cc4bc917"`);
        await queryRunner.query(`DROP TABLE "customers"`);
        await queryRunner.query(`DROP TABLE "service_items"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_97672ac88f789774dd47f7c8be"`);
        await queryRunner.query(`DROP TABLE "users"`);
        await queryRunner.query(`DROP TYPE "public"."users_role_enum"`);
        await queryRunner.query(`DROP TABLE "branches"`);
    }

}
