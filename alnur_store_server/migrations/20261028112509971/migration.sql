BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_account_info" (
    "id" bigserial PRIMARY KEY,
    "userEmail" text NOT NULL,
    "fullName" text NOT NULL,
    "phoneNumber" text,
    "avatarUrl" text,
    "preferredCurrency" text,
    "bio" text
);

-- Indexes
CREATE UNIQUE INDEX "user_account_email_idx" ON "user_account_info" USING btree ("userEmail");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_address" (
    "id" bigserial PRIMARY KEY,
    "userEmail" text NOT NULL,
    "title" text NOT NULL,
    "recipientName" text NOT NULL,
    "phoneNumber" text NOT NULL,
    "streetAddress" text NOT NULL,
    "city" text NOT NULL,
    "state" text NOT NULL,
    "country" text,
    "postalCode" text,
    "isDefault" boolean NOT NULL,
    "additionalInstructions" text
);

-- Indexes
CREATE INDEX "user_address_email_idx" ON "user_address" USING btree ("userEmail");


--
-- MIGRATION VERSION FOR alnur_store
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('alnur_store', '20261028112509971', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261028112509971', "timestamp" = now();

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
