
-- MUSIC PLAYER: SETUP URUTAN PLAYLIST

-- 1. Tambahkan kolom urutan jika belum ada
ALTER TABLE public.tracks
ADD COLUMN IF NOT EXISTS sort_order INTEGER;

-- 2. Isi nomor urutan lagu yang masih kosong
WITH numbered AS (
    SELECT
        id,
        ROW_NUMBER() OVER (ORDER BY created_at ASC, id ASC) AS nomor
    FROM public.tracks
    WHERE soundcloud_url IS NOT NULL
      AND sort_order IS NULL
)
UPDATE public.tracks AS t
SET sort_order = numbered.nomor
FROM numbered
WHERE t.id = numbered.id;

-- 3. Pastikan admin bisa membaca, menambah,
-- mengubah urutan, dan menghapus lagu
GRANT SELECT, INSERT, UPDATE, DELETE
ON public.tracks TO authenticated;

-- 4. Izinkan admin mengubah data dan urutan lagu
DROP POLICY IF EXISTS "Authenticated can update tracks"
ON public.tracks;

CREATE POLICY "Authenticated can update tracks"
ON public.tracks
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);
