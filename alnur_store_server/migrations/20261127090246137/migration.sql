BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "nupe_listener" (
    "id" bigserial PRIMARY KEY,
    "username" text NOT NULL,
    "email" text NOT NULL,
    "firstName" text,
    "lastName" text,
    "passwordHash" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "lastSeenAt" timestamp without time zone,
    "lastActivity" text,
    "platform" text,
    "isDisabled" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE UNIQUE INDEX "nupe_listener_username_idx" ON "nupe_listener" USING btree ("username");
CREATE UNIQUE INDEX "nupe_listener_email_idx" ON "nupe_listener" USING btree ("email");
CREATE INDEX "nupe_listener_last_seen_idx" ON "nupe_listener" USING btree ("lastSeenAt");


--
-- MIGRATION VERSION FOR alnur_store
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('alnur_store', '20261127090246137', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261127090246137', "timestamp" = now();

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
