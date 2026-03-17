import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    return await openDatabase(
      caminhoBd,
      version: 2,
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
      },
    );
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
        produtos_json TEXT,
        FOREIGN KEY (lista_id) REFERENCES listas (id) ON DELETE CASCADE
      )
    ''');
  }

  // BLOCO 4: Sincronizacao com Supabase (listas_compartilhadas).
  static Future<void> compartilharListaNaCloud({
    required String id,
    required String listaId,
    required String nome,
    required String usuarioId,
    required String produtosJson,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('listas_compartilhadas').insert({
        'id': id,
        'lista_id': listaId,
        'nome': nome,
        'usuario_id': usuarioId,
        'produtos_json': produtosJson,
        'data_compartilhamento': DateTime.now().toIso8601String(),
        'criador_id': usuarioId,
      });
    } catch (e) {
      print('Erro ao compartilhar lista na cloud: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> buscarListasCompartilhadasNuvem() async {
    try {
      final supabase = Supabase.instance.client;
      final usuarioAtual = supabase.auth.currentUser;

      if (usuarioAtual == null) return [];

      final response = await supabase
          .from('listas_compartilhadas')
          .select()
          .neq('usuario_id', usuarioAtual.id)
          .order('data_compartilhamento', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar listas compartilhadas: $e');
      return [];
    }
  }

  static Future<void> fazerDownloadLista({
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

  static Future<void> atualizarListaNaCloud({
    required String id,
    required String nome,
    required String produtosJson,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('listas_compartilhadas').update({
        'nome': nome,
        'produtos_json': produtosJson,
        'data_compartilhamento': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      print('Erro ao atualizar lista na cloud: $e');
      rethrow;
    }
  }

  static Future<void> removerListaDaNuvem(String id) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('listas_compartilhadas').delete().eq('id', id);
    } catch (e) {
      print('Erro ao remover lista da cloud: $e');
      rethrow;
    }
  }
}
