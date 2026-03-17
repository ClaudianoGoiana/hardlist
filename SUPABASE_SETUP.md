# Configuração do Supabase - HardList Cloud

Este guia explica como configurar o Supabase para ativar o sincronização de listas compartilhadas entre usuários.

## 📋 Pré-requisitos

- Conta ativa no Supabase
- Projeto Supabase criado (já configurado em `lib/main.dart`)
- Acesso ao SQL Editor do Supabase

## 🚀 Passos para Configuração

### 1. Acessar o SQL Editor do Supabase

1. Vá para [app.supabase.com](https://app.supabase.com)
2. Selecione seu projeto "hardlist" (URL: `zlfhxcksweffglpjelci.supabase.co`)
3. No menu lateral, clique em **SQL Editor** ou **Database** → **SQL**

### 2. Executar a Migração

1. Clique em **+ New Query** ou abra uma nova aba SQL
2. Copie o conteúdo completo do arquivo: `supabase/migrations/001_create_listas_compartilhadas.sql`
3. Cole no editor SQL
4. Clique em **Execute** (ícone de play ou pressione `Ctrl+Enter`)

### 3. Verificar a Criação

Após executar, você deve ver:
- ✅ Tabela `listas_compartilhadas` criada
- ✅ Índices criados para melhor performance
- ✅ Políticas de RLS (Row Level Security) ativadas

Para confirmar, vá para **Database** → **Tables** no sidebar e procure por `listas_compartilhadas`.

## 📊 Schema da Tabela

```sql
listas_compartilhadas (
  id TEXT PRIMARY KEY,
  lista_id TEXT,
  nome TEXT,
  usuario_id UUID (referência a auth.users),
  criador_id UUID (referência a auth.users),
  produtos_json TEXT (JSON array),
  data_compartilhamento TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

## 🔐 Segurança - Políticas de RLS

As seguintes políticas RLS foram criadas:

| Política | Ação | Condição |
|----------|------|----------|
| Ver listas de outros | SELECT | Só ver se `usuario_id != auth.uid()` |
| Compartilhar lista | INSERT | Apenas se `usuario_id = auth.uid()` |
| Atualizar lista | UPDATE | Apenas se `criador_id = auth.uid()` |
| Deletar lista | DELETE | Apenas se `criador_id = auth.uid()` |

Isso garante que:
- ✅ Usuários só veem listas compartilhadas por OUTROS
- ✅ Cada usuário só pode compartilhar suas próprias listas
- ✅ Apenas o criador pode modificar/deletar

## 📱 Como Funciona o Fluxo

```
1. Usuário A compartilha lista
   └─> compartilharListaNaCloud() insere em listas_compartilhadas

2. Usuário B abre "Listas Recebidas"
   └─> buscarListasCompartilhadasNuvem() busca onde usuario_id != seu_id

3. Usuário B faz download
   └─> fazerDownloadLista() insere em listas_cloud (SQLite local)

4. Usuário A deleta lista
   └─> removerListaDaNuvem() remove de listas_compartilhadas
```

## 🆘 Solução de Problemas

### Erro: "PostgreSQL syntax error"
- Verifique se copiou todo o arquivo corretamente
- Certifique-se de não deixar caracteres especiais fora do lugar

### Erro: "relação listas_compartilhadas não existe"
- A migração não foi executada
- Repita os passos 1-3 acima

### Tabela criada mas ReceivedListsScreen mostra vazio
- Verifique se há listas compartilhadas (de outros usuários)
- Verifique se o usuário está autenticado (`Supabase.instance.client.auth.currentUser != null`)
- Abra tabela `listas_compartilhadas` em Database → Tables para inspecionar dados

### Erro ao compartilhar: "permission denied"
- Verifique se o RLS está habilitado corretamente
- Certifique-se de que `criador_id` está sendo setado como `auth.uid()` no código

## 🔍 Inspeção Manual no Supabase

Para verificar dados manualmente:

1. Vá para **Database** → **Tables** → **listas_compartilhadas**
2. Clique em **Data** para ver todas as listas compartilhadas
3. Use o SQL Editor para queries customizadas:

```sql
-- Ver todas as listas compartilhadas
SELECT * FROM public.listas_compartilhadas;

-- Ver listas compartilhadas por um usuário específico
SELECT * FROM public.listas_compartilhadas 
WHERE usuario_id = 'USER_ID_HERE';

-- Ver listas criadas por você
SELECT * FROM public.listas_compartilhadas 
WHERE criador_id = auth.uid();
```

## ✅ Após Conclusão

Quando a tabela estiver criada corretamente:

1. ✅ App compila normalmente
2. ✅ Botão "Compartilhar" no HomeScreen funciona
3. ✅ "Listas Recebidas" mostra listas de outros usuários
4. ✅ Download de listas funciona
5. ✅ Exclusão de listas compartilhadas funciona

## 📝 Referências

- [Supabase SQL Editor Documentation](https://supabase.com/docs/guides/api/using-sql)
- [Row Level Security (RLS) Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)

---

**Última atualização**: Gerada automaticamente durante desenvolvimento
**Status**: Configuração obrigatória para funcionalidade de compartilhamento de listas
