-- Funcoes que permitem ao professor (e-mail fixo abaixo) liberar/remover
-- matricula de alunos direto pelo professor.html, sem expor a service_role
-- key no site publico. Cada funcao roda com SECURITY DEFINER mas verifica
-- internamente se quem chamou e o e-mail do admin antes de fazer qualquer
-- coisa -- por isso e seguro deixa-las no schema public.

create or replace function public.admin_enroll_student(student_email text, p_course_slug text)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  target_user_id uuid;
begin
  if (auth.jwt() ->> 'email') is distinct from 'lucascfs15123@gmail.com' then
    raise exception 'not authorized';
  end if;

  select id into target_user_id from auth.users where email = student_email limit 1;

  if target_user_id is null then
    raise exception 'Nenhum aluno cadastrado com esse e-mail ainda';
  end if;

  insert into public.enrollments (user_id, course_slug)
  values (target_user_id, p_course_slug)
  on conflict (user_id, course_slug) do nothing;

  return json_build_object('success', true);
end;
$$;

revoke all on function public.admin_enroll_student(text, text) from public;
revoke execute on function public.admin_enroll_student(text, text) from anon;
grant execute on function public.admin_enroll_student(text, text) to authenticated;

create or replace function public.admin_unenroll_student(student_email text, p_course_slug text)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  target_user_id uuid;
begin
  if (auth.jwt() ->> 'email') is distinct from 'lucascfs15123@gmail.com' then
    raise exception 'not authorized';
  end if;

  select id into target_user_id from auth.users where email = student_email limit 1;

  delete from public.enrollments
  where user_id = target_user_id and course_slug = p_course_slug;

  return json_build_object('success', true);
end;
$$;

revoke all on function public.admin_unenroll_student(text, text) from public;
revoke execute on function public.admin_unenroll_student(text, text) from anon;
grant execute on function public.admin_unenroll_student(text, text) to authenticated;

create or replace function public.admin_list_enrollments()
returns table(student_email text, course_slug text, enrolled_at timestamptz)
language plpgsql
security definer
set search_path = public
as $$
begin
  if (auth.jwt() ->> 'email') is distinct from 'lucascfs15123@gmail.com' then
    raise exception 'not authorized';
  end if;

  return query
    select u.email::text, e.course_slug, e.created_at
    from public.enrollments e
    join auth.users u on u.id = e.user_id
    order by e.created_at desc;
end;
$$;

revoke all on function public.admin_list_enrollments() from public;
revoke execute on function public.admin_list_enrollments() from anon;
grant execute on function public.admin_list_enrollments() to authenticated;
