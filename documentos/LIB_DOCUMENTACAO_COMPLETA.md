# Documentacao Completa da Pasta lib

Data: 2026-03-18
Escopo: todos os arquivos Dart dentro de lib

## 1. Visao Geral da Arquitetura

A camada lib esta organizada em 4 blocos:

1. Inicializacao e tema
- main.dart
- theme_notifier.dart

2. Persistencia e dados
- dados/banco_local.dart
- dados/catalogo_local.dart

3. Interface de telas
- screens/*.dart

4. Componentes compartilhados
- widgets/*.dart

## 2. Mapa de Navegacao

Entrada do app:
- main.dart -> MyApp -> ListScreen

Fluxos principais:
- ListScreen -> HomeScreen (abrir lista)
- HomeScreen -> AddProductScreen (adicionar itens)
- HomeScreen -> HistoryScreen (apos confirmar compra)
- Drawer -> ProductsScreen, CategoriesScreen, HistoryScreen, ExpensesScreen, ReceivedListsScreen, CloudScreen, SettingsScreen, AboutScreen
- LoginScreen -> ListScreen (login ok)
- LoginScreen -> RegisterScreen
- SettingsScreen -> Edge Function delete-account

## 3. Estrutura de Dados (banco local e nuvem)

SQLite local (sqflite_common_ffi):
- listas
- produtos
- historico
- listas_cloud

Supabase (nuvem):
- auth (login/registro/sessao)
- tabela listas (compartilhamento)
- edge function delete-account

## 4. Documentacao Arquivo por Arquivo

## 4.1 lib/main.dart

Objetivo:
- Inicializar Flutter e Supabase.
- Injetar ThemeNotifier com Provider.
- Definir tela inicial.

Elementos principais:
- Variavel global themeNotifier.
- Funcao main() async.
- Classe MyApp (StatelessWidget).

Comportamento:
- Chama Supabase.initialize com url e anonKey.
- Usa ChangeNotifierProvider para disponibilizar o tema.
- MaterialApp abre em ListScreen.

## 4.2 lib/theme_notifier.dart

Objetivo:
- Gerenciar alternancia entre tema claro e escuro.

Classe:
- ThemeNotifier extends ValueNotifier<ThemeMode>

Metodos:
- Sem metodos publicos adicionais no estado atual (usa apenas ValueNotifier<ThemeMode>).

## 4.3 lib/cloud_screen.dart (raiz de lib)

Status:
- Removido na limpeza tecnica de 2026-03-18.
- Nao participa mais da base de codigo.

Recomendacao:
- Caso volte a ser necessario, recriar com responsabilidade clara.

## 4.4 lib/dados/banco_local.dart

Objetivo:
- Centralizar acesso ao banco SQLite local.
- Sincronizar listas com Supabase.
- Suportar historico de compras e recebimento de listas.

Classe:
- BancoLocal (static utility/singleton de acesso ao DB)

Atributos:
- static Database? _bd: instancia unica do banco.

Getter:
- bancoDeDados: inicializa de forma lazy e retorna Database.

Metodos de historico:
- adicionarHistorico(...): grava compra finalizada.
- listarHistorico(): lista compras por data desc.

Metodos de cache local de cloud:
- compartilharLista(...): salva lista compartilhada localmente em listas_cloud.
- listarListasCloud(): lista cache local da nuvem.
- listarListasRecebidasLocal(): filtra downloads com id prefixado por dl_.
- removerListaCloud(id, usuarioId): remove cache local.
- atualizarListaCloud(id, nome, produtosJson, usuarioId): atualiza cache local.

Inicializacao e migracao:
- _inicializarBanco(): configura sqflite_ffi para desktop e abre banco versao 4.
- onCreate: cria tabelas base.
- onUpgrade:
  - v2: cria historico
  - v3: adiciona coluna criador_id em listas_cloud
  - v4: adiciona coluna criador_nome em listas_cloud
- _garantirSchemaListasCloud(): verifica/adiciona colunas ausentes.
- _criarTabelas(): cria listas, produtos, historico, listas_cloud.

Sincronizacao Supabase:
- compartilharListaNaCloud(..., publica): upsert em tabela listas com fallback para schema antigo sem criador_nome.
- _normalizarListasNuvem(response): padroniza campos esperados localmente.
- buscarListasCompartilhadasNuvem(): busca listas publicas de outros usuarios.
- listarListasNaNuvemDoUsuario(): busca listas do usuario atual (usuario_id ou criador_id).
- fazerDownloadLista(...):
  - evita download duplicado
  - cria nova lista local
  - importa produtos
  - registra em listas_cloud como recebida (id dl_...)
- atualizarListaNaCloud(...): atualiza nome, produtos_json e publica opcional.
- removerListaDaNuvem(id): deleta da tabela listas.

Dependencias externas:
- sqflite_common_ffi
- supabase_flutter
- uuid
- path
- dart:io
- dart:convert

## 4.5 lib/dados/catalogo_local.dart

Objetivo:
- Fornecer catalogo padrao de produtos e categorias.

Classe:
- CatalogoLocal

Metodos e dados:
- caminhoFotoPadrao(nome): normaliza texto e gera caminho assets/images/<nome>.webp.
- produtosPadrao: lista estatica com produtos de mercado por categoria.

Categorias presentes:
- Mercearia
- Acougue
- Hortifruti
- Frios e Laticinios
- Bebidas
- Limpeza
- Higiene
- Padaria
- Outros

Observacoes:
- Alguns itens possuem campo foto explicito; outros usam caminhoFotoPadrao.

## 4.6 lib/screens/about_screen.dart

Objetivo:
- Exibir dados institucionais do app.

Classe:
- AboutScreen (StatelessWidget)

Elementos UI:
- AppBar com titulo Sobre o HardList.
- Logo/identidade visual.
- Versao 1.0.0.
- Texto descritivo do app.
- Creditos de desenvolvimento.

## 4.7 lib/screens/add_product_screen.dart

Objetivo:
- Adicionar produtos na lista atual via catalogo ou item personalizado.

Classe:
- AddProductScreen (StatefulWidget)

Estado:
- produtos: origem CatalogoLocal.produtosPadrao.
- _categorias, _categoriaSelecionada, _textoBusca.

Fluxos:
1. Catalogo rapido em grid
- Busca por texto.
- Filtro por categoria.
- Toque em card insere produto na tabela produtos com quantidade 1 e preco 0.

2. Novo item personalizado (FAB)
- Abre bottom sheet.
- Captura foto com camera (image_picker).
- Define nome e categoria.
- Salva no banco local na lista atual.

Metodos:
- build(context)
- _abrirCriadorDeProdutoPersonalizado(context)

Dependencias:
- image_picker
- uuid
- BancoLocal
- CatalogoLocal

## 4.8 lib/screens/categories_screen.dart

Objetivo:
- Exibir categorias para atalho de navegacao de produtos filtrados.

Classe:
- CategoriesScreen (StatelessWidget)

Dados:
- _categorias (lista ordenada).
- _iconesPorCategoria (map categoria -> icon).

Fluxo:
- Tocar categoria abre ProductsScreen(categoriaNome: categoriaAtual).

## 4.9 lib/screens/cloud_screen.dart

Objetivo:
- Gerenciar listas na nuvem (minhas e recebidas de terceiros).

Classe:
- CloudScreen (StatefulWidget)

Estado:
- _minhasListasFuture
- _listasRecebidasFuture
- _usuarioId
- _meuNome

Metodos utilitarios:
- _toBool(valor, padrao)
- _refresh()
- _formatarData(dataIso)

Renderizacao principal:
- Future.wait para carregar minhas + recebidas.
- secoes separadas:
  - Listas na nuvem (enviadas por mim)
  - Listas de outros usuarios

Builders:
- _buildMinhaListaTile(lista)
- _buildListaCompartilhadaTile(lista)

Acoes:
- _handleMenuAction(action, lista)
- _verDetalhesLista(context, lista, permitirDownload)
- _editarLista(context, lista)
- _removerLista(context, lista)

Capacidades:
- Visualizar produtos da lista em dialog.
- Baixar lista compartilhada.
- Editar nome/visibilidade de lista propria.
- Remover lista propria da nuvem.

## 4.10 lib/screens/expenses_screen.dart

Objetivo:
- Exibir despesas agregadas por categoria a partir do historico de compras.

Classe ativa:
- ExpensesScreen (StatefulWidget)
- _DonutPainter (CustomPainter)

Estado:
- _mostrarRosquinha (alterna pizza/ barras)
- _despesasFuture
- _coresPorCategoria

Metodos ativos:
- _calcularDespesas():
  - busca historico
  - parse produtos_json
  - soma por categoria
  - calcula percentual
  - ordena por maior valor
- _botaoGrafico(...)
- _buildDonut(...)
- _buildBarras(...)

Elementos visuais:
- Total gasto.
- Toggle de visualizacao (Pizza/Barras).
- Grafico de rosca.
- Grafico de barras horizontal.
- Tabela/legenda por categoria (nome, valor, percentual).

Status de manutencao:
- Bloco legado antigo (tabs/grafico duplicado) foi removido na limpeza tecnica de 2026-03-18.

## 4.11 lib/screens/history_detail_screen.dart

Objetivo:
- Mostrar detalhes de uma compra do historico.

Classe:
- HistoryDetailScreen (StatelessWidget)

Entradas obrigatorias:
- nomeDaLista
- dataDaLista
- valorDaLista
- produtosJson

Metodos:
- _formatarData(iso): converte para dd/mm/yyyy as hh:mm.

UI:
- Cabecalho com nome/data/total.
- Lista de itens comprados com qtd, preco unitario e subtotal.

## 4.12 lib/screens/history_screen.dart

Objetivo:
- Listar historico de compras concluida.

Classe:
- HistoryScreen (StatefulWidget)

Estado:
- _historicoFuture

Metodos:
- initState(): carrega historico.
- _refresh(): recarrega Future.

Fluxo:
- FutureBuilder com loading/erro/vazio/lista.
- Tap em item abre HistoryDetailScreen.

## 4.13 lib/screens/home_screen.dart

Objetivo:
- Tela principal de itens de uma lista especifica.

Classe:
- HomeScreen (StatefulWidget)

Parametros:
- listaId
- listaNome

Estado:
- _produtos
- _carregando
- _nomeListaAtual

Metodos:
- _carregarProdutos(): busca dados da lista e produtos no SQLite.
- _construirListaAgrupada(produtos, context): agrupa por categoria e renderiza cards.
- _mostrarMenuDeOpcoes(context, produto): editar/excluir.
- _mostrarTelaDeEdicao(context, produto): dialog de edicao de nome/qtd/preco.
- _confirmarCompra(context, valorCompra): grava historico e limpa carrinho.
- _compartilharLista(context):
  - verifica autenticacao
  - evita duplicidade na nuvem
  - salva localmente
  - pergunta se envia para nuvem
  - pergunta visibilidade publica/privada
  - envia para Supabase
- _construirBarraInferior(context, valorTotalLista, valorNoCarrinho): resumo financeiro e botao confirmar.

Elementos de tela:
- AppBar com nome da lista e acao cloud_upload.
- Drawer global.
- Estado vazio com mensagem.
- FAB de adicionar produto.
- Bottom bar com totais e confirmacao.

## 4.14 lib/screens/list_screen.dart

Objetivo:
- Tela inicial de listas do usuario no banco local.

Classe:
- ListScreen (StatefulWidget)

Estado:
- _listas
- _carregando

Regra de negocio:
- Limite maximo de 20 listas para criacao.

Metodos:
- _atualizarListasNaTela(): consulta tabela listas.
- _mostrarMenuDeOpcoes(context, lista): menu de renomear/excluir.
- _mostrarDialogoNovaLista(context): cria nova lista.
- _mostrarDialogoEditarLista(context, lista): renomeia lista.

UI:
- Logo HardList no topo.
- Lista de cards com navegacao para HomeScreen.
- FAB Nova Lista.

Atualizacao aplicada no projeto:
- A contagem visual 0/20 foi removida da tela inicial.
- A regra de limite continua ativa ao criar nova lista.

## 4.15 lib/screens/login_screen.dart

Objetivo:
- Autenticar usuario por email/senha com Supabase.

Classe:
- LoginScreen (StatefulWidget)

Estado:
- controllers email/senha
- _carregando
- _obscurePassword

Metodo principal:
- _fazerLoginEmailSenha():
  - valida campos
  - executa signInWithPassword
  - trata erros comuns (email nao confirmado, credenciais invalidas)
  - navega para ListScreen com pushReplacement

UI:
- Formulario de login.
- Toggle de visibilidade de senha.
- Link para RegisterScreen.

## 4.16 lib/screens/products_screen.dart

Objetivo:
- Exibir catalogo de produtos com busca e filtro por categoria.

Classe:
- ProductsScreen (StatefulWidget)

Estado:
- _textoBusca
- _categoriaSelecionada
- _categorias

Fluxo:
- Filtra CatalogoLocal.produtosPadrao por texto e categoria.
- Lista cards com imagem e fallback de icone.

Observacao:
- Se chamada com categoriaNome, abre ja filtrada nessa categoria.

## 4.17 lib/screens/received_lists_screen.dart

Objetivo:
- Mostrar listas baixadas da nuvem e permitir consulta de detalhes.

Classe:
- ReceivedListsScreen (StatefulWidget)

Estado:
- _listasRecebidasFuture

Metodos:
- _carregarListasCompartilhadas(): consulta local via BancoLocal.listarListasRecebidasLocal.
- _refresh(): recarrega lista.
- _formatarData(iso)
- _mostrarDetalhesLista(context, lista): dialog com itens recebidos.

UI:
- FutureBuilder + RefreshIndicator.
- Cards com nome, quantidade de produtos, data e nome do criador.

## 4.18 lib/screens/register_screen.dart

Objetivo:
- Criar conta por email/senha no Supabase.

Classe:
- RegisterScreen (StatefulWidget)

Estado:
- controllers nome/email/senha/confirma
- _carregando
- _obscurePassword
- _obscureConfirmPassword

Metodo principal:
- _registrar():
  - valida campos
  - confirma senha
  - valida tamanho minimo
  - executa signUp com metadata name
  - exibe mensagens e retorna ao login

UI:
- Formulario completo de cadastro.
- Toggle de visibilidade para senha e confirmacao.

## 4.19 lib/screens/settings_screen.dart

Objetivo:
- Configuracoes de app, conta e exclusao de conta.

Classe:
- SettingsScreen (StatefulWidget)

Estado:
- _isDarkMode
- _notificationsEnabled
- _deletandoConta

Metodos:
- _confirmarExclusaoConta():
  - confirma em dialog
  - invoca edge function delete-account
  - faz signOut
  - redireciona para LoginScreen
  - trata erro de funcao nao publicada

Seções da tela:
- Aparencia: switch modo escuro.
- Notificacoes: switch alertas.
- Conta: email conectado + excluir conta (somente logado).
- Geral: idioma (placeholder).

Dependencia importante:
- Usa themeNotifier global definido em main.dart.

## 4.20 lib/widgets/app_drawer.dart

Objetivo:
- Menu lateral de navegacao global da aplicacao.

Classe:
- AppDrawer (StatelessWidget)

Comportamento:
- Escuta auth.onAuthStateChange via StreamBuilder.
- Mostra cabecalho diferente para usuario logado e visitante.
- Itens sempre visiveis:
  - Listas
  - Produtos
  - Categorias
  - Historico de compras
  - Minhas despesas
  - Listas recebidas
  - Configuracoes
  - Sobre
- Item condicional:
  - HardList Cloud (somente logado)
  - Sair (somente logado)

Metodo auxiliar:
- _buildDrawerItem(icon, text, onTap)

## 4.21 lib/widgets/bottom_summary_bar.dart

Objetivo:
- Removido na limpeza tecnica de 2026-03-18.

Classe:
- Nao se aplica (arquivo removido).

Conteudo:
- Nao se aplica.

Status funcional:
- O HomeScreen segue usando _construirBarraInferior propria.

## 5. Abas, Menus e Elementos Interativos (consolidado)

Aba e alternadores no projeto:
- ExpensesScreen: alternador Pizza/Barras.
- Sem codigo residual conhecido nessa tela apos a limpeza.

Menus e dialogos:
- HomeScreen: menu por produto (editar/excluir), dialog de edicao.
- ListScreen: menu por lista (renomear/excluir), dialog de criar/editar.
- CloudScreen: popup de editar/remover e dialog de detalhes/baixar.
- SettingsScreen: dialog de confirmacao para excluir conta.
- ReceivedListsScreen: dialog de detalhes da lista recebida.

## 6. Dependencias e Integracoes da lib

Principais packages usados:
- flutter/material.dart
- provider
- supabase_flutter
- sqflite_common_ffi
- path
- uuid
- image_picker

Recursos locais:
- assets/images/* (produtos)

Servicos externos:
- Supabase Auth
- Supabase tabela listas
- Supabase Edge Function delete-account

## 7. Pontos de Atencao Tecnicos

1. Chaves sensiveis:
- main.dart contem url/anon key no codigo.
- recomendado migrar para configuracao segura por ambiente.

2. Historico de limpeza concluida:
- Arquivos removidos: lib/cloud_screen.dart e lib/widgets/bottom_summary_bar.dart.
- Codigo legado removido: trecho residual antigo de lib/screens/expenses_screen.dart.

## 8. Checklist de Cobertura desta Documentacao

Cobertura concluida:
- Todos os arquivos de lib mapeados.
- Classes e responsabilidades descritas.
- Funcoes e metodos principais descritos.
- Fluxos de navegacao documentados.
- Menus, dialogos e elementos interativos listados.
- Integracoes com banco local e Supabase documentadas.
- Pontos de manutencao e risco registrados.

Fim da documentacao.
