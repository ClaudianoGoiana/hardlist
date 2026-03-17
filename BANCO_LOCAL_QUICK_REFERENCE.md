# 📖 Guia Rápido: Referência de Métodos banco_local.dart

## 🎯 Acesso ao Banco

```dart
// Obter instância do banco (lazy loading)
final db = await BancoLocal.bancoDeDados;

// Executar query diretamente
final resultado = await db.query('listas');
```

---

## 📝 SEÇÃO 1: Histórico de Compras

### `adicionarHistorico()` - Registrar compra finalizada
```dart
Future<void> adicionarHistorico({
  required String id,              // Uuid: const Uuid().v4()
  required String listaId,         // ID da lista comprada
  required String nome,            // Nome da lista
  required String data,            // DateTime.now().toIso8601String()
  required double valor,           // Valor total calculado
  required String produtosJson,    // jsonEncode(produtos)
})
```

**Quando usar**: Usuário finaliza compra em HomeScreen
```dart
await BancoLocal.adicionarHistorico(
  id: const Uuid().v4(),
  listaId: widget.listaId,
  nome: widget.listaNome,
  data: DateTime.now().toIso8601String(),
  valor: _calcularTotal(),
  produtosJson: jsonEncode(_produtos),
);
```

---

### `listarHistorico()` - Obter histórico completo
```dart
Future<List<Map<String, dynamic>>> listarHistorico()
```

**Retorna**: Lista de compras ordenada por data (mais recente primeiro)

**Estrutura retornada**:
```dart
[
  {
    'id': 'uuid-123',
    'lista_id': 'lista-456',
    'nome': 'Supermercado',
    'data': '2026-03-17T15:30:00.000Z',
    'valor': 125.50,
    'produtos_json': '[{"nome":"Leite",...}]'
  }
]
```

**Quando usar**: HistoryScreen carrega histórico ao abrir
```dart
final historico = await BancoLocal.listarHistorico();

for (var compra in historico) {
  final produtos = jsonDecode(compra['produtos_json']);
  print('${compra["nome"]}: R\$ ${compra["valor"]}');
}
```

---

## 🔗 SEÇÃO 2: Cache Local de Listas Compartilhadas

### `compartilharLista()` - Salvar localmente
```dart
Future<void> compartilharLista({
  required String id,              // Uuid
  required String listaId,         // Referência
  required String nome,            // Nome da lista
  required String usuarioId,       // ID de quem compartilhou
  required String produtosJson,    // JSON dos produtos
})
```

**Quando usar**: Salvar cópia local (passo 1)
```dart
await BancoLocal.compartilharLista(
  id: const Uuid().v4(),
  listaId: widget.listaId,
  nome: widget.listaNome,
  usuarioId: usuario.id,
  produtosJson: jsonEncode(_produtos),
);
```

---

### `listarListasCloud()` - Listar cache compartilhado
```dart
Future<List<Map<String, dynamic>>> listarListasCloud()
```

**Retorna**: Todas as listas no cache (ordenadas por data)

**Quando usar**: CloudScreen exibe listas baixadas
```dart
final listasCloud = await BancoLocal.listarListasCloud();
```

---

### `removerListaCloud()` - Deletar do cache local
```dart
Future<void> removerListaCloud(
  String id,           // UUID da lista
  String usuarioId,    // Validação
)
```

**Quando usar**: Usuário remove lista baixada
```dart
await BancoLocal.removerListaCloud(lista['id'], usuario.id);
```

---

### `atualizarListaCloud()` - Modificar cache
```dart
Future<void> atualizarListaCloud(
  String id,              // UUID
  String nome,            // Novo nome
  String produtosJson,    // Novos produtos
  String usuarioId,       // Validação
)
```

**Quando usar**: Sincronizar mudanças localmente
```dart
await BancoLocal.atualizarListaCloud(
  lista['id'],
  'Novo Nome',
  jsonEncode(novosProdutos),
  usuario.id
);
```

---

## ☁️ SEÇÃO 3: Cloud Sync (Supabase)

