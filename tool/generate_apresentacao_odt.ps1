$ErrorActionPreference = 'Stop'

$outputPath = Join-Path $PWD 'documentos/APRESENTACAO_HARDLIST_EDITAVEL_LIBREOFFICE.odt'
$tempRoot = Join-Path $PWD '.tmp_odt_hardlist'

if (Test-Path $tempRoot) { Remove-Item $tempRoot -Recurse -Force }
New-Item -ItemType Directory -Path $tempRoot | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempRoot 'META-INF') | Out-Null

$mimetype = 'application/vnd.oasis.opendocument.text'

$manifestXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">
  <manifest:file-entry manifest:media-type="application/vnd.oasis.opendocument.text" manifest:full-path="/"/>
  <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="content.xml"/>
  <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="styles.xml"/>
  <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="meta.xml"/>
  <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="settings.xml"/>
</manifest:manifest>
'@

$metaXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<office:document-meta
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    office:version="1.2">
  <office:meta>
    <meta:generator>HardList ODT Generator</meta:generator>
    <dc:title>Apresentacao HardList</dc:title>
  </office:meta>
</office:document-meta>
'@

$settingsXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<office:document-settings
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
    office:version="1.2">
  <office:settings>
    <config:config-item-set config:name="ooo:view-settings"/>
  </office:settings>
</office:document-settings>
'@

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<office:document-styles
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    office:version="1.2">
  <office:styles>
    <style:style style:name="P1" style:family="paragraph">
      <style:text-properties fo:font-size="11pt"/>
    </style:style>
    <style:style style:name="H1" style:family="paragraph" style:parent-style-name="Heading">
      <style:text-properties fo:font-weight="bold" fo:font-size="14pt"/>
    </style:style>
  </office:styles>
</office:document-styles>
'@

$sections = @(
  @{Title='CAPA'; Items=@('APRESENTACAO DE ARQUITETURA - Projeto HardList','Aplicativo inteligente para listas de compras com suporte offline e sincronizacao em nuvem.','Data: 08/04/2026','Versao: v1.0','Equipe:','Claudiano Goiana','Jonatan Filipe','Tárcito Luã')},
  @{Title='Introducao'; Items=@('O HardList e um aplicativo Flutter para gestao de listas de compras com foco em praticidade no uso diario.','A solucao combina armazenamento local (SQLite) e recursos de nuvem (Supabase) para permitir uso offline e compartilhamento.')},
  @{Title='Finalidade'; Items=@('Apresentar a visao arquitetural do sistema HardList e os requisitos que guiam seu desenvolvimento.','Consolidar base tecnica para implementacao, manutencao e evolucao do produto.')},
  @{Title='Escopo'; Items=@('Inclui: autenticacao, gerenciamento de listas e produtos, historico de compras, visualizacao de despesas e compartilhamento de listas.','Nao inclui: marketplace, pagamentos online e recomendacao por IA nesta versao.')},
  @{Title='Definicoes, Acronimos e Abreviacoes'; Items=@('CRUD: Create, Read, Update, Delete.','RLS: Row Level Security (controle de acesso por linha no banco).','SDK: Software Development Kit.','UI/UX: Interface e experiencia do usuario.')},
  @{Title='Referencias'; Items=@('Flutter Documentation: https://docs.flutter.dev','Supabase Documentation: https://supabase.com/docs','Documentos internos do projeto (pasta documentos e supabase/migrations).')},
  @{Title='Representacao Arquitetural'; Items=@('Arquitetura em camadas com separacao entre apresentacao (screens/widgets), dados locais (SQLite) e servicos de nuvem (Supabase).','Padrao de estado com Provider para tema e controle de comportamento global da aplicacao.')},
  @{Title='Requisitos do Sistema'; Items=@('Aplicacao mobile multiplataforma baseada em Flutter.','Persistencia local para funcionamento offline e sincronizacao cloud para compartilhamento.')},
  @{Title='Requisitos de usuario'; Items=@('Cadastrar, editar e remover listas de compras.','Adicionar produtos por categoria e acompanhar progresso da compra.','Visualizar historico e gastos por categoria.','Compartilhar e baixar listas entre usuarios autenticados.')},
  @{Title='Requisitos funcionais'; Items=@('RF01: Cadastro e autenticacao de usuario via Supabase.','RF02: Criacao e gerenciamento de listas e produtos localmente.','RF03: Registro de historico de compras com itens e valores.','RF04: Geracao de visao de despesas em graficos.','RF05: Compartilhamento de listas na nuvem e download por outros usuarios.')},
  @{Title='Requisitos nao funcionais'; Items=@('RNF01: Tempo de resposta adequado para navegacao e operacoes comuns.','RNF02: Usabilidade com interface clara em tema claro/escuro.','RNF03: Seguranca de dados com politicas de acesso no Supabase (RLS).','RNF04: Portabilidade para Android, iOS, Windows, Linux e Web.')},
  @{Title='Requisitos e restricoes arquiteturais'; Items=@('Uso obrigatorio de Flutter (frontend), SQLite (offline) e Supabase (backend cloud).','Variaveis sensiveis (URL e anon key) devem ser injetadas por --dart-define.','Integracao cloud depende da existencia da tabela listas_compartilhadas no Supabase.')},
  @{Title='Rastreabilidade'; Items=@('Matriz de rastreabilidade conecta requisitos, casos de uso e componentes arquiteturais.','Exemplo: RF05 (compartilhar lista) -> UC Compartilhar Lista -> modulo banco_local + tela de listas recebidas + tabela cloud.')},
  @{Title='Requisitos -> Casos de Uso -> Arquitetura'; Items=@('RF01 -> UC Login/Registro -> main.dart + telas login/register + Supabase Auth.','RF03 -> UC Finalizar Compra -> historico em SQLite + telas de historico.','RF05 -> UC Compartilhar/Receber Lista -> metodos cloud em banco_local + received_lists_screen.')},
  @{Title='Visao de Casos de Uso'; Items=@('Atores principais: Usuario autenticado.','Casos de uso centrais: Gerenciar listas, realizar compra, consultar historico/despesas, compartilhar e baixar listas.')},
  @{Title='Diagramas de caso de uso'; Items=@('Diagrama recomendado com ator Usuario conectado aos casos: Login, Criar Lista, Adicionar Produto, Finalizar Compra, Consultar Historico, Compartilhar Lista, Baixar Lista.','Representar tambem relacoes include entre Finalizar Compra e Registrar Historico.')},
  @{Title='Casos de uso significativos para a arquitetura'; Items=@('UC1 - Compartilhar Lista: valida autenticacao, serializa itens e grava no Supabase.','UC2 - Baixar Lista Recebida: consulta cloud, importa para banco local e habilita uso offline.','UC3 - Finalizar Compra: persiste snapshot em historico para analise posterior.')},
  @{Title='Visao Logica'; Items=@('Camada de apresentacao: telas e widgets em lib/screens e lib/widgets.','Camada de dominio/dados: regras de lista/historico e acesso SQLite em lib/dados/banco_local.dart.','Camada de integracao: autenticacao e operacoes cloud via Supabase.')},
  @{Title='Visao geral (pacotes e camadas)'; Items=@('Pacotes principais: flutter/material, provider, sqflite, supabase_flutter, pdf/printing.','Separacao em modulos: UI (screens/widgets), dados (dados), configuracao global (main/theme_notifier).')},
  @{Title='Visao de Implementacao'; Items=@('Tecnologias: Dart 3, Flutter, SQLite local, Supabase cloud.','Organizacao por features em telas e repositorio de dados centralizado em banco_local.','Build e execucao com parametros de ambiente para chaves de integracao.')},
  @{Title='Dimensionamento e Performance'; Items=@('Leituras locais em SQLite minimizam latencia para uso cotidiano.','Operacoes cloud sao pontuais e voltadas a compartilhamento.','Indices e consultas filtradas no Supabase auxiliam escalabilidade inicial.')},
  @{Title='Qualidade'; Items=@('Uso de flutter_lints para padrao de codigo.','Tratamento de erros em operacoes cloud com validacoes e fallback local.','Recomendacao: ampliar testes de widget e testes de integracao para fluxo de compartilhamento.')},
  @{Title='Conclusao'; Items=@('A arquitetura do HardList atende ao objetivo de combinar usabilidade, operacao offline e colaboracao cloud.','O projeto esta maduro para entrega academica, com melhoria principal concentrada na validacao final da configuracao Supabase.','Importante: a apresentacao deve ser clara, objetiva e bem distribuida entre os integrantes da equipe.')}
)

