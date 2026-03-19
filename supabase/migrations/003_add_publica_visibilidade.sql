-- Adiciona controle de visibilidade de listas na nuvem.
-- publica = true  -> visível para outros usuários
-- publica = false -> visível apenas para o dono

ALTER TABLE IF EXISTS public.listas
  ADD COLUMN IF NOT EXISTS publica BOOLEAN NOT NULL DEFAULT TRUE;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'listas_compartilhadas'
  ) THEN
    EXECUTE 'ALTER TABLE public.listas_compartilhadas ADD COLUMN IF NOT EXISTS publica BOOLEAN NOT NULL DEFAULT TRUE';
  END IF;
END $$;

COMMENT ON COLUMN public.listas.publica IS 'true = lista pública; false = lista privada';

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'listas_compartilhadas'
  ) THEN
    EXECUTE 'COMMENT ON COLUMN public.listas_compartilhadas.publica IS ''true = lista pública; false = lista privada''';
  END IF;
END $$;
