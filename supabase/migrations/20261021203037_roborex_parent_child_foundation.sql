CREATE TABLE "public"."child_pin_credentials" (
  "child_id"     uuid                     NOT NULL,
  "pin_verifier" text                     NOT NULL,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "child_pin_credentials_pkey" PRIMARY KEY (child_id)
);

ALTER TABLE "public"."child_pin_credentials"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."child_pin_credentials" FROM "anon", "authenticated";

CREATE TABLE "public"."child_profiles" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parent_id"  uuid                     NOT NULL,
  "nickname"   text                     NOT NULL,
  "avatar_key" text                     NOT NULL DEFAULT 'roborex'::text,
  "is_active"  boolean                  NOT NULL DEFAULT true,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "child_profiles_nickname_check" CHECK (((char_length(nickname) >= 1) AND (char_length(nickname) <= 24))),
  CONSTRAINT "child_profiles_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."child_profiles"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."child_profiles" FROM "anon";

CREATE TABLE "public"."child_sessions" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "child_id"     uuid                     NOT NULL,
  "token_hash"   text                     NOT NULL,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "expires_at"   timestamp with time zone NOT NULL,
  "revoked_at"   timestamp with time zone,
  "last_seen_at" timestamp with time zone,
  CONSTRAINT "child_sessions_check" CHECK ((expires_at > created_at)),
  CONSTRAINT "child_sessions_pkey" PRIMARY KEY (id),
  CONSTRAINT "child_sessions_token_hash_key" UNIQUE (token_hash)
);

ALTER TABLE "public"."child_sessions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."child_sessions" FROM "anon", "authenticated";

CREATE TABLE "public"."learning_progress" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "child_id"      uuid                     NOT NULL,
  "activity_key"  text                     NOT NULL,
  "status"        text                     NOT NULL DEFAULT 'started'::text,
  "score"         integer,
  "points_earned" integer                  NOT NULL DEFAULT 0,
  "started_at"    timestamp with time zone NOT NULL DEFAULT now(),
  "completed_at"  timestamp with time zone,
  "metadata"      jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT "learning_progress_pkey" PRIMARY KEY (id),
  CONSTRAINT "learning_progress_points_earned_check" CHECK ((points_earned >= 0)),
  CONSTRAINT "learning_progress_score_check" CHECK (((score IS NULL) OR (score >= 0))),
  CONSTRAINT "learning_progress_status_check" CHECK ((status = ANY (ARRAY['started'::text, 'completed'::text])))
);

ALTER TABLE "public"."learning_progress"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."learning_progress" FROM "anon";

CREATE TABLE "public"."parent_profiles" (
  "id"           uuid                     NOT NULL,
  "display_name" text,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "parent_profiles_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."parent_profiles"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."parent_profiles" FROM "anon";

CREATE TABLE "public"."parental_consents" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parent_id"      uuid                     NOT NULL,
  "child_id"       uuid                     NOT NULL,
  "notice_version" text                     NOT NULL,
  "consent_scope"  text                     NOT NULL,
  "consented_at"   timestamp with time zone,
  "withdrawn_at"   timestamp with time zone,
  "recorded_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "parental_consents_check" CHECK (((consented_at IS NULL) OR (withdrawn_at IS NULL) OR (withdrawn_at >= consented_at))),
  CONSTRAINT "parental_consents_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."parental_consents"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."parental_consents" FROM "anon";

CREATE TABLE "public"."points_ledger" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "child_id"     uuid                     NOT NULL,
  "activity_key" text                     NOT NULL,
  "points"       integer                  NOT NULL,
  "reason"       text                     NOT NULL,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "points_ledger_pkey" PRIMARY KEY (id),
  CONSTRAINT "points_ledger_points_check" CHECK ((points > 0))
);

ALTER TABLE "public"."points_ledger"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."points_ledger" FROM "anon";

