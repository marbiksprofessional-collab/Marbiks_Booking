import { MigrationInterface, QueryRunner } from "typeorm";

export class AttendanceAndCommission1784883629441 implements MigrationInterface {
    name = 'AttendanceAndCommission1784883629441'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "attendance_records" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "userId" uuid NOT NULL, "branchId" uuid NOT NULL, "clockInAt" TIMESTAMP WITH TIME ZONE NOT NULL, "clockOutAt" TIMESTAMP WITH TIME ZONE, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_946920332f5bc9efad3f3023b96" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_73796654c582080014d49fdffb" ON "attendance_records" ("userId", "clockInAt") `);
        await queryRunner.query(`ALTER TABLE "service_items" ADD "commissionPercent" numeric(5,2) NOT NULL DEFAULT '0'`);
        await queryRunner.query(`ALTER TABLE "attendance_records" ADD CONSTRAINT "FK_3e24aad29f272e2606de0462420" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "attendance_records" ADD CONSTRAINT "FK_1e54e65dc1807c1c1103426643e" FOREIGN KEY ("branchId") REFERENCES "branches"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "attendance_records" DROP CONSTRAINT "FK_1e54e65dc1807c1c1103426643e"`);
        await queryRunner.query(`ALTER TABLE "attendance_records" DROP CONSTRAINT "FK_3e24aad29f272e2606de0462420"`);
        await queryRunner.query(`ALTER TABLE "service_items" DROP COLUMN "commissionPercent"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_73796654c582080014d49fdffb"`);
        await queryRunner.query(`DROP TABLE "attendance_records"`);
    }

}
