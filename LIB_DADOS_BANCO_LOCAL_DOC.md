# Documentação: banco_local.dart

## 📋 Visão Geral

Arquivo central que gerencia **toda persistência de dados** do HardList:
- Base de dados SQLite local
- Sincronização com Supabase (cloud)
- Cache de listas compartilhadas

**Localização**: `lib/dados/banco_local.dart`

---

## 🏗️ Arquitetura

### Padrão de Design
- **Singleton**: Uma única instância durante toda sessão do app
- **Lazy Loading**: Banco criado apenas no primeiro acesso
- **Static Methods**: Todos métodos são estáticos (não precisa instanciar a classe)

```dart
// Uso típico
final db = await BancoLocal.bancoDeDados;
await db.query('listas');

// Ou através de métodos helper
final historico = await BancoLocal.listarHistorico();
```

---

## 📊 Estrutura de Dados

### 4 Tabelas SQLite

#### 1️⃣ **listas** - Listas de Compras
```sql
CREATE TABLE listas (
  id TEXT PRIMARY KEY,
  nome TEXT
)
```
- Listas criadas pelo usuário
- Exemplo: "Supermercado", "Padaria", "Farmácia"

---

#### 2️⃣ **produtos** - Produtos em Listas
```sql
CREATE TABLE produtos (
  id TEXT PRIMARY KEY,
  lista_id TEXT,                    -- FK para listas.id
  nome TEXT,
  categoria TEXT,
  quantidade TEXT,
  preco REAL,
  caminho_foto_local TEXT,          -- null ou path local (removido de assets)
  comprado INTEGER DEFAULT 0,       -- 0=não, 1=sim
  FOREIGN KEY (lista_id) REFERENCES listas(id) ON DELETE CASCADE
)
```
- Produtos adicionados às listas
- Status de compra (checkbox)
- Vem do `CatalogoLocal` (100+ produtos pré-carregados)

---

#### 3️⃣ **historico** - Histórico de Compras Finalizadas
```sql
CREATE TABLE historico (
  id TEXT PRIMARY KEY,
  lista_id TEXT,                    -- FK para listas.id
  nome TEXT,                        -- Nome da lista no momento
  data TEXT,                        -- ISO8601 timestamp
  valor REAL,                       -- Total gasto
  produtos_json TEXT,              -- JSON array com snapshot dos produtos
  FOREIGN KEY (lista_id) REFERENCES listas(id) ON DELETE SET NULL
)
```

**Exemplo `produtos_json`**:
```json
[
  {
    "nome": "Leite Integral",
    "quantidade": "2",
    "preco": 5.50,
    "subtotal": 11.00
  },
  {
    "nome": "Pão Francês",
    "quantidade": "1",
    "preco": 3.00,
    "subtotal": 3.00
  }
]
```

**Usado por**:
- HistoryScreen: Lista todas as compras
- HistoryDetailScreen: Mostra produtos com valores
- ExpensesScreen: Calcula gastos por categoria

---

#### 4️⃣ **listas_cloud** - Cache de Listas Compartilhadas
```sql
CREATE TABLE listas_cloud (
  id TEXT PRIMARY KEY,
  lista_id TEXT,
  nome TEXT,
  data_compartilhamento TEXT,      -- ISO8601 timestamp
  usuario_id TEXT,                 -- ID de quem compartilhou
  produtos_json TEXT,              -- JSON com produtos
  FOREIGN KEY (lista_id) REFERENCES listas(id) ON DELETE CASCADE
)
```

- Cache **local** de listas **baixadas** de outros usuários
- Sincroniza com tabela Supabase `listas_compartilhadas`
- Leitura/visualização apenas

---

## 🔄 Fluxos de Dados

### Fluxo 1: Compra Local
```
Usuário cria lista
  ↓
Adiciona produtos (via CatalogoLocal)
  ↓
Marca como comprado (checkbox)
  ↓
Clica "Finalizar Compra"
  ↓
adicionarHistorico() salva snapshot em historico table
  ↓
Lista removida de "listas" e produtos deletados (cascade)
  ↓
Aparece em "Histórico" com totais
```

### Fluxo 2: Compartilhamento (Usuário A)
```
Usuário A compartilha lista
  ↓
compartilharLista() salvaguarda em listas_cloud (local)
  ↓
compartilharListaNaCloud() envia INSERT para Supabase
  ↓
Registro inserido em "listas_compartilhadas" (Supabase)
  ↓
Disponível para outros usuários verem
```

### Fluxo 3: Recebimento (Usuário B)
```
Usuário B abre "Listas Recebidas"
  ↓
buscarListasCompartilhadasNuvem() busca Supabase
  ↓
WHERE usuario_id != meu_id (só vê de outros)
  ↓
Exibe na ReceivedListsScreen
  ↓
Usuário B clica "Baixar"
  ↓
fazerDownloadLista() insere em listas_cloud (local)
  ↓
Lista agora aparece localmente (apenas leitura)
```

### Fluxo 4: Sincronização Delete
```
Usuário A deleta lista compartilhada
  ↓
removerListaDaNuvem() executa DELETE em Supabase
  ↓
Registro removido de "listas_compartilhadas"
  ↓
Usuário B vê que lista desapareceu em "Listas Recebidas"
```