function Escape-Xml([string]$text) {
  $text = $text -replace '&','&amp;'
  $text = $text -replace '<','&lt;'
  $text = $text -replace '>','&gt;'
  $text = $text -replace '"','&quot;'
  $text = $text -replace "'",'&apos;'
  return $text
}

$sb = New-Object System.Text.StringBuilder
$null = $sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
$null = $sb.AppendLine('<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" office:version="1.2">')
$null = $sb.AppendLine('  <office:body>')
$null = $sb.AppendLine('    <office:text>')

foreach ($sec in $sections) {
  $title = Escape-Xml $sec.Title
  $null = $sb.AppendLine('      <text:p text:style-name="H1">' + $title + '</text:p>')
  foreach ($item in $sec.Items) {
    $txt = Escape-Xml $item
    $null = $sb.AppendLine('      <text:p text:style-name="P1">- ' + $txt + '</text:p>')
  }
  $null = $sb.AppendLine('      <text:p text:style-name="P1"></text:p>')
}

$null = $sb.AppendLine('    </office:text>')
$null = $sb.AppendLine('  </office:body>')
$null = $sb.AppendLine('</office:document-content>')

Set-Content -Path (Join-Path $tempRoot 'mimetype') -Value $mimetype -NoNewline -Encoding ASCII
Set-Content -Path (Join-Path $tempRoot 'META-INF/manifest.xml') -Value $manifestXml -Encoding UTF8
Set-Content -Path (Join-Path $tempRoot 'meta.xml') -Value $metaXml -Encoding UTF8
Set-Content -Path (Join-Path $tempRoot 'settings.xml') -Value $settingsXml -Encoding UTF8
Set-Content -Path (Join-Path $tempRoot 'styles.xml') -Value $stylesXml -Encoding UTF8
Set-Content -Path (Join-Path $tempRoot 'content.xml') -Value $sb.ToString() -Encoding UTF8

$zipTemp = Join-Path $PWD 'documentos/APRESENTACAO_HARDLIST_EDITAVEL_LIBREOFFICE.zip'
if (Test-Path $zipTemp) { Remove-Item $zipTemp -Force }
if (Test-Path $outputPath) { Remove-Item $outputPath -Force }

Compress-Archive -Path (Join-Path $tempRoot '*') -DestinationPath $zipTemp -Force
Rename-Item -Path $zipTemp -NewName 'APRESENTACAO_HARDLIST_EDITAVEL_LIBREOFFICE.odt'

Remove-Item $tempRoot -Recurse -Force

Get-Item $outputPath | Select-Object FullName, Length, LastWriteTime | Format-List
