BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "store_category" (
    "id" bigserial PRIMARY KEY,
    "categoryId" text NOT NULL,
    "name" text NOT NULL,
    "iconName" text,
    "tagline" text,
    "intro" text,
    "colorHex" text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "store_product" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "categoryId" text NOT NULL,
    "price" double precision NOT NULL,
    "originalPrice" double precision,
    "rating" double precision NOT NULL,
    "reviewCount" bigint NOT NULL,
    "imageUrl" text NOT NULL,
    "description" text NOT NULL,
    "isAvailable" boolean NOT NULL,
    "isFavorite" boolean
);


--
-- MIGRATION VERSION FOR alnur_store
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('alnur_store', '20261023041748725', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023041748725', "timestamp" = now();

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
