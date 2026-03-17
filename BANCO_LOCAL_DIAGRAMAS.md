# Diagrama da Arquitetura: banco_local.dart

## 🏗️ Estrutura de Dados Completa

```
┌─────────────────────────────────────────────────────────────────────┐
│                        HARDLIST APP                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │           BANCO DE DADOS SQLite (LOCAL)                     │  │
│  │      File: ${app_data}/hardlist_offline.db (v2)            │  │
│  │                                                              │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐        │  │
│  │  │   LISTAS    │  │  PRODUTOS    │  │  HISTÓRICO   │        │  │
│  │  │             │  │              │  │              │        │  │
│  │  │ id (TEXT)   │  │ id (TEXT)    │  │ id (TEXT)    │        │  │
│  │  │ nome (TEXT) │  │ lista_id ──┐ │  │ lista_id +   │        │  │
│  │  │             │  │ nome (TEXT) │ │  │ nome (TEXT) │        │  │
│  │  │ (0-N)       │  │ categoria   │ │  │ data (TEXT) │        │  │
│  │  │             │  │ quantidade  │ │  │ valor (REAL)│        │  │
│  │  │  Ex:        │  │ preco (REAL)│ │  │ produtos_   │        │  │
│  │  │  Superm.    │  │ foto (TEXT) │ │  │  json (TEXT)│        │  │
│  │  │  Padaria    │  │ comprado(→) │ │  │             │        │  │
│  │  │  Farmácia   │  │             │ │  │  Ex:        │        │  │
│  │  │             │  │ (0-100+)    │ │  │  2026-03-17 │        │  │
│  │  └─────────────┘  └─────────┬──┘ │  │  R\$ 152,50 │        │  │
│  │         ↑                    │    │  │  [{"nome":  │        │  │
│  │         │                    │    │  │   "Leite"}] │        │  │
│  │    Criada por          Referencia └──┘  │        │        │  │
│  │    ListScreen          local             └────────────┐     │  │
│  │                                                       │     │  │
│  │  ┌──────────────────────────────────────────────────┘     │  │
│  │  │                                                        │  │
│  │  ↓                                                        │  │
│  │  ┌─────────────────────┐                                 │  │
│  │  │  LISTAS_CLOUD       │                                 │  │
│  │  │  (Cache Local)      │  ← Baixadas de Supabase         │  │
│  │  │                     │                                 │  │
│  │  │ id (TEXT)           │                                 │  │
│  │  │ lista_id (TEXT)     │                                 │  │
│  │  │ nome (TEXT)         │                                 │  │
│  │  │ data_compartilh...  │                                 │  │
│  │  │ usuario_id (TEXT)   │                                 │  │
│  │  │ produtos_json (TEXT)│                                 │  │
│  │  │                     │                                 │  │
│  │  │ (Leitura/Visua.)    │                                 │  │
│  │  └─────────────────────┘                                 │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ↑ ↓ Sync (async)                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        SUPABASE CLOUD (Remote PostgreSQL)               │  │
│  │                                                          │  │
│  │  ┌─────────────────────────────────────┐                │  │
│  │  │  listas_compartilhadas (table)      │                │  │
│  │  │                                     │                │  │
│  │  │  id (TEXT)                          │                │  │
│  │  │  lista_id (TEXT)                    │                │  │
│  │  │  nome (TEXT)                        │                │  │
│  │  │  usuario_id (UUID) ──→ auth.users   │                │  │
│  │  │  criador_id (UUID) ──→ auth.users   │                │  │
│  │  │  produtos_json (TEXT)               │                │  │
│  │  │  data_compartilhamento (TIMESTAMP)  │                │  │
│  │  │                                     │                │  │
│  │  │  RLS Policies:                      │                │  │
│  │  │  SELECT: usuario_id != auth.uid()   │                │  │
│  │  │  INSERT: usuario_id = auth.uid()    │                │  │
│  │  │  UPDATE: criador_id = auth.uid()    │                │  │
│  │  │  DELETE: criador_id = auth.uid()    │                │  │
│  │  └─────────────────────────────────────┘                │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxos de Sincronização

### Fluxo A: Compra Local
```
┌─────────────────────────────────────────────────┐
│ HomeScreen: Usuário finaliza compra             │
└────────────────┬────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────┐
│ Calcula total (sum de preço × quantidade)       │
└────────────────┬────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────┐
│ adicionarHistorico() insere em "historico"      │
│ - id: uuid                                      │
│ - lista_id: referência                          │
│ - nome: "Supermercado"                          │
│ - data: "2026-03-17T15:30:00.000Z"              │
│ - valor: 152.50                                 │
│ - produtos_json: [{"nome":"Leite",...}]         │
└────────────────┬────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────┐
│ SQLite autom. DELETE produtos via FOREIGN KEY   │
│ (CASCADE delete)                                │
└────────────────┬────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────┐
│ SQLite DELETE da lista em "listas"              │
└────────────────┬────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────┐
│ HistoryScreen mostra compra em histórico        │
└─────────────────────────────────────────────────┘
```

---

### Fluxo B: Compartilhamento (Usuário A)
```
┌──────────────────────────────────────────────┐
│ HomeScreen: Usuário A clica "Compartilhar"   │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ compartilharLista() insere em "listas_cloud" │
│ (salva localmente)                           │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ compartilharListaNaCloud() INSERT Supabase   │
│ await supabase                               │
│   .from('listas_compartilhadas')             │
│   .insert({...})                             │
│                                              │
│ Envia para cloud via HTTP/REST               │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ Supabase RLS valida: usuario_id = auth.uid() │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ INSERT em listas_compartilhadas (Supabase)   │
│ Lista agora visível para OUTROS usuários     │
└──────────────────────────────────────────────┘
```

---

### Fluxo C: Recebimento (Usuário B)
```
┌──────────────────────────────────────────────┐
│ ReceivedListsScreen: Usuário B abre tela     │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ buscarListasCompartilhadasNuvem() executa    │
│ SELECT * FROM listas_compartilhadas          │
│ WHERE usuario_id != auth.uid()               │
│ ORDER BY data_compartilhamento DESC          │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ HTTP/REST request para Supabase              │
│ (via supabase_flutter package)               │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ Supabase RLS valida: usuario_id != auth.uid()│
│ (Retorna apenas listas de OUTROS)            │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ Supabase retorna List<Map> JSON              │
│ ReceivedListsScreen exibe na ListView        │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ Usuário B clica "Baixar"                     │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ fazerDownloadLista() insere em "listas_cloud"│
│ (cria cópia local do snapshot)               │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ Lista agora disponível offline para Usuário B│
│ (aparece em sua visualização local)          │
└──────────────────────────────────────────────┘
```

---

### Fluxo D: Deleção (Usuário A)
```
┌──────────────────────────────────────────────┐
│ HomeScreen: Usuário A clica "Deletar"        │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ removerListaDaNuvem(id) executa DELETE       │
│ await supabase                               │
│   .from('listas_compartilhadas')             │
│   .delete()                                  │
│   .eq('id', id)                              │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ HTTP DELETE request para Supabase            │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ Supabase RLS valida: criador_id = auth.uid() │
│ (Apenas criador consegue deletar)            │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ DELETE de "listas_compartilhadas" (Supabase) │
└────────────────┬─────────────────────────────┘
                 ↓
