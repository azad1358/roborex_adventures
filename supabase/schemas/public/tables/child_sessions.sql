CREATE TABLE "public"."child_sessions" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "child_id"     uuid                     NOT NULL,
  "token_hash"   text                     NOT NULL,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "expires_at"   timestamp with time zone NOT NULL,
  "revoked_at"   timestamp with time zone,
  "last_seen_at" timestamp with time zone,
  CONSTRAINT "child_sessions_check" CHECK ((expires_at > created_at)),
  CONSTRAINT "child_sessions_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE,
  CONSTRAINT "child_sessions_pkey" PRIMARY KEY (id),
  CONSTRAINT "child_sessions_token_hash_key" UNIQUE (token_hash)
);

ALTER TABLE "public"."child_sessions"
  ENABLE ROW LEVEL SECURITY;

CREATE INDEX child_sessions_child_id_idx ON public.child_sessions USING btree (child_id);

CREATE INDEX child_sessions_expiry_idx ON public.child_sessions USING btree (expires_at)
  WHERE (revoked_at IS NULL);

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_sessions" TO "service_role";

REVOKE ALL ON TABLE "public"."child_sessions" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."child_sessions" TO "postgres";

REVOKE ALL ON TABLE "public"."child_sessions" FROM "anon", "authenticated";
