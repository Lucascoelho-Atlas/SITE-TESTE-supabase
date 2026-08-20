-- Tabela de matriculas: controla quais cursos cada aluno pode ver em aluno.html
-- Cadastro de matriculas e feito manualmente pelo professor no Table Editor do Supabase
-- (ver professor.html), por isso nao ha policy de insert/update/delete para
-- authenticated/anon: o service_role usado no dashboard do Supabase ignora RLS.

create table public.enrollments (
  user_id uuid not null references auth.users(id) on delete cascade,
  course_slug text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, course_slug)
);

alter table public.enrollments enable row level security;

create policy "Users can view their own enrollments"
on public.enrollments
for select
to authenticated
using ( (select auth.uid()) = user_id );
