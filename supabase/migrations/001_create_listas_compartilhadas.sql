-- Criação da tabela para armazenar listas compartilhadas entre usuários
-- IMPORTANTE: Execute isso no SQL Editor do Supabase (https://app.supabase.com)

-- Tabela para listas compartilhadas
CREATE TABLE IF NOT EXISTS public.listas_compartilhadas (
  id TEXT PRIMARY KEY,
  lista_id TEXT NOT NULL,
  nome TEXT NOT NULL,
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  criador_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  produtos_json TEXT NOT NULL,
  data_compartilhamento TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_listas_compartilhadas_usuario_id 
  ON public.listas_compartilhadas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_listas_compartilhadas_criador_id 
  ON public.listas_compartilhadas(criador_id);
CREATE INDEX IF NOT EXISTS idx_listas_compartilhadas_data 
  ON public.listas_compartilhadas(data_compartilhamento DESC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE public.listas_compartilhadas ENABLE ROW LEVEL SECURITY;

-- Política para visualizar listas compartilhadas por outros usuários
-- Um usuário pode ver listas compartilhadas por OUTROS usuários (onde usuario_id != auth.uid())
CREATE POLICY "Usuários podem ver listas de outros usuários"
  ON public.listas_compartilhadas
  FOR SELECT
  USING (usuario_id != auth.uid());

-- Política para criar novas listas compartilhadas
-- Um usuário pode inserir uma lista apenas se usuario_id for o seu próprio ID
CREATE POLICY "Usuários podem compartilhar suas próprias listas"
  ON public.listas_compartilhadas
  FOR INSERT
  WITH CHECK (usuario_id = auth.uid() AND criador_id = auth.uid());

-- Política para atualizar listas compartilhadas
-- Apenas o criador pode atualizar
CREATE POLICY "Apenas criador pode atualizar lista"
  ON public.listas_compartilhadas
  FOR UPDATE
  USING (criador_id = auth.uid());

-- Política para deletar listas compartilhadas
-- Apenas o criador pode deletar sua própria lista compartilhada
CREATE POLICY "Apenas criador pode deletar lista"
  ON public.listas_compartilhadas
  FOR DELETE
  USING (criador_id = auth.uid());

-- Comentários para documentação
COMMENT ON TABLE public.listas_compartilhadas IS 'Listas de compras compartilhadas entre usuários na nuvem';
COMMENT ON COLUMN public.listas_compartilhadas.id IS 'UUID único da lista compartilhada';
COMMENT ON COLUMN public.listas_compartilhadas.lista_id IS 'ID local da lista';
COMMENT ON COLUMN public.listas_compartilhadas.nome IS 'Nome da lista compartilhada';
COMMENT ON COLUMN public.listas_compartilhadas.usuario_id IS 'ID do usuário que compartilhou a lista';
COMMENT ON COLUMN public.listas_compartilhadas.criador_id IS 'ID do usuário que criou originalmente a lista';
COMMENT ON COLUMN public.listas_compartilhadas.produtos_json IS 'JSON com array de produtos da lista';
COMMENT ON COLUMN public.listas_compartilhadas.data_compartilhamento IS 'Data e hora que a lista foi compartilhada';
