// Arquivo: lib/dados/banco_local.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BancoLocal {
  // A "chave" para acessar o banco de dados
  static Database? _bd;

  // Se o banco já estiver aberto, ele usa. Se não, ele cria e abre.
  static Future<Database> get bancoDeDados async {
    if (_bd != null) return _bd!;
    _bd = await _inicializarBanco();
    return _bd!;
  }

  static Future<Database> _inicializarBanco() async {
    // Descobre onde é a pasta de cofres do celular (Android/iOS)
    String caminhoApp = await getDatabasesPath();
    String caminhoBd = join(caminhoApp, 'hardlist_offline.db');

    // Abre (ou cria) o arquivo do banco de dados
    return await openDatabase(
      caminhoBd,
      version: 1,
      // Se for a primeira vez que o app abre, ele cria as gavetas (tabelas)
      onCreate: (Database db, int version) async {
        
        // 1. GAVETA DE LISTAS
        await db.execute('''
          CREATE TABLE listas (
            id TEXT PRIMARY KEY,
            nome TEXT
          )
        ''');

        // 2. GAVETA DE PRODUTOS
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
        // Nota: O SQLite não tem "true/false" para o comprado, então usamos INTEGER (0 = falso, 1 = verdadeiro).
      },
    );
  }
}