// Arquivo: lib/dados/catalogo_local.dart

class CatalogoLocal {
  // Esta é a lista oficial de produtos que já vêm instalados no aplicativo!
  // Todo mundo que baixar o app terá esses produtos disponíveis.
  static final List<Map<String, String>> produtosPadrao = [
    {
      'nome': 'Arroz 5kg',
      'categoria': 'Mercearia',
      'foto': 'assets/images/arroz.png' // Lembre-se de colocar essa foto na pasta assets!
    },
    {
      'nome': 'Feijão Preto',
      'categoria': 'Mercearia',
      'foto': 'assets/images/feijao.png'
    },
    {
      'nome': 'Picanha',
      'categoria': 'Açougue',
      'foto': 'assets/images/picanha.png'
    },
    {
      'nome': 'Carvão 3kg',
      'categoria': 'Outros',
      'foto': 'assets/images/carvao.png'
    },
    {
      'nome': 'Refrigerante 2L',
      'categoria': 'Bebidas',
      'foto': 'assets/images/refrigerante.png'
    },
    {
      'nome': 'Detergente',
      'categoria': 'Limpeza',
      'foto': 'assets/images/detergente.png'
    },
  ];
}