---

## 🔧 Métodos Principais

### SEÇÃO 1: Histórico de Compras

#### `adicionarHistorico()`
**Insere** compra finalizada no histórico
```dart
await BancoLocal.adicionarHistorico(
  id: const Uuid().v4(),
  listaId: widget.listaId,
  nome: widget.listaNome,
  data: DateTime.now().toIso8601String(),
  valor: totalGasto,
  produtosJson: jsonEncode(produtos),
);
```

#### `listarHistorico()`
**Obtém** todas as compras ordenadas por data
```dart
final historico = await BancoLocal.listarHistorico();
// Retorna List<Map> com campo 'produtos_json' que precisa jsonDecode()
```

---

### SEÇÃO 2: Listas Compartilhadas (Cache Local)

#### `compartilharLista()`
**Salva** lista no cache local (sem sincronizar Supabase)

#### `listarListasCloud()`
**Obtém** todas as listas no cache cloud

#### `removerListaCloud()`
**Remove** lista do cache local

#### `atualizarListaCloud()`
**Atualiza** lista no cache local

---

### SEÇÃO 3: Inicialização

#### `bancoDeDados` (getter)
**Fornece acesso** ao banco (lazy loading)

#### `_inicializarBanco()`
**Setup inicial** do SQLite com FFI (desktop)

#### `_criarTabelas()`
**Cria esquema** na primeira instalação

---

### SEÇÃO 4: Cloud Sync (Supabase)

#### `compartilharListaNaCloud()`
**INSERT** na tabela Supabase `listas_compartilhadas`
- Torna lista visível para outros usuários
- Chamado após `compartilharLista()` local

#### `buscarListasCompartilhadasNuvem()`
**SELECT** listas de outros usuários do Supabase
- Filtra `.neq('usuario_id', meu_id)`
- Retorna [] se erro (não lança exception)
- Usado por ReceivedListsScreen

#### `fazerDownloadLista()`
**INSERT** em listas_cloud (local) após download
- Torna lista disponível offline
- Cria snapshot local do momento

#### `atualizarListaNaCloud()`
**UPDATE** lista em Supabase
- Modifica nome/produtos
- Apenas criador consegue

#### `removerListaDaNuvem()`
**DELETE** lista de Supabase
- RLS policy valida permissão
- Apenas criador consegue deletar

---

## 🔐 Segurança (RLS Policies Supabase)

Tabela `listas_compartilhadas` tem 4 políticas:

| Operação | Condição | Resultado |
|----------|----------|-----------|
| **SELECT** | `usuario_id != auth.uid()` | Vê apenas listas de outros |
| **INSERT** | `usuario_id = auth.uid()` | Pode compartilhar suas próprias |
| **UPDATE** | `criador_id = auth.uid()` | Apenas criador modifica |
| **DELETE** | `criador_id = auth.uid()` | Apenas criador deleta |

---

## 📱 Versões do Banco

### Versão 1 (Original)
- Tabelas: listas, produtos, listas_cloud

### Versão 2 (Atual)
- **Adição**: Tabela `historico`
- Migration em `onUpgrade`: Cria tabela se `oldVersion < 2`
- Retroativa: Usuários com BD v1 são migrados automaticamente

---

## 🐛 Debugging

### Logs de Erro
Todos métodos Supabase têm `print()` para debugging:
```dart
print('Erro ao compartilhar lista na cloud: $e');
print('Erro ao buscar listas compartilhadas: $e');
```

### Erro Comum: "tabela listas_compartilhadas não existe"
**Causa**: Supabase não foi configurado
**Solução**: Execute migração SQL em `SUPABASE_QUICK_START.md`

### Erro: "permission denied"
**Causa**: RLS policy rejected
**Solução**: Verifique se usuário está autenticado

---

## 📚 Referências no Código

**Arquivo usa em**:
- `lib/screens/home_screen.dart` - compartilhamento
- `lib/screens/history_screen.dart` - histórico
- `lib/screens/history_detail_screen.dart` - detalhes
- `lib/screens/expenses_screen.dart` - cálculos
- `lib/screens/received_lists_screen.dart` - listas recebidas
- `lib/screens/cloud_screen.dart` - gerenciamento cloud

---

## 🎯 Resumo

| Necessidade | Método | Tabela |
|-----------|--------|--------|
| Criar lista | (em list_screen.dart) | listas |
| Adicionar produto | (em home_screen.dart) | produtos |
| Checkout | `adicionarHistorico()` | historico |
| Ver histórico | `listarHistorico()` | historico |
| Compartilhar | `compartilharListaNaCloud()` | Supabase |
| Ver recebidas | `buscarListasCompartilhadasNuvem()` | Supabase |
| Baixar lista | `fazerDownloadLista()` | listas_cloud |
| Deletar compartilhada | `removerListaDaNuvem()` | Supabase |

---

**Status**: ✅ Totalmente documentado  
**Versão**: 2.0  
**Última atualização**: 2024 - Documentação Completa
