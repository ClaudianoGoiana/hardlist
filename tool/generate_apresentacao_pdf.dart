import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Container(
          width: double.infinity,
          height: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blueGrey800, width: 2),
          ),
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Spacer(),
              pw.Text(
                'APRESENTACAO DE ARQUITETURA',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Projeto HardList',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'Aplicativo inteligente para listas de compras com suporte offline e sincronizacao em nuvem.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 24),
              pw.Text('Data: 08/04/2026', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('Versao: v1.0', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 8),
              pw.Text('Equipe:', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('Claudiano Goiana', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('Jonatan Filipe', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('Tárcito Luã', style: const pw.TextStyle(fontSize: 11)),
              pw.Spacer(),
            ],
          ),
        );
      },
    ),
  );

  final sections = <_Section>[
    _Section(
      'Introducao',
      [
        'O HardList e um aplicativo Flutter para gestao de listas de compras com foco em praticidade no uso diario.',
        'A solucao combina armazenamento local (SQLite) e recursos de nuvem (Supabase) para permitir uso offline e compartilhamento.',
      ],
    ),
    _Section(
      'Finalidade',
      [
        'Apresentar a visao arquitetural do sistema HardList e os requisitos que guiam seu desenvolvimento.',
        'Consolidar base tecnica para implementacao, manutencao e evolucao do produto.',
      ],
    ),
    _Section(
      'Escopo',
      [
        'Inclui: autenticacao, gerenciamento de listas e produtos, historico de compras, visualizacao de despesas e compartilhamento de listas.',
        'Nao inclui: marketplace, pagamentos online e recomendacao por IA nesta versao.',
      ],
    ),
    _Section(
      'Definicoes, Acronimos e Abreviacoes',
      [
        'CRUD: Create, Read, Update, Delete.',
        'RLS: Row Level Security (controle de acesso por linha no banco).',
        'SDK: Software Development Kit.',
        'UI/UX: Interface e experiencia do usuario.',
      ],
    ),
    _Section(
      'Referencias',
      [
        'Flutter Documentation: https://docs.flutter.dev',
        'Supabase Documentation: https://supabase.com/docs',
        'Documentos internos do projeto (pasta documentos e supabase/migrations).',
      ],
    ),
    _Section(
      'Representacao Arquitetural',
      [
        'Arquitetura em camadas com separacao entre apresentacao (screens/widgets), dados locais (SQLite) e servicos de nuvem (Supabase).',
        'Padrao de estado com Provider para tema e controle de comportamento global da aplicacao.',
      ],
    ),
    _Section(
      'Requisitos do Sistema',
      [
        'Aplicacao mobile multiplataforma baseada em Flutter.',
        'Persistencia local para funcionamento offline e sincronizacao cloud para compartilhamento.',
      ],
    ),
    _Section(
      'Requisitos de usuario',
      [
        'Cadastrar, editar e remover listas de compras.',
        'Adicionar produtos por categoria e acompanhar progresso da compra.',
        'Visualizar historico e gastos por categoria.',
        'Compartilhar e baixar listas entre usuarios autenticados.',
      ],
    ),
    _Section(
      'Requisitos funcionais',
      [
        'RF01: Cadastro e autenticacao de usuario via Supabase.',
        'RF02: Criacao e gerenciamento de listas e produtos localmente.',
        'RF03: Registro de historico de compras com itens e valores.',
        'RF04: Geracao de visao de despesas em graficos.',
        'RF05: Compartilhamento de listas na nuvem e download por outros usuarios.',
      ],
    ),
    _Section(
      'Requisitos nao funcionais',
      [
        'RNF01: Tempo de resposta adequado para navegacao e operacoes comuns.',
        'RNF02: Usabilidade com interface clara em tema claro/escuro.',
        'RNF03: Seguranca de dados com politicas de acesso no Supabase (RLS).',
        'RNF04: Portabilidade para Android, iOS, Windows, Linux e Web.',
      ],
    ),
    _Section(
      'Requisitos e restricoes arquiteturais',
      [
        'Uso obrigatorio de Flutter (frontend), SQLite (offline) e Supabase (backend cloud).',
        'Variaveis sensiveis (URL e anon key) devem ser injetadas por --dart-define.',
        'Integracao cloud depende da existencia da tabela listas_compartilhadas no Supabase.',
      ],
    ),
    _Section(
      'Rastreabilidade',
      [
        'Matriz de rastreabilidade conecta requisitos, casos de uso e componentes arquiteturais.',
        'Exemplo: RF05 (compartilhar lista) -> UC Compartilhar Lista -> modulo banco_local + tela de listas recebidas + tabela cloud.',
      ],
    ),
    _Section(
      'Requisitos -> Casos de Uso -> Arquitetura',
      [
        'RF01 -> UC Login/Registro -> main.dart + telas login/register + Supabase Auth.',
        'RF03 -> UC Finalizar Compra -> historico em SQLite + telas de historico.',
        'RF05 -> UC Compartilhar/Receber Lista -> metodos cloud em banco_local + received_lists_screen.',
      ],
    ),
    _Section(
      'Visao de Casos de Uso',
      [
        'Atores principais: Usuario autenticado.',
        'Casos de uso centrais: Gerenciar listas, realizar compra, consultar historico/despesas, compartilhar e baixar listas.',
      ],
    ),
    _Section(
      'Diagramas de caso de uso',
      [
        'Diagrama recomendado com ator Usuario conectado aos casos: Login, Criar Lista, Adicionar Produto, Finalizar Compra, Consultar Historico, Compartilhar Lista, Baixar Lista.',
        'Representar tambem relacoes include entre Finalizar Compra e Registrar Historico.',
      ],
    ),
    _Section(
      'Casos de uso significativos para a arquitetura',
      [
        'UC1 - Compartilhar Lista: valida autenticacao, serializa itens e grava no Supabase.',
        'UC2 - Baixar Lista Recebida: consulta cloud, importa para banco local e habilita uso offline.',
        'UC3 - Finalizar Compra: persiste snapshot em historico para analise posterior.',
      ],
    ),
    _Section(
      'Visao Logica',
      [
        'Camada de apresentacao: telas e widgets em lib/screens e lib/widgets.',
        'Camada de dominio/dados: regras de lista/historico e acesso SQLite em lib/dados/banco_local.dart.',
        'Camada de integracao: autenticacao e operacoes cloud via Supabase.',
      ],
    ),
    _Section(
      'Visao geral (pacotes e camadas)',
      [
        'Pacotes principais: flutter/material, provider, sqflite, supabase_flutter, pdf/printing.',
        'Separacao em modulos: UI (screens/widgets), dados (dados), configuracao global (main/theme_notifier).',
      ],
    ),
    _Section(
      'Visao de Implementacao',
      [
        'Tecnologias: Dart 3, Flutter, SQLite local, Supabase cloud.',
        'Organizacao por features em telas e repositorio de dados centralizado em banco_local.',
        'Build e execucao com parametros de ambiente para chaves de integracao.',
      ],
    ),
    _Section(
      'Dimensionamento e Performance',
      [
        'Leituras locais em SQLite minimizam latencia para uso cotidiano.',
        'Operacoes cloud sao pontuais e voltadas a compartilhamento.',
        'Indices e consultas filtradas no Supabase auxiliam escalabilidade inicial.',
      ],
    ),
    _Section(
      'Qualidade',
      [
        'Uso de flutter_lints para padrao de codigo.',
        'Tratamento de erros em operacoes cloud com validacoes e fallback local.',
        'Recomendacao: ampliar testes de widget e testes de integracao para fluxo de compartilhamento.',
      ],
    ),
    _Section(
      'Conclusao',
      [
        'A arquitetura do HardList atende ao objetivo de combinar usabilidade, operacao offline e colaboracao cloud.',
        'O projeto esta maduro para entrega academica, com melhoria principal concentrada na validacao final da configuracao Supabase.',
        'Importante: distribuir a apresentacao de forma equilibrada entre os integrantes, separando blocos (contexto, requisitos, arquitetura, casos de uso, qualidade e encerramento).',
      ],
    ),
  ];

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      build: (context) {
        return [
          for (final section in sections) ...[
            pw.Text(
              section.title,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 6),
            ...section.items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: const pw.TextStyle(fontSize: 11)),
                    pw.Expanded(
                      child: pw.Text(item, style: const pw.TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 10),
          ],
        ];
      },
    ),
  );

  final outputDir = Directory('documentos');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final file = File('documentos/APRESENTACAO_HARDLIST.pdf');
  await file.writeAsBytes(await doc.save());

  stdout.writeln('PDF gerado com sucesso em: ${file.path}');
}

class _Section {
  _Section(this.title, this.items);

  final String title;
  final List<String> items;
}
