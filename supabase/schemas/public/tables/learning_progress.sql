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
  CONSTRAINT "learning_progress_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.child_profiles(id) ON DELETE CASCADE,
  CONSTRAINT "learning_progress_pkey" PRIMARY KEY (id),
  CONSTRAINT "learning_progress_points_earned_check" CHECK ((points_earned >= 0)),
  CONSTRAINT "learning_progress_score_check" CHECK (((score IS NULL) OR (score >= 0))),
  CONSTRAINT "learning_progress_status_check" CHECK ((status = ANY (ARRAY['started'::text, 'completed'::text])))
);

ALTER TABLE "public"."learning_progress"
  ENABLE ROW LEVEL SECURITY;

CREATE INDEX learning_progress_child_id_idx ON public.learning_progress USING btree (child_id, started_at DESC);

CREATE POLICY "Parents can read progress for their children" ON "public"."learning_progress"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.child_profiles c
  WHERE ((c.id = learning_progress.child_id) AND (c.parent_id = ( SELECT auth.uid() AS uid))))));

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."learning_progress" TO "service_role";

REVOKE ALL ON TABLE "public"."learning_progress" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."learning_progress" TO "authenticated";

REVOKE ALL ON TABLE "public"."learning_progress" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."learning_progress" TO "postgres";

REVOKE ALL ON TABLE "public"."learning_progress" FROM "anon";
