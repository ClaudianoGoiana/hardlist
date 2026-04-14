// Arquivo: lib/dados/catalogo_local.dart

/// A classe [CatalogoLocal] serve como um banco de dados inicial em memória
/// para os produtos padrão que acompanham o aplicativo.
///
/// Ela fornece uma lista estática de produtos pré-configurados com suas
/// respectivas imagens e categorias, criados para facilitar o uso do aplicativo,
/// permitindo que os usuários adicionem itens rapidamente sem precisar
/// cadastrá-los do zero.
class CatalogoLocal {
  /// Gera caminho de imagem .webp a partir do nome do produto.
  /// Exemplo: "Leite Integral" -> "assets/images/leite_integral.webp"
  static String caminhoFotoPadrao(String nome) {
    String normalizado = nome.toLowerCase();

    const mapaAcentos = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c'
    };

    mapaAcentos.forEach((comAcento, semAcento) {
      normalizado = normalizado.replaceAll(comAcento, semAcento);
    });

    normalizado = normalizado
        .replaceAll('%', 'pct')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return 'assets/images/$normalizado.webp';
  }

  /// Lista oficial de produtos instalados por padrão no aplicativo.
  /// 
  /// Cada produto é estruturado como um dicionário (`Map<String, String>`) contendo:
  /// * `nome`: O nome de exibição do produto (ex: 'Arroz').
  /// * `categoria`: A seção do supermercado a qual ele pertence (ex: 'Mercearia').
  ///
  /// Para adicionar novos itens, basta inserir um novo bloco `{...}` abaixo.
  static final List<Map<String, String>> produtosPadrao = [
    // --- MERCEARIA ---
    { 'nome': 'Macarrão', 'categoria': 'Mercearia', 'foto': 'assets/images/macarrao.webp' },
    { 'nome': 'Arroz', 'categoria': 'Mercearia', 'foto': 'assets/images/m_arroz.webp' },
    { 'nome': 'Açúcar', 'categoria': 'Mercearia', 'foto': 'assets/images/m_acuca.webp' },
    { 'nome': 'Óleo', 'categoria': 'Mercearia', 'foto': 'assets/images/oleo.webp' },
    { 'nome': 'Azeite', 'categoria': 'Mercearia', 'foto': 'assets/images/m_azeite.webp' },
    { 'nome': 'Farinha', 'categoria': 'Mercearia', 'foto': 'assets/images/m_farinha.webp' },
    { 'nome': 'Feijão Carioca', 'categoria': 'Mercearia', 'foto': 'assets/images/m_feijao_carioca.webp' },
    { 'nome': 'Feijão Preto', 'categoria': 'Mercearia', 'foto': 'assets/images/m_Feijao_Preto.webp' },
    { 'nome': 'Feijão Macaça', 'categoria': 'Mercearia', 'foto': 'assets/images/m_Feijao_macaca.webp' },
    { 'nome': 'Flocão de Milho', 'categoria': 'Mercearia', 'foto': 'assets/images/m_flocao.webp' },
    { 'nome': 'Sal', 'categoria': 'Mercearia', 'foto': 'assets/images/m_sal.webp' },
    { 'nome': 'Oleo de Soja', 'categoria': 'Mercearia', 'foto': 'assets/images/oleo.webp' },

    // --- AÇOUGUE ---
    { 'nome': 'Picanha', 'categoria': 'Açougue' },
    { 'nome': 'Picanha', 'categoria': 'Açougue', 'foto': 'assets/images/picanha.webp' },
    { 'nome': 'Contrafilé', 'categoria': 'Açougue' },
    { 'nome': 'Patinho', 'categoria': 'Açougue' },
    { 'nome': 'Coxão Mole', 'categoria': 'Açougue' },
    { 'nome': 'Maminha', 'categoria': 'Açougue' },
    { 'nome': 'Fraldinha', 'categoria': 'Açougue' },
    { 'nome': 'Costela', 'categoria': 'Açougue' },
    { 'nome': 'Linguiça Toscana', 'categoria': 'Açougue' },
    { 'nome': 'Frango Inteiro', 'categoria': 'Açougue' },
    { 'nome': 'Peito de Frango', 'categoria': 'Açougue' },
    { 'nome': 'Coxa de Frango', 'categoria': 'Açougue' },
    { 'nome': 'Asa de Frango', 'categoria': 'Açougue' },
    { 'nome': 'Carne Moída', 'categoria': 'Açougue' },
    { 'nome': 'Bisteca Suína', 'categoria': 'Açougue' },

    // --- HORTIFRUTI ---
    { 'nome': 'Banana', 'categoria': 'Hortifruti' },
    { 'nome': 'Maçã', 'categoria': 'Hortifruti' },
    { 'nome': 'Laranja', 'categoria': 'Hortifruti' },
    { 'nome': 'Limão', 'categoria': 'Hortifruti' },
    { 'nome': 'Mamão', 'categoria': 'Hortifruti' },
    { 'nome': 'Melancia', 'categoria': 'Hortifruti' },
    { 'nome': 'Tomate', 'categoria': 'Hortifruti' },
    { 'nome': 'Cebola', 'categoria': 'Hortifruti' },
    { 'nome': 'Alho', 'categoria': 'Hortifruti' },
    { 'nome': 'Batata', 'categoria': 'Hortifruti' },
    { 'nome': 'Cenoura', 'categoria': 'Hortifruti' },
    { 'nome': 'Alface', 'categoria': 'Hortifruti' },
    { 'nome': 'Couve', 'categoria': 'Hortifruti' },
    { 'nome': 'Pimentão', 'categoria': 'Hortifruti' },
    { 'nome': 'Brócolis', 'categoria': 'Hortifruti' },

    // --- FRIOS E LATICÍNIOS ---
    { 'nome': 'Queijo Mussarela', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Queijo Prato', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Presunto', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Apresuntado', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Peito de Peru', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Salame', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Mortadela', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Leite Integral', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Leite Desnatado', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Manteiga', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Margarina', 'categoria': 'Frios e Laticínios' },
    { 'nome': 'Iogurte', 'categoria': 'Frios e Laticínios' },
    // --- BEBIDAS ---
    { 'nome': 'Água Mineral', 'categoria': 'Bebidas' },
    { 'nome': 'Água com Gás', 'categoria': 'Bebidas' },
    { 'nome': 'Refrigerante Cola', 'categoria': 'Bebidas' },
    { 'nome': 'Refrigerante Guaraná', 'categoria': 'Bebidas' },
    { 'nome': 'Suco de Laranja', 'categoria': 'Bebidas' },
    { 'nome': 'Suco de Uva', 'categoria': 'Bebidas' },
    { 'nome': 'Cerveja Pilsen', 'categoria': 'Bebidas' },
    { 'nome': 'Cerveja IPA', 'categoria': 'Bebidas' },
    { 'nome': 'Vinho Tinto', 'categoria': 'Bebidas' },
    { 'nome': 'Vinho Branco', 'categoria': 'Bebidas' },
    { 'nome': 'Vodka', 'categoria': 'Bebidas' },
    { 'nome': 'Whisky', 'categoria': 'Bebidas' },
    { 'nome': 'Energético', 'categoria': 'Bebidas' },
    { 'nome': 'Chá Gelado', 'categoria': 'Bebidas' },
    { 'nome': 'Água de Coco', 'categoria': 'Bebidas' },

    // --- LIMPEZA ---
    { 'nome': 'Sabão em Pó', 'categoria': 'Limpeza' },
    { 'nome': 'Sabão Líquido', 'categoria': 'Limpeza' },
    { 'nome': 'Amaciante', 'categoria': 'Limpeza' },
    { 'nome': 'Água Sanitária', 'categoria': 'Limpeza' },
    { 'nome': 'Desinfetante', 'categoria': 'Limpeza' },
    { 'nome': 'Detergente', 'categoria': 'Limpeza' },
    { 'nome': 'Esponja', 'categoria': 'Limpeza' },
    { 'nome': 'Lã de Aço', 'categoria': 'Limpeza' },
    { 'nome': 'Limpa Vidros', 'categoria': 'Limpeza' },
    { 'nome': 'Álcool 70%', 'categoria': 'Limpeza' },
    { 'nome': 'Multiuso', 'categoria': 'Limpeza' },
    { 'nome': 'Saco de Lixo', 'categoria': 'Limpeza' },
    { 'nome': 'Vassoura', 'categoria': 'Limpeza' },
    { 'nome': 'Rodo', 'categoria': 'Limpeza' },
    { 'nome': 'Pano de Chão', 'categoria': 'Limpeza' },

    // --- HIGIENE ---
    { 'nome': 'Sabonete', 'categoria': 'Higiene' },
    { 'nome': 'Shampoo', 'categoria': 'Higiene' },
    { 'nome': 'Condicionador', 'categoria': 'Higiene' },
    { 'nome': 'Creme Dental', 'categoria': 'Higiene' },
    { 'nome': 'Escova de Dentes', 'categoria': 'Higiene' },
    { 'nome': 'Fio Dental', 'categoria': 'Higiene' },
    { 'nome': 'Desodorante', 'categoria': 'Higiene' },
    { 'nome': 'Papel Higiênico', 'categoria': 'Higiene' },
    { 'nome': 'Absorvente', 'categoria': 'Higiene' },
    { 'nome': 'Hastes Flexíveis', 'categoria': 'Higiene' },
    { 'nome': 'Algodão', 'categoria': 'Higiene' },
    { 'nome': 'Lâmina de Barbear', 'categoria': 'Higiene' },
    { 'nome': 'Creme de Barbear', 'categoria': 'Higiene' },
    { 'nome': 'Loção Pós-Barba', 'categoria': 'Higiene' },
    { 'nome': 'Enxaguante Bucal', 'categoria': 'Higiene' },

    // --- PADARIA ---
    { 'nome': 'Pão Francês', 'categoria': 'Padaria' },
    { 'nome': 'Pão de Forma', 'categoria': 'Padaria' },
    { 'nome': 'Pão de Queijo', 'categoria': 'Padaria' },
    { 'nome': 'Bolo de Cenoura', 'categoria': 'Padaria' },
    { 'nome': 'Bolo de Chocolate', 'categoria': 'Padaria' },
    { 'nome': 'Croissant', 'categoria': 'Padaria' },
    { 'nome': 'Sonho', 'categoria': 'P