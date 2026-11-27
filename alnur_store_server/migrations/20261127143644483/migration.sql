BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "nupe_play_event" (
    "id" bigserial PRIMARY KEY,
    "songId" bigint NOT NULL,
    "listenerId" bigint,
    "kind" text NOT NULL,
    "platform" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "nupe_play_event_created_idx" ON "nupe_play_event" USING btree ("createdAt");
CREATE INDEX "nupe_play_event_listener_idx" ON "nupe_play_event" USING btree ("listenerId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "nupe_report" (
    "id" bigserial PRIMARY KEY,
    "itemType" text NOT NULL,
    "itemId" text NOT NULL,
    "itemLabel" text,
    "reason" text NOT NULL,
    "details" text,
    "reporterId" bigint,
    "targetListenerId" bigint,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "createdAt" timestamp without time zone NOT NULL,
    "resolvedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "nupe_report_status_idx" ON "nupe_report" USING btree ("status");
CREATE INDEX "nupe_report_created_idx" ON "nupe_report" USING btree ("createdAt");


--
-- MIGRATION VERSION FOR alnur_store
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('alnur_store', '20261127143644483', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261127143644483', "timestamp" = now();

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
