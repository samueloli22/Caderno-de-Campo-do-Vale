// Controle de Estoque de Insumos — PARTE D do app
// Programação para Dispositivos Móveis · IF Goiano — Campus Ceres
//

import 'package:flutter/material.dart';

// =====================================================================
// MODELO
// =====================================================================
// A 'quantidade' NÃO é final: ela muda quando o usuário retira ou repõe.
// Por isso a lista de insumos não pode ser 'const'.
class Insumo {
  final String nome;
  final String categoria; // 'semente', 'fertilizante' ou 'defensivo'
  final String unidade; // 'sc', 't', 'L'...
  final double minimo; // abaixo disso, é hora de comprar
  final double passo; // quanto cada toque em − / + mexe
  double quantidade;

  Insumo({
    required this.nome,
    required this.categoria,
    required this.unidade,
    required this.minimo,
    required this.passo,
    required this.quantidade,
  });

  // Getter: propriedade calculada. Cada vez que alguém pergunta
  // insumo.abaixoDoMinimo, o Dart refaz a conta com a quantidade atual.
  bool get abaixoDoMinimo => quantidade < minimo;
}

const List<String> _categorias = ['semente', 'fertilizante', 'defensivo'];

// Ícone de cada categoria.
IconData _iconeDaCategoria(String categoria) {
  switch (categoria) {
    case 'semente':
      return Icons.grass;
    case 'fertilizante':
      return Icons.science;
    case 'defensivo':
      return Icons.bug_report;
    default:
      return Icons.inventory_2;
  }
}

// Formata no padrão brasileiro: 12.5 -> "12,5" e 40.0 -> "40".
String _formatar(double valor) {
  final texto = valor == valor.roundToDouble()
      ? valor.toStringAsFixed(0)
      : valor.toStringAsFixed(1);
  return texto.replaceAll('.', ',');
}

// Lê um número digitado, aceitando vírgula. Devolve null se for inválido.
double? _numero(String texto) {
  return double.tryParse(texto.trim().replaceAll(',', '.'));
}

// =====================================================================
// TELA (com estado)
// =====================================================================
class TelaEstoque extends StatefulWidget {
  const TelaEstoque({super.key});

  @override
  State<TelaEstoque> createState() => _TelaEstoqueState();
}

class _TelaEstoqueState extends State<TelaEstoque> {
  // O estado da tela: a lista de insumos.
  final List<Insumo> _insumos = [
    Insumo(nome: 'Semente de soja', categoria: 'semente', unidade: 'sc', minimo: 40, passo: 5, quantidade: 46),
    Insumo(nome: 'Semente de milho', categoria: 'semente', unidade: 'sc', minimo: 25, passo: 5, quantidade: 18),
    Insumo(nome: 'NPK 04-14-08', categoria: 'fertilizante', unidade: 't', minimo: 10, passo: 0.5, quantidade: 12.5),
    Insumo(nome: 'Ureia', categoria: 'fertilizante', unidade: 't', minimo: 6, passo: 0.5, quantidade: 4),
    Insumo(nome: 'Glifosato', categoria: 'defensivo', unidade: 'L', minimo: 200, passo: 20, quantidade: 320),
    Insumo(nome: 'Fungicida', categoria: 'defensivo', unidade: 'L', minimo: 60, passo: 10, quantidade: 90),
  ];