ALTER TABLE "public"."child_pin_credentials"
  ADD CONSTRAINT "child_pin_credentials_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."child_sessions"
  ADD CONSTRAINT "child_sessions_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."learning_progress"
  ADD CONSTRAINT "learning_progress_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."parent_profiles"
  ADD CONSTRAINT "parent_profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE "public"."child_profiles"
  ADD CONSTRAINT "child_profiles_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.parent_profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."parental_consents"
  ADD CONSTRAINT "parental_consents_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."parental_consents"
  ADD CONSTRAINT "parental_consents_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.parent_profiles(id) ON DELETE CASCADE;

ALTER TABLE "public"."points_ledger"
  ADD CONSTRAINT "points_ledger_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE;

CREATE INDEX child_profiles_parent_id_idx ON public.child_profiles USING btree (parent_id);

CREATE INDEX child_sessions_child_id_idx ON public.child_sessions USING btree (child_id);

CREATE INDEX child_sessions_expiry_idx ON public.child_sessions USING btree (expires_at)
  WHERE (revoked_at IS NULL);

CREATE INDEX learning_progress_child_id_idx ON public.learning_progress USING btree (child_id, started_at DESC);

CREATE INDEX parental_consents_child_id_idx ON public.parental_consents USING btree (child_id, recorded_at DESC);

CREATE INDEX points_ledger_child_id_idx ON public.points_ledger USING btree (child_id, created_at DESC);

CREATE POLICY "Parents can create their own children" ON "public"."child_profiles"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((parent_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can delete their own children" ON "public"."child_profiles"
  FOR DELETE
  TO "authenticated"
  USING ((parent_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can read their own children" ON "public"."child_profiles"
  FOR SELECT
  TO "authenticated"
  USING ((parent_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can update their own children" ON "public"."child_profiles"
  FOR UPDATE
  TO "authenticated"
  USING ((parent_id = ( SELECT auth.uid() AS uid)))
  WITH CHECK ((parent_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can read progress for their children" ON "public"."learning_progress"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.child_profiles c
  WHERE ((c.id = learning_progress.child_id) AND (c.parent_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY "Parents can create their own profile" ON "public"."parent_profiles"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can read their own profile" ON "public"."parent_profiles"
  FOR SELECT
  TO "authenticated"
  USING ((id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can update their own profile" ON "public"."parent_profiles"
  FOR UPDATE
  TO "authenticated"
  USING ((id = ( SELECT auth.uid() AS uid)))
  WITH CHECK ((id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can read consent records for their children" ON "public"."parental_consents"
  FOR SELECT
  TO "authenticated"
  USING ((parent_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Parents can read points for their children" ON "public"."points_ledger"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.child_profiles c
  WHERE ((c.id = points_ledger.child_id) AND (c.parent_id = ( SELECT auth.uid() AS uid))))));

REVOKE ALL ON TABLE "public"."child_pin_credentials" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_pin_credentials" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_pin_credentials" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_profiles" TO "authenticated";

REVOKE ALL ON TABLE "public"."child_profiles" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_profiles" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_profiles" TO "service_role";

REVOKE ALL ON TABLE "public"."child_sessions" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_sessions" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_sessions" TO "service_role";

REVOKE ALL ON TABLE "public"."learning_progress" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."learning_progress" TO "authenticated";

REVOKE ALL ON TABLE "public"."learning_progress" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."learning_progress" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."learning_progress" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parent_profiles" TO "authenticated";

REVOKE ALL ON TABLE "public"."parent_profiles" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parent_profiles" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parent_profiles" TO "service_role";

REVOKE ALL ON TABLE "public"."parental_consents" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."parental_consents" TO "authenticated";

REVOKE ALL ON TABLE "public"."parental_consents" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parental_consents" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parental_consents" TO "service_role";

REVOKE ALL ON TABLE "public"."points_ledger" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."points_ledger" TO "authenticated";

REVOKE ALL ON TABLE "public"."points_ledger" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."points_ledger" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."points_ledger" TO "service_role";
