CREATE TABLE "public"."child_profiles" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parent_id"  uuid                     NOT NULL,
  "nickname"   text                     NOT NULL,
  "avatar_key" text                     NOT NULL DEFAULT 'roborex'::text,
  "is_active"  boolean                  NOT NULL DEFAULT true,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "child_profiles_nickname_check" CHECK (((char_length(nickname) >= 1) AND (char_length(nickname) <= 24))),
  CONSTRAINT "child_profiles_pkey" PRIMARY KEY (id),
  CONSTRAINT "child_profiles_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.parent_profiles(id) ON DELETE CASCADE
);

ALTER TABLE "public"."child_profiles"
  ENABLE ROW LEVEL SECURITY;

CREATE INDEX child_profiles_parent_id_idx ON public.child_profiles USING btree (parent_id);

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

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_profiles" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_profiles" TO "service_role";

REVOKE ALL ON TABLE "public"."child_profiles" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_profiles" TO "postgres";

REVOKE ALL ON TABLE "public"."child_profiles" FROM "anon";