  // Retira (delta negativo) ou repõe (delta positivo) um insumo.
  // Tudo que muda algo visível fica DENTRO do setState.
  void _alterar(Insumo insumo, double delta) {
    // REGRA DE NEGÓCIO: Se for uma baixa e a quantidade for insuficiente, recusa com aviso.
    if (delta < 0 && (insumo.quantidade + delta) < 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Baixa recusada: estoque de ${insumo.nome} insuficiente!'),
            backgroundColor: const Color(0xFFC0392B),
          ),
        );
      return;
    }

    final estavaEmDia = !insumo.abaixoDoMinimo;

    setState(() {
      insumo.quantidade += delta;
    });

    // Se ESTE toque fez o insumo cruzar o mínimo, avisa.
    if (estavaEmDia && insumo.abaixoDoMinimo) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${insumo.nome} ficou abaixo do mínimo!')),
        );
    }
  }

  // Abre o formulário e espera o resultado. O formulário devolve um Insumo
  // (Navigator.pop) ou null se o usuário cancelar.
  Future<void> _abrirCadastro() async {
    final novo = await showModalBottomSheet<Insumo>(
      context: context,
      isScrollControlled: true, // deixa o formulário subir com o teclado
      builder: (context) => const _FormNovoInsumo(),
    );

    if (!mounted) return;
    if (novo != null) {
      setState(() => _insumos.add(novo));
    }
  }

  // Remove um insumo e oferece DESFAZER.
  void _remover(Insumo insumo) {
    final posicao = _insumos.indexOf(insumo);
    setState(() => _insumos.remove(insumo));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${insumo.nome} removido'),
          action: SnackBarAction(
            label: 'DESFAZER',
            onPressed: () => setState(() => _insumos.insert(posicao, insumo)),
          ),
        ),
      );
  }

  // Abre o formulário preenchido com os dados do insumo selecionado para edição.
  Future<void> _abrirEdicao(Insumo insumo) async {
    final editado = await showModalBottomSheet<Insumo>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FormNovoInsumo(insumoExistente: insumo),
    );

    if (!mounted) return;
    if (editado != null) {
      setState(() {
        final indice = _insumos.indexOf(insumo);
        if (indice != -1) {
          _insumos[indice] = editado;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recalculado a cada build: sempre reflete o estoque atual.
    final emAlerta = _insumos.where((i) => i.abaixoDoMinimo).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque de insumos'),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 'if' dentro da lista de filhos: a faixa só existe quando há alerta.
          if (emAlerta.isNotEmpty) _FaixaAlerta(insumos: emAlerta),

          // ---- TRÊS NÚMEROS, dividindo a largura sem overflow ----
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _CardNumero(
                    titulo: 'Insumos',
                    valor: '${_insumos.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CardNumero(
                    titulo: 'Em alerta',
                    valor: '${emAlerta.length}',
                    alerta: emAlerta.isNotEmpty,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CardNumero(
                    titulo: 'Em dia',
                    valor: '${_insumos.length - emAlerta.length}',
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Insumos da propriedade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),

          // ---- LISTA (ocupa o espaço que sobra) ----
          Expanded(
            child: _insumos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum insumo cadastrado.\nToque em "Novo insumo".',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    // bottom 88: para o botão flutuante não cobrir o último item
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: _insumos.length,
                    itemBuilder: (context, indice) {
                      final insumo = _insumos[indice];
                      // Dismissible: arrastar para a esquerda ou direita remove.
                      // Precisa de uma key única por item.
                      return Dismissible(
                        key: ObjectKey(insumo),
                        // Permite deslizar tanto para a esquerda quanto para a direita
                        direction: DismissDirection.horizontal,
                        // Fundo ao deslizar da esquerda para a direita
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0392B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        // Fundo ao deslizar da direita para a esquerda
                        secondaryBackground: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0392B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        // Pergunta antes de confirmar a exclusão
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: Text(
                                  'Deseja realmente remover "${insumo.nome}" do estoque?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFC0392B),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (_) => _remover(insumo),
                        child: _ItemEstoque(
                          insumo: insumo,
                          // Callbacks: o item não altera o estoque sozinho;
                          // ele AVISA a tela, que é a dona do estado.
                          onRetirar: () => _alterar(insumo, -insumo.passo),
                          onRepor: () => _alterar(insumo, insumo.passo),
                          onTap: () => _abrirEdicao(insumo),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo insumo'),
      ),
    );
  }
}

// =====================================================================
// FORMULÁRIO DE INSUMO (Novo ou Edição)
// =====================================================================
// É um StatefulWidget próprio porque tem controllers para criar e liberar.
class _FormNovoInsumo extends StatefulWidget {
  final Insumo? insumoExistente; // null = Novo | com valor = Edição

  const _FormNovoInsumo({super.key, this.insumoExistente});

  @override
  State<_FormNovoInsumo> createState() => _FormNovoInsumoState();
}

class _FormNovoInsumoState extends State<_FormNovoInsumo> {
  // A chave que dá acesso ao estado do formulário.
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _minimoController = TextEditingController();
  final _passoController = TextEditingController();

  String _categoria = 'semente';

  // Getter para saber se estamos editando um insumo existente ou criando um novo
  bool get _editando => widget.insumoExistente != null;

  @override
  void initState() {
    super.initState();
    // Se estiver editando, preenche os controllers com os dados atuais do insumo
    if (_editando) {
      final item = widget.insumoExistente!;
      _nomeController.text = item.nome;
      _unidadeController.text = item.unidade;
      _quantidadeController.text = _formatar(item.quantidade);
      _minimoController.text = _formatar(item.minimo);
      _passoController.text = _formatar(item.passo);
      _categoria = item.categoria;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _unidadeController.dispose();
    _quantidadeController.dispose();
    _minimoController.dispose();
    _passoController.dispose();
    super.dispose();
  }

  // ---- VALIDATORS REUTILIZÁVEIS ----
  // Devolvem a mensagem de erro, ou null se o valor for válido.

  String? _validarTexto(String? valor, String nomeCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe $nomeCampo';
    }
    return null;
  }

  // permiteZero: true para "Em estoque" (pode ser 0);
  // false para mínimo e passo (precisam ser > 0).
  String? _validarNumero(String? valor, String nomeCampo,
      {bool permiteZero = false}) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe $nomeCampo';
    }
    final numero = _numero(valor);
    if (numero == null) {
      return '$nomeCampo deve ser um número';
    }
    if (permiteZero ? numero < 0 : numero <= 0) {
      return permiteZero
          ? '$nomeCampo não pode ser negativo'
          : '$nomeCampo deve ser maior que zero';
    }
    return null;
  }

  // Validator específico do passo: reaproveita o _validarNumero e
  // depois confere a regra própria (passo não pode passar do mínimo).
  String? _validarPasso(String? valor) {
    // 1º: as regras gerais (vazio, não numérico, <= 0).
    final erroGeral = _validarNumero(valor, 'o passo');
    if (erroGeral != null) return erroGeral;

    // 2º: a regra específica. Lê o campo "mínimo" pelo controller.
    final passo = _numero(valor!)!;
    final minimo = _numero(_minimoController.text);

    // Se o mínimo ainda está vazio/inválido, ele mesmo vai mostrar erro;
    // aqui só comparamos quando existe um mínimo válido.
    if (minimo != null && minimo > 0 && passo > minimo) {
      return 'O passo não pode ser maior que o mínimo '
          '(${_formatar(minimo)})';
    }
    return null;
  }

  void _salvar() {
    // Dispara TODOS os validators de uma vez.
    if (!_formKey.currentState!.validate()) return;

    // Se chegou aqui, todos os campos são válidos: os '!' são seguros.
    Navigator.pop(
      context,
      Insumo(
        nome: _nomeController.text.trim(),
        categoria: _categoria,
        unidade: _unidadeController.text.trim(),
        minimo: _numero(_minimoController.text)!,
        passo: _numero(_passoController.text)!,
        quantidade: _numero(_quantidadeController.text)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // viewInsets.bottom = altura do teclado; empurra o formulário para cima.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_editando ? 'Editar insumo' : 'Novo insumo',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _Campo(
                controlador: _nomeController,
                rotulo: 'Nome (ex.: Semente de soja)',
                icone: Icons.label_outline,
                validator: (v) => _validarTexto(v, 'o nome'),
              ),
              const SizedBox(height: 12),

              // Categoria: um chip selecionável para cada opção.
              Wrap(
                spacing: 8,
                children: [
                  for (final c in _categorias)
                    ChoiceChip(
                      avatar: Icon(_iconeDaCategoria(c), size: 18),
                      label: Text(c[0].toUpperCase() + c.substring(1)),
                      selected: _categoria == c,
                      onSelected: (_) => setState(() => _categoria = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // crossAxisAlignment.start: se só um campo da linha der erro,
              // os dois continuam alinhados pelo topo.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Campo(
                      controlador: _quantidadeController,
                      rotulo: 'Em estoque',
                      icone: Icons.inventory_2_outlined,
                      numerico: true,
                      validator: (v) =>
                          _validarNumero(v, 'a quantidade', permiteZero: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Campo(
                      controlador: _unidadeController,
                      rotulo: 'Unidade (sc, t, L)',
                      icone: Icons.straighten,
                      validator: (v) => _validarTexto(v, 'a unidade'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Campo(
                      controlador: _minimoController,
                      rotulo: 'Estoque mínimo',
                      icone: Icons.warning_amber_rounded,
                      numerico: true,
                      validator: (v) => _validarNumero(v, 'o mínimo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Campo(
                      controlador: _passoController,
                      rotulo: 'Passo de − / +',
                      icone: Icons.exposure,
                      numerico: true,
                      validator: _validarPasso,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.check),
                      label: Text(_editando ? 'Salvar alterações' : 'Salvar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// WIDGETS AUXILIARES (sem estado: só desenham o que recebem)
// =====================================================================

// Campo reutilizável (texto ou número), agora com validator.
class _Campo extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final IconData icone;
  final bool numerico;
  final String? Function(String?)? validator;

  const _Campo({
    required this.controlador,
    required this.rotulo,
    required this.icone,
    this.numerico = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      validator: validator,
      keyboardType: numerico
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      textCapitalization:
          numerico ? TextCapitalization.none : TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: Icon(icone, color: const Color(0xFF1E5631)),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// Faixa vermelha no topo, listando quem está abaixo do mínimo.
class _FaixaAlerta extends StatelessWidget {
  final List<Insumo> insumos;
  const _FaixaAlerta({required this.insumos});

  @override
  Widget build(BuildContext context) {
    final nomes = insumos.map((i) => i.nome).join(', ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFC0392B),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          // Expanded: sem ele, o texto longo dá overflow dentro da Row.
          Expanded(
            child: Text(
              'Abaixo do mínimo: $nomes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardNumero extends StatelessWidget {
  final String titulo;
  final String valor;
  final bool alerta;

  const _CardNumero({
    required this.titulo,
    required this.valor,
    this.alerta = false,
  });

  @override
  Widget build(BuildContext context) {
    final cor = alerta ? const Color(0xFFC0392B) : const Color(0xFF1E8449);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alerta ? const Color(0xFFFDEDEC) : const Color(0xFFEFF7F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor),
      ),
      child: Column(
        children: [
          Text(valor,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: cor)),
          const SizedBox(height: 2),
          Text(titulo, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// Um item da lista: nome, quantidade, barra de nível e botões − / +.
class _ItemEstoque extends StatelessWidget {
  final Insumo insumo;
  final VoidCallback onRetirar;
  final VoidCallback onRepor;
  final VoidCallback onTap;

  const _ItemEstoque({
    required this.insumo,
    required this.onRetirar,
    required this.onRepor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emAlerta = insumo.abaixoDoMinimo;
    final cor = emAlerta ? const Color(0xFFC0392B) : const Color(0xFF1E8449);

    // A barra fica cheia quando o estoque chega ao DOBRO do mínimo.
    // Logo, o meio da barra é exatamente o limite do mínimo.
    final nivel = (insumo.quantidade / (insumo.minimo * 2)).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: emAlerta ? const Color(0xFFFDEDEC) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: emAlerta ? cor : Colors.transparent, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Linha de cima: ícone, nome + mínimo, quantidade.
              Row(
                children: [
                  Icon(_iconeDaCategoria(insumo.categoria), color: cor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(insumo.nome,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          emAlerta
                              ? 'ABAIXO DO MÍNIMO (${_formatar(insumo.minimo)} ${insumo.unidade})'
                              : 'Mínimo: ${_formatar(insumo.minimo)} ${insumo.unidade}',
                          style: TextStyle(
                            fontSize: 13,
                            color: emAlerta ? cor : Colors.black54,
                            fontWeight:
                                emAlerta ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatar(insumo.quantidade)} ${insumo.unidade}',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: cor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Linha de baixo: barra de nível + botões grandes (toque fácil).
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: nivel,
                        minHeight: 10,
                        color: cor,
                        backgroundColor: Colors.black12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: onRetirar,
                    tooltip:
                        'Retirar ${_formatar(insumo.passo)} ${insumo.unidade}',
                    iconSize: 28,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: onRepor,
                    tooltip: 'Repor ${_formatar(insumo.passo)} ${insumo.unidade}',
                    iconSize: 28,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}