### `compartilharListaNaCloud()` - Publicar para nuvem
```dart
Future<void> compartilharListaNaCloud({
  required String id,              // Uuid
  required String listaId,         // Referência
  required String nome,            // Nome
  required String usuarioId,       // auth.currentUser.id
  required String produtosJson,    // JSON produtos
})
```

**Quando usar**: Passo 2 após compartilharLista() (HomeScreen)
```dart
try {
  final usuario = Supabase.instance.client.auth.currentUser;
  
  await BancoLocal.compartilharListaNaCloud(
    id: const Uuid().v4(),
    listaId: widget.listaId,
    nome: widget.listaNome,
    usuarioId: usuario.id,
    produtosJson: jsonEncode(_produtos),
  );
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Lista compartilhada!'))
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e'))
  );
}
```

---

### `buscarListasCompartilhadasNuvem()` - Buscar nuvem
```dart
Future<List<Map<String, dynamic>>> buscarListasCompartilhadasNuvem()
```

**Retorna**: Lista de listas de OUTROS usuários

**Estrutura**:
```dart
[
  {
    'id': 'uuid-abc',
    'lista_id': 'ref-xyz',
    'nome': 'Supermercado',
    'usuario_id': 'other-user-uuid',
    'criador_id': 'other-user-uuid',
    'produtos_json': '[...]',
    'data_compartilhamento': '2026-03-17T...'
  }
]
```

**Erro handling**: Retorna [] se erro (não lança exception)

**Quando usar**: ReceivedListsScreen carrega ao abrir
```dart
setState(() {
  _listasCompartilhadasFuture = BancoLocal.buscarListasCompartilhadasNuvem();
});

// Em widget:
FutureBuilder(
  future: _listasCompartilhadasFuture,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final listas = snapshot.data ?? [];
    return ListView.builder(
      itemCount: listas.length,
      itemBuilder: (context, index) {
        final lista = listas[index];
        return ListTile(
          title: Text(lista['nome']),
          subtitle: Text('De: ${lista["usuario_id"]}'),
        );
      },
    );
  },
)
```

---

### `fazerDownloadLista()` - Baixar para local
```dart
Future<void> fazerDownloadLista({
  required String id,
  required String listaId,
  required String nome,
  required String usuarioId,
  required String produtosJson,
})
```

**Quando usar**: Usuário clica "Baixar" em ReceivedListsScreen
```dart
try {
  await BancoLocal.fazerDownloadLista(
    id: lista['id'],
    listaId: lista['lista_id'],
    nome: lista['nome'],
    usuarioId: lista['usuario_id'],
    produtosJson: lista['produtos_json'],
  );
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Lista baixada com sucesso!'))
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro ao baixar: $e'))
  );
}
```

---

### `atualizarListaNaCloud()` - Sincronizar mudanças
```dart
Future<void> atualizarListaNaCloud({
  required String id,
  required String nome,
  required String produtosJson,
})
```

**Quando usar**: Criador modifica lista após compartilhar
```dart
try {
  await BancoLocal.atualizarListaNaCloud(
    id: lista['id'],
    nome: 'Novo Nome',
    produtosJson: jsonEncode(novosProdutos),
  );
} catch (e) {
  print('Erro ao atualizar: $e');
}
```

---

### `removerListaDaNuvem()` - Deletar nuvem
```dart
Future<void> removerListaDaNuvem(String id)
```

**Quando usar**: Criador remove compartilhamento
```dart
try {
  await BancoLocal.removerListaDaNuvem(lista['id']);
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Lista removida'))
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e'))
  );
}
```

---

## 🔧 SEÇÃO 4: Setup (Interno)

### `bancoDeDados` (Getter)
```dart
static Future<Database> get bancoDeDados
```

**Acesso automático ao inicializar a classe**
```dart
final db = await BancoLocal.bancoDeDados;
```

---

### `_inicializarBanco()` [Privado]
Chamado automaticamente por `bancoDeDados` getter.
- Setup FFI para desktop
- Locação do arquivo
- Migração de versão

---

### `_criarTabelas()` [Privado]
Chamado automaticamente em `onCreate`.
- Cria schema do banco
- Cria 4 tabelas (listas, produtos, historico, listas_cloud)

