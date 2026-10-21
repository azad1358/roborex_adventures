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
  CONSTRAINT "parental_consents_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE,
  CONSTRAINT "parental_consents_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.parent_profiles(id) ON DELETE CASCADE,
  CONSTRAINT "parental_consents_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."parental_consents"
  ENABLE ROW LEVEL SECURITY;

CREATE INDEX parental_consents_child_id_idx ON public.parental_consents USING btree (child_id, recorded_at DESC);

CREATE POLICY "Parents can read consent records for their children" ON "public"."parental_consents"
  FOR SELECT
  TO "authenticated"
  USING ((parent_id = ( SELECT auth.uid() AS uid)));

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parental_consents" TO "service_role";

REVOKE ALL ON TABLE "public"."parental_consents" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."parental_consents" TO "authenticated";

REVOKE ALL ON TABLE "public"."parental_consents" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parental_consents" TO "postgres";

REVOKE ALL ON TABLE "public"."parental_consents" FROM "anon";
