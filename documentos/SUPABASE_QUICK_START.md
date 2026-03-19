⚠️ **ATENÇÃO: CONFIGURAÇÃO OBRIGATÓRIA PARA COMPARTILHAMENTO DE LISTAS**

Seu app está pronto para sincronizar listas com a nuvem, mas precisa de UM passo manual no Supabase.

## ⚡ Procedimento Rápido (5 minutos)

1. **Abra o Supabase Console**
   - URL: https://app.supabase.com
   - Projeto: "hardlist" (zlfhxcksweffglpjelci)

2. **Vá ao SQL Editor**
   - Menu lateral → "SQL Editor"
   - Clique em "+ New Query"

3. **Cole este comando SQL:**

```sql
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

CREATE INDEX idx_listas_compartilhadas_usuario_id ON public.listas_compartilhadas(usuario_id);
CREATE INDEX idx_listas_compartilhadas_criador_id ON public.listas_compartilhadas(criador_id);
CREATE INDEX idx_listas_compartilhadas_data ON public.listas_compartilhadas(data_compartilhamento DESC);

ALTER TABLE public.listas_compartilhadas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem ver listas de outros usuários" ON public.listas_compartilhadas FOR SELECT USING (usuario_id != auth.uid());
CREATE POLICY "Usuários podem compartilhar suas próprias listas" ON public.listas_compartilhadas FOR INSERT WITH CHECK (usuario_id = auth.uid() AND criador_id = auth.uid());
CREATE POLICY "Apenas criador pode atualizar lista" ON public.listas_compartilhadas FOR UPDATE USING (criador_id = auth.uid());
CREATE POLICY "Apenas criador pode deletar lista" ON public.listas_compartilhadas FOR DELETE USING (criador_id = auth.uid());
```

4. **Clique em "Execute"** (botão de play ou Ctrl+Enter)

5. **Pronto!** ✅

## 🎯 Resultado

Agora você pode:
- ✅ Compartilhar listas com outros usuários
- ✅ Ver listas compartilhadas com você em "Listas Recebidas"
- ✅ Baixar e gerenciar listas sincronizadas

---

📖 **Documentação completa**: Veja `SUPABASE_SETUP.md` para mais detalhes e troubleshooting
