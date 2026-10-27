BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "idempotency_record" (
    "id" bigserial PRIMARY KEY,
    "key" text NOT NULL,
    "endpoint" text NOT NULL,
    "requestHash" text NOT NULL,
    "status" text NOT NULL,
    "responseJson" text,
    "statusCode" bigint,
    "errorMessage" text,
    "createdAt" timestamp without time zone NOT NULL,
    "lockedAt" timestamp without time zone,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "idempotency_record_key_idx" ON "idempotency_record" USING btree ("key");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "store_order" (
    "id" bigserial PRIMARY KEY,
    "orderRef" text NOT NULL,
    "customerEmail" text NOT NULL,
    "customerName" text NOT NULL,
    "customerPhone" text NOT NULL,
    "shippingAddress" text NOT NULL,
    "totalAmount" double precision NOT NULL,
    "paymentStatus" text NOT NULL,
    "fulfillmentStatus" text NOT NULL,
    "idempotencyKey" text,
    "paymentReference" text,
    "itemsJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "store_order_ref_idx" ON "store_order" USING btree ("orderRef");


--
-- MIGRATION VERSION FOR alnur_store
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('alnur_store', '20261027115736276', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261027115736276', "timestamp" = now();

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
