CREATE TABLE "public"."child_pin_credentials" (
  "child_id"     uuid                     NOT NULL,
  "pin_verifier" text                     NOT NULL,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "child_pin_credentials_pkey" PRIMARY KEY (child_id),
  CONSTRAINT "child_pin_credentials_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE
);

ALTER TABLE "public"."child_pin_credentials"
  ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_pin_credentials" TO "service_role";

REVOKE ALL ON TABLE "public"."child_pin_credentials" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_pin_credentials" TO "postgres";

REVOKE ALL ON TABLE "public"."child_pin_credentials" FROM "anon", "authenticated";
