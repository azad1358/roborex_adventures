CREATE TABLE "public"."points_ledger" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "child_id"     uuid                     NOT NULL,
  "activity_key" text                     NOT NULL,
  "points"       integer                  NOT NULL,
  "reason"       text                     NOT NULL,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "points_ledger_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE,
  CONSTRAINT "points_ledger_pkey" PRIMARY KEY (id),
  CONSTRAINT "points_ledger_points_check" CHECK ((points > 0))
);

ALTER TABLE "public"."points_ledger"
  ENABLE ROW LEVEL SECURITY;

CREATE INDEX points_ledger_child_id_idx ON public.points_ledger USING btree (child_id, created_at DESC);

CREATE POLICY "Parents can read points for their children" ON "public"."points_ledger"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.child_profiles c
  WHERE ((c.id = points_ledger.child_id) AND (c.parent_id = ( SELECT auth.uid() AS uid))))));

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."points_ledger" TO "service_role";

REVOKE ALL ON TABLE "public"."points_ledger" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."points_ledger" TO "authenticated";

REVOKE ALL ON TABLE "public"."points_ledger" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."points_ledger" TO "postgres";

REVOKE ALL ON TABLE "public"."points_ledger" FROM "anon";
