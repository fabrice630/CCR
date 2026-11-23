-- À coller dans Supabase > SQL Editor > Run.
-- Peut être relancé sans danger, même si tu as déjà exécuté l'ancienne version.

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  preacher text not null default 'Pasteur Principal',
  kind text not null default 'message',
  media_url text not null,
  secs int not null default 0,
  published_at timestamptz not null default now()
);
alter table messages drop constraint if exists messages_kind_check;
alter table messages add constraint messages_kind_check check (kind in ('message','testimony','video'));

create table if not exists announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text,
  event_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists lives (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  url text not null,
  starts_at timestamptz not null,
  weekly boolean not null default false,
  created_at timestamptz not null default now()
);

-- Liste des administrateurs (seuls eux peuvent publier)
create table if not exists admins (user_id uuid primary key references auth.users(id) on delete cascade);
alter table admins enable row level security;

create or replace function is_admin() returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from admins where user_id = auth.uid()) $$;

alter table messages enable row level security;
alter table announcements enable row level security;
alter table lives enable row level security;

-- Nettoyage des anciennes règles
drop policy if exists "lecture publique messages" on messages;
drop policy if exists "lecture publique annonces" on announcements;
drop policy if exists "admin messages" on messages;
drop policy if exists "admin annonces" on announcements;
drop policy if exists "lecture messages" on messages;
drop policy if exists "lecture annonces" on announcements;
drop policy if exists "lecture directs" on lives;
drop policy if exists "ecriture messages" on messages;
drop policy if exists "ecriture annonces" on announcements;
drop policy if exists "ecriture directs" on lives;

-- Tout le monde lit (les messages programmés dans le futur restent cachés)
create policy "lecture messages" on messages for select using (published_at <= now() or is_admin());
create policy "lecture annonces" on announcements for select using (true);
create policy "lecture directs" on lives for select using (true);

-- Seuls les admins écrivent
create policy "ecriture messages" on messages for all using (is_admin()) with check (is_admin());
create policy "ecriture annonces" on announcements for all using (is_admin()) with check (is_admin());
create policy "ecriture directs" on lives for all using (is_admin()) with check (is_admin());

-- Fichiers audio
insert into storage.buckets (id, name, public) values ('media', 'media', true) on conflict (id) do nothing;
drop policy if exists "lecture media" on storage.objects;
drop policy if exists "envoi media admin" on storage.objects;
drop policy if exists "suppression media admin" on storage.objects;
create policy "lecture media" on storage.objects for select using (bucket_id = 'media');
create policy "envoi media admin" on storage.objects for insert to authenticated with check (bucket_id = 'media' and is_admin());
create policy "suppression media admin" on storage.objects for delete to authenticated using (bucket_id = 'media' and is_admin());

-- ÉTAPE FINALE : ajoute-toi (et le pasteur) comme admin. Remplace l'email, puis exécute :
-- insert into admins (user_id) select id from auth.users where email = 'ton-email@exemple.com';

-- Durcissement : taille et types de fichiers acceptés par le serveur (50 Mo, audio uniquement)
update storage.buckets set file_size_limit = 52428800,
  allowed_mime_types = array['audio/mpeg','audio/mp4','audio/x-m4a','audio/aac','audio/wav','audio/ogg']
  where id = 'media';
revoke all on admins from anon, authenticated;
