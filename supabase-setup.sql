-- Jalankan sekali di Supabase SQL Editor.
-- Menambahkan kolom untuk URL SoundCloud; data lama tidak dihapus.
alter table public.tracks
  add column if not exists soundcloud_url text;

-- Kolom file_path perlu boleh NULL karena lagu baru memakai URL SoundCloud.
alter table public.tracks
  alter column file_path drop not null;

-- Hak akses tabel (RLS tetap mengatur siapa yang boleh membaca/menulis).
grant usage on schema public to anon, authenticated;
grant select on public.tracks to anon, authenticated;
grant insert, delete on public.tracks to authenticated;

-- Pastikan policy baca publik tersedia.
alter table public.tracks enable row level security;
drop policy if exists "Public can read tracks" on public.tracks;
create policy "Public can read tracks"
on public.tracks for select
to anon, authenticated
using (true);

-- Admin yang sudah login boleh menambah dan menghapus lagu.
drop policy if exists "Authenticated can insert tracks" on public.tracks;
create policy "Authenticated can insert tracks"
on public.tracks for insert
to authenticated
with check (true);

drop policy if exists "Authenticated can delete tracks" on public.tracks;
create policy "Authenticated can delete tracks"
on public.tracks for delete
to authenticated
using (true);
