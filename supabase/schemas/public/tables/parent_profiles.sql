CREATE TABLE "public"."parent_profiles" (
  "id"           uuid                     NOT NULL,
  "display_name" text,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "parent_profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT "parent_profiles_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."parent_profiles"
  ENABLE ROW LEVEL SECURITY;

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

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parent_profiles" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parent_profiles" TO "service_role";

REVOKE ALL ON TABLE "public"."parent_profiles" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parent_profiles" TO "postgres";

REVOKE ALL ON TABLE "public"."parent_profiles" FROM "anon";
