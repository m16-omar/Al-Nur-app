BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "store_product" ADD COLUMN "colors" json;
ALTER TABLE "store_product" ADD COLUMN "sizes" json;

--
-- MIGRATION VERSION FOR alnur_store
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('alnur_store', '20261023131946264', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023131946264', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