┌──────────────────────────────────────────────┐
│ Usuário B: próxima vez que            │
│ buscarListasCompartilhadasNuvem() é chamado, │
│ lista não aparece (foi deletada)             │
└──────────────────────────────────────────────┘
```

---

## 🔗 Chamadas de Método por Tela

```
┌─────────────────────────────────────────────────────────────┐
│ ListScreen                                                  │
│ └─ Após criar lista: insere em "listas" (via não visible)   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ HomeScreen                                                  │
│ ├─ Compartilhar: compartilharLista() + compartilharListaNa... │
│ └─ Finalizar: adicionarHistorico()                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ HistoryScreen                                               │
│ └─ Carregar: listarHistorico()                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ HistoryDetailScreen                                         │
│ └─ Recebe produtos_json (jsonDecode para exibir)            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ExpensesScreen                                              │
│ └─ Calcular: listarHistorico() → soma por categoria         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ReceivedListsScreen                                         │
│ ├─ Carregar: buscarListasCompartilhadasNuvem()              │
│ ├─ Baixar: fazerDownloadLista()                             │
│ └─ Deletar: removerListaDaNuvem()                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ CloudScreen                                                 │
│ ├─ Listar own: (acesso não visible ao histórico)            │
│ └─ Sincronizar: compartilharListaNaCloud()                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Relacionamentos e Integridade Referencial

```
LISTAS (1)
   │
   ├─── (1..N) ──→ PRODUTOS
   │              (CASCADE delete)
   │
   └─── (1..N) ──→ HISTÓRICO
                  (SET NULL delete)

LISTAS_CLOUD (1)
   │
   └─── (1..N) ──→ LISTAS
                  (CASCADE delete)
```

---

## 🔐 Autenticação e Autorização

```
┌─────────────────────────────────────────────┐
│ Supabase Auth (JWT Token)                   │
└────────────┬────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│ Quando usuário faz request:                 │
│ Authorization: Bearer {JWT_TOKEN}           │
└────────────┬────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│ Supabase extrai auth.uid() do token         │
│ RLS policies validam contra uid             │
│                                             │
│ Exemplo:                                    │
│ WHERE usuario_id = auth.uid()               │
│ WHERE usuario_id != auth.uid()              │
│ WHERE criador_id = auth.uid()               │
└─────────────────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│ Request aprovado ou rejeitado               │
│ (permission denied, row not found, etc)     │
└─────────────────────────────────────────────┘
```

---

## 🎯 Resumo Visual

| Componente | Tipo | Onde | Sincroniza |
|-----------|------|------|-----------|
| **listas** | SQLite Tabela | Local | - |
| **produtos** | SQLite Tabela | Local | - |
| **histórico** | SQLite Tabela | Local | - (snapshot) |
| **listas_cloud** | SQLite Tabela | Local | ← Supabase |
| **listas_compartilhadas** | PostgreSQL Tabela | Supabase | ← Local |

---

**Criado**: 2026-03-17  
**Versão do Banco**: 2.0  
**Status**: Totalmente Documentado
