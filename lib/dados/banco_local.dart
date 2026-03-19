import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class BancoLocal {
  // Instancia unica do banco local (lazy).
  static Database? _bd;

  // Acesso central ao banco SQLite.
  static Future<Database> get bancoDeDados async {
    if (_bd != null) return _bd!;
    _bd = await _inicializarBanco();
    return _bd!;
  }

  // BLOCO 1: Historico de compras (salvar e listar compras finalizadas).
  static Future<void> adicionarHistorico({
    required String id,
    required String listaId,
    required String nome,
    required String data,
    required double valor,
    required String produtosJson,
  }) async {
    final db = await bancoDeDados;
    await db.insert('historico', {
      'id': id,
      'lista_id': listaId,
      'nome': nome,
      'data': data,
      'valor': valor,
      'produtos_json': produtosJson,
    });
  }

  static Future<List<Map<String, dynamic>>> listarHistorico() async {
    final db = await bancoDeDados;
    return await db.query('historico', orderBy: 'data DESC');
  }

  // BLOCO 2: Cache local de listas compartilhadas (listas_cloud).
  static Future<void> compartilharLista({
    required String id,
    required String listaId,
    required String nome,
    required String usuarioId,
    required String produtosJson,
  }) async {
    final db = await bancoDeDados;
    await db.insert('listas_cloud', {
      'id': id,
      'lista_id': listaId,
      'nome': nome,
      'data_compartilhamento': DateTime.now().toIso8601String(),
      'usuario_id': usuarioId,
      'produtos_json': produtosJson,
    });
  }

  static Future<List<Map<String, dynamic>>> listarListasCloud() async {
    final db = await bancoDeDados;
    return await db.query('listas_cloud', orderBy: 'data_compartilhamento DESC');
  }

  static Future<List<Map<String, dynamic>>> listarListasRecebidasLocal() async {
    final db = await bancoDeDados;
    final usuarioAtualId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return await db.query(
      'listas_cloud',
      where: 'id LIKE ? AND usuario_id = ?',
      whereArgs: ['dl_%', usuarioAtualId],
      orderBy: 'data_compartilhamento DESC',
    );
  }

  static Future<void> removerListaCloud(String id, String usuarioId) async {
    final db = await bancoDeDados;
    await db.delete('listas_cloud', where: 'id = ? AND usuario_id = ?', whereArgs: [id, usuarioId]);
  }

  static Future<void> atualizarListaCloud(String id, String nome, String produtosJson, String usuarioId) async {
    final db = await bancoDeDados;
    await db.update(
      'listas_cloud',
      {
        'nome': nome,
        'produtos_json': produtosJson,
        'data_compartilhamento': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND usuario_id = ?',
      whereArgs: [id, usuarioId],
    );
  }

  // BLOCO 3: Inicializacao e migracao do SQLite.
  static Future<Database> _inicializarBanco() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final caminhoApp = await getDatabasesPath();
    final caminhoBd = join(caminhoApp, 'hardlist_offline.db');

    final db = await openDatabase(
      caminhoBd,
      version: 4,
      onCreate: (Database db, int version) async {
        await _criarTabelas(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE historico (
              id TEXT PRIMARY KEY,
              lista_id TEXT,
              nome TEXT,
              data TEXT,
              valor REAL,
              produtos_json TEXT,
              FOREIGN KEY (lista_id) REFERENCES listas (id) ON DELETE SET NULL
            )
          ''');
        }

        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE listas_cloud ADD COLUMN criador_id TEXT');
          } catch (_) {
            // Coluna pode já existir em algumas instalações.
          }
        }

        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE listas_cloud ADD COLUMN criador_nome TEXT');
          } catch (_) {
            // Coluna pode já existir em algumas instalações.
          }
        }
      },
    );

    await _garantirSchemaListasCloud(db);
    return db;
  }

  static Future<void> _garantirSchemaListasCloud(Database db) async {
    try {
      final colunas = await db.rawQuery("PRAGMA table_info(listas_cloud)");
      final possuiCriadorId = colunas.any((c) => c['name']?.toString() == 'criador_id');
      final possuiCriadorNome = colunas.any((c) => c['name']?.toString() == 'criador_nome');
      if (!possuiCriadorId) {
        await db.execute('ALTER TABLE listas_cloud ADD COLUMN criador_id TEXT');
      }
      if (!possuiCriadorNome) {
        await db.execute('ALTER TABLE listas_cloud ADD COLUMN criador_nome TEXT');
      }
    } catch (_) {
      // Melhor esforço: se falhar, o fluxo principal segue e tenta novamente no próximo acesso.
    }
  }

  // Cria o schema base: listas, produtos, historico e listas_cloud.
  static Future<void> _criarTabelas(Database db) async {
    await db.execute('''
      CREATE TABLE listas (
        id TEXT PRIMARY KEY,
        nome TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE produtos (
        id TEXT PRIMARY KEY,
        lista_id TEXT,
        nome TEXT,
        categoria TEXT,
        quantidade TEXT,
        preco REAL,
        caminho_foto_local TEXT,
        comprado INTEGER DEFAULT 0,
        FOREIGN KEY (lista_id) REFERENCES listas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE historico (
        id TEXT PRIMARY KEY,
        lista_id TEXT,
        nome TEXT,
        data TEXT,
        valor REAL,
        produtos_json TEXT,
        FOREIGN KEY (lista_id) REFERENCES listas (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE listas_cloud (
        id TEXT PRIMARY KEY,
        lista_id TEXT,
        nome TEXT,
        data_compartilhamento TEXT,
        usuario_id TEXT,
        criador_id TEXT,
        criador_nome TEXT,
        produtos_json TEXT,
        FOREIGN KEY (lista_id) REFERENCES listas (id) ON DELETE CASCADE
      )
    ''');
  }

  // BLOCO 4: Sincronizacao com Supabase (listas).
  static Future<void> compartilharListaNaCloud({
    required String id,
    required String listaId,
    required String nome,
    required String usuarioId,
    required String produtosJson,
    required bool publica,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final usuarioAtual = supabase.auth.currentUser;
      final criadorNome = (usuarioAtual?.userMetadata?['name']?.toString().trim().isNotEmpty ?? false)
          ? usuarioAtual!.userMetadata!['name'].toString().trim()
          : (usuarioAtual?.email?.split('@').first ?? 'Usuário');

      final payload = {
        'id': listaId,
        'lista_id': listaId,
        'nome': nome,
        'usuario_id': usuarioId,
        'produtos_json': produtosJson,
        'data_compartilhamento': DateTime.now().toIso8601String(),
        'criador_id': usuarioId,
        'criador_nome': criadorNome,
        'publica': publica,
      };

      try {
        await supabase.from('listas').upsert(payload);
      } catch (_) {
        // Fallback para schemas antigos na nuvem sem a coluna criador_nome.
        final payloadSemNome = Map<String, dynamic>.from(payload)..remove('criador_nome');
        await supabase.from('listas').upsert(payloadSemNome);
      }
    } catch (e) {
      print('Erro ao compartilhar lista na cloud: $e');
      rethrow;
    }
  }

  static List<Map<String, dynamic>> _normalizarListasNuvem(dynamic response) {
    return List<Map<String, dynamic>>.from(response).map((lista) {
      final normalizada = Map<String, dynamic>.from(lista);
      normalizada['lista_id'] ??= normalizada['id'];
      normalizada['produtos_json'] ??= '[]';
      normalizada['data_compartilhamento'] ??= '';
      normalizada['criador_id'] ??= normalizada['usuario_id'] ?? '';
      normalizada['criador_nome'] ??= '';
      normalizada['publica'] ??= true;
      return normalizada;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> buscarListasCompartilhadasNuvem() async {
    try {
      final supabase = Supabase.instance.client;
      final usuarioAtual = supabase.auth.currentUser;

      if (usuarioAtual == null) return [];

      final response = await supabase
          .from('listas')
          .select()
          .eq('publica', true)
          .neq('usuario_id', usuarioAtual.id)
          .order('data_compartilhamento', ascending: false);

      return _normalizarListasNuvem(response);
    } catch (e) {
      print('Erro ao buscar listas compartilhadas: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> listarListasNaNuvemDoUsuario() async {
    try {
      final supabase = Supabase.instance.client;
      final usuarioAtual = supabase.auth.currentUser;

      if (usuarioAtual == null) return [];

      final response = await supabase
          .from('listas')
          .select()
          .or('usuario_id.eq.${usuarioAtual.id},criador_id.eq.${usuarioAtual.id}')
          .order('data_compartilhamento', ascending: false);

      return _normalizarListasNuvem(response);
    } catch (e) {
      print('Erro ao listar listas na nuvem: $e');
      return [];
    }
  }

  static Future<void> fazerDownloadLista({
    required String id,
    required String listaId,
    required String nome,
    required String usuarioId,
    required String produtosJson,
    String? criadorNome,
  }) async {
    try {
      final db = await bancoDeDados;
      await _garantirSchemaListasCloud(db);
      final usuarioAtualId = Supabase.instance.client.auth.currentUser?.id ?? '';

      if (usuarioAtualId.isEmpty) {
        throw Exception('Usuário não autenticado. Não é possível baixar a lista.');
      }

      final jaImportada = await db.query(
        'listas_cloud',
        where: 'lista_id = ? AND usuario_id = ? AND id LIKE ?',
        whereArgs: [listaId, usuarioAtualId, 'dl_%'],
        limit: 1,
      );

      if (jaImportada.isNotEmpty) {
        throw Exception('Esta lista já foi baixada.');
      }

      // Importa como uma NOVA lista local do usuário atual.
      final novoListaId = const Uuid().v4();
      final nomeImportado = nome;

      await db.insert('listas', {
        'id': novoListaId,
        'nome': nomeImportado,
      });

      List<dynamic> produtos = [];
      try {
        produtos = jsonDecode(produtosJson) as List<dynamic>;
      } catch (e) {
        print('Aviso: Erro ao decodificar produtos JSON: $e');
        produtos = [];
      }

      for (int i = 0; i < produtos.length; i++) {
        final p = (produtos[i] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        final preco = (p['preco'] as num?)?.toDouble() ?? 0.0;

        try {
          await db.insert('produtos', {
            'id': const Uuid().v4(),
            'lista_id': novoListaId,
            'nome': p['nome']?.toString() ?? 'Produto',
            'categoria': p['categoria']?.toString() ?? 'Outros',
            'quantidade': p['quantidade']?.toString() ?? '1',
            'preco': preco,
            'caminho_foto_local': p['caminho_foto_local']?.toString(),
            'comprado': 0,
          });
        } catch (e) {
          print('Erro ao inserir produto $i: $e');
          rethrow;
        }
      }

      // Salva no histórico local de recebidas para aparecer em "Listas recebidas".
      try {
        await db.insert('listas_cloud', {
          'id': 'dl_${const Uuid().v4()}',
          'lista_id': listaId,
          'nome': nome,
          'data_compartilhamento': DateTime.now().toIso8601String(),
          // Dono local do download (quem recebeu)
          'usuario_id': usuarioAtualId,
          // Dono original da lista na nuvem (quem compartilhou)
          'criador_id': usuarioId,
          'criador_nome': (criadorNome ?? '').trim(),
          'produtos_json': produtosJson,
        });
      } catch (e) {
        print('Erro ao inserir na tabela listas_cloud: $e');
        rethrow;
      }
    } catch (e) {
      print('Erro geral em fazerDownloadLista: $e');
      rethrow;
    }
  }

  static Future<void> atualizarListaNaCloud({
    required String id,
    required String nome,
    required String produtosJson,
    bool? publica,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      final payload = <String, dynamic>{
        'nome': nome,
        'produtos_json': produtosJson,
        'data_compartilhamento': DateTime.now().toIso8601String(),
      };
      if (publica != null) {
        payload['publica'] = publica;
      }

      await supabase.from('listas').update(payload).eq('id', id);
    } catch (e) {
      print('Erro ao atualizar lista na cloud: $e');
      rethrow;
    }
  }

  static Future<void> removerListaDaNuvem(String id) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('listas').delete().eq('id', id);
    } catch (e) {
      print('Erro ao remover lista da cloud: $e');
      rethrow;
    }
  }
}
