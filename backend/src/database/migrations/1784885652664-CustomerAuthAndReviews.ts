import { MigrationInterface, QueryRunner } from "typeorm";

export class CustomerAuthAndReviews1784885652664 implements MigrationInterface {
    name = 'CustomerAuthAndReviews1784885652664'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "reviews" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "customerId" uuid NOT NULL, "appointmentId" uuid NOT NULL, "branchId" uuid NOT NULL, "technicianId" uuid, "rating" integer NOT NULL, "comment" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_231ae565c273ee700b283f15c1d" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE UNIQUE INDEX "IDX_45a6cefc24d5af16842be69a65" ON "reviews" ("appointmentId") `);
        await queryRunner.query(`CREATE TABLE "otp_codes" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "phone" character varying NOT NULL, "codeHash" character varying NOT NULL, "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL, "consumed" boolean NOT NULL DEFAULT false, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_9d0487965ac1837d57fec4d6a26" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_da14d5fd28d202557193fb3fdf" ON "otp_codes" ("phone") `);
        await queryRunner.query(`ALTER TABLE "reviews" ADD CONSTRAINT "FK_6d99bdfa69280ede313699fab92" FOREIGN KEY ("customerId") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "reviews" ADD CONSTRAINT "FK_45a6cefc24d5af16842be69a65a" FOREIGN KEY ("appointmentId") REFERENCES "appointments"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "reviews" DROP CONSTRAINT "FK_45a6cefc24d5af16842be69a65a"`);
        await queryRunner.query(`ALTER TABLE "reviews" DROP CONSTRAINT "FK_6d99bdfa69280ede313699fab92"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_da14d5fd28d202557193fb3fdf"`);
        await queryRunner.query(`DROP TABLE "otp_codes"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_45a6cefc24d5af16842be69a65"`);
        await queryRunner.query(`DROP TABLE "reviews"`);
    }

}
