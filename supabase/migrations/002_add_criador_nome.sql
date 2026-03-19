-- Adiciona nome de exibição do criador para evitar mostrar UID na interface.
-- Compatível com bancos que têm apenas public.listas (schema atual)
-- e também com bancos antigos que ainda tenham public.listas_compartilhadas.

ALTER TABLE IF EXISTS public.listas
  ADD COLUMN IF NOT EXISTS criador_nome TEXT;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'listas_compartilhadas'
  ) THEN
    EXECUTE 'ALTER TABLE public.listas_compartilhadas ADD COLUMN IF NOT EXISTS criador_nome TEXT';
  END IF;
END $$;

COMMENT ON COLUMN public.listas.criador_nome IS 'Display name do usuário que compartilhou a lista';

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'listas_compartilhadas'
  ) THEN
    EXECUTE $$COMMENT ON COLUMN public.listas_compartilhadas.criador_nome IS 'Display name do usuário que compartilhou a lista'$$;
  END IF;
END $$;