---

## 🐛 Troubleshooting

### Erro: "no such table: listas_compartilhadas"
```
Causa: Você esqueceu de configurar Supabase
Solução: Execute SUPABASE_QUICK_START.md
```

### Erro: "permission denied"
```
Causa: RLS policy rejeitou acesso
Solução: Verifique se usuário está autenticado
        e se usuario_id corresponde ao auth.uid()
```

### Erro: "FOREIGN KEY constraint failed"
```
Causa: Tentou inserir lista_id que não existe
Solução: Crie lista antes de adicionar produtos
```

### Histórico vazio
```
Causa: Nenhuma compra foi finalizada
Solução: Complete uma compra usando adicionarHistorico()
```

### Listas compartilhadas não aparecem
```
Causa 1: Tabela Supabase não foi criada
        → Execute migração SQL

Causa 2: Usuário não está autenticado
        → Login primeiro

Causa 3: Nenhuma lista foi compartilhada
        → Outro usuário deve compartilhar
```

---

## 📊 Tabela Rápida: Quando Usar Cada Método

| Situação | Método | Local |
|----------|--------|-------|
| Usuário compra | `adicionarHistorico()` | HomeScreen |
| Ver compras passadas | `listarHistorico()` | HistoryScreen |
| Compartilhar lista | `compartilharLista()` + `compartilharListaNaCloud()` | HomeScreen |
| Ver listas recebidas | `buscarListasCompartilhadasNuvem()` | ReceivedListsScreen |
| Baixar lista recebida | `fazerDownloadLista()` | ReceivedListsScreen |
| Deletar compartilhamento | `removerListaDaNuvem()` | ReceivedListsScreen |
| Calcular despesas | `listarHistorico()` | ExpensesScreen |

---

## 🎓 Padrões de Uso Completos

### Padrão 1: Checkout
```dart
// HomeScreen._finalizarCompra()
try {
  // Calcula total
  double total = _produtos.fold(0, (sum, p) => 
    sum + (p['preco'] * double.parse(p['quantidade'])));
  
  // Salva no histórico
  await BancoLocal.adicionarHistorico(
    id: const Uuid().v4(),
    listaId: widget.listaId,
    nome: widget.listaNome,
    data: DateTime.now().toIso8601String(),
    valor: total,
    produtosJson: jsonEncode(_produtos),
  );
  
  // Navega para histórico
  Navigator.pop(context, true);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e'))
  );
}
```

### Padrão 2: Compartilhamento
```dart
// HomeScreen._compartilharLista()
final usuario = Supabase.instance.client.auth.currentUser;
final id = const Uuid().v4();

try {
  // 1. Salva localmente
  await BancoLocal.compartilharLista(
    id: id,
    listaId: widget.listaId,
    nome: widget.listaNome,
    usuarioId: usuario.id,
    produtosJson: jsonEncode(_produtos),
  );
  
  // 2. Sincroniza com cloud
  await BancoLocal.compartilharListaNaCloud(
    id: id,
    listaId: widget.listaId,
    nome: widget.listaNome,
    usuarioId: usuario.id,
    produtosJson: jsonEncode(_produtos),
  );
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Lista compartilhada!'))
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e'))
  );
}
```

### Padrão 3: Receber Lista
```dart
// ReceivedListsScreen
@override
void initState() {
  super.initState();
  _listasCompartilhadasFuture = 
    BancoLocal.buscarListasCompartilhadasNuvem();
}

void _fazerDownload(Map lista) async {
  try {
    await BancoLocal.fazerDownloadLista(
      id: lista['id'],
      listaId: lista['lista_id'],
      nome: lista['nome'],
      usuarioId: lista['usuario_id'],
      produtosJson: lista['produtos_json'],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Baixado!'))
    );
    
    setState(() {
      _listasCompartilhadasFuture = 
        BancoLocal.buscarListasCompartilhadasNuvem();
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e'))
    );
  }
}
```

---

**Última atualização**: 2026-03-17  
**Versão**: 2.0  
**Mantido por**: Desenvolvimento HardList
