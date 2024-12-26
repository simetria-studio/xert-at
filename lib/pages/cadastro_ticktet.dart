import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xerp_motor/class/api_config.dart';
import 'package:xerp_motor/pages/listall.dart';
import 'package:xerp_motor/pages/ticket_list.dart';

class CadTicket extends StatefulWidget {
  const CadTicket({super.key});

  @override
  State<CadTicket> createState() => _CadTicketState();
}

class _CadTicketState extends State<CadTicket> {
  bool userDataLoaded = false;
  final _formKey = GlobalKey<FormState>();

  // Declare controllers for text fields
  final TextEditingController ciNumberController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _depositoController = TextEditingController();
  final TextEditingController _placaVeiculoController = TextEditingController();
  final TextEditingController _placaCarretaController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController grossWeightController = TextEditingController();
  final TextEditingController tareWeightController = TextEditingController();
  final TextEditingController netWeightController = TextEditingController();
  final TextEditingController volumeController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController pilhaController = TextEditingController();

  final TextEditingController selectedMaterialsController =
      TextEditingController();

  final TextEditingController altura1Controller = TextEditingController();
  final TextEditingController altura2Controller = TextEditingController();
  final TextEditingController altura3Controller = TextEditingController();
  final TextEditingController altura4Controller = TextEditingController();
  final TextEditingController altura5Controller = TextEditingController();
  final TextEditingController altura6Controller = TextEditingController();
  final TextEditingController larguraController = TextEditingController();
  final TextEditingController comprimentoController = TextEditingController();

  final TextEditingController alturaJulieta1Controller =
      TextEditingController();
  final TextEditingController alturaJulieta2Controller =
      TextEditingController();
  final TextEditingController alturaJulieta3Controller =
      TextEditingController();
  final TextEditingController alturaJulieta4Controller =
      TextEditingController();
  final TextEditingController alturaJulieta5Controller =
      TextEditingController();
  final TextEditingController alturaJulieta6Controller =
      TextEditingController();

  final TextEditingController larguraJulietaController =
      TextEditingController();
  final TextEditingController comprimentoJulietaController =
      TextEditingController();

  final TextEditingController totalCavaloController = TextEditingController();
  final TextEditingController totalJulietaController = TextEditingController();

  late DateTime entryDate = DateTime.now();

  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> depositos = [];
  List<Map<String, dynamic>> placas = [];
  List<Map<String, dynamic>> carretas = [];
  List<Map<String, dynamic>> funcionarios = [];
  List<String> selectedMaterialsList = [];
  List<Map<String, dynamic>> produtos =
      []; // Lista de produtos carregados da API
  List<Map<String, dynamic>> produtosSelecionados = [];

  String formatarNumero(double valor) {
    // Converte o valor para string e remove qualquer ponto decimal
    String numeroString = valor.toString().replaceAll('.', '');

    // Pega apenas os 4 primeiros dígitos (ou preenche com zeros se necessário)
    numeroString = numeroString.padLeft(4, '0').substring(0, 4);

    // Insere o ponto decimal na posição correta (XX.XX)
    String resultado =
        '${numeroString.substring(0, 2)},${numeroString.substring(2)}';

    return resultado;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    ciNumberController.dispose();
    _clienteController.dispose();
    plateNumberController.dispose();
    driverNameController.dispose();
    grossWeightController.dispose();
    tareWeightController.dispose();
    netWeightController.dispose();
    volumeController.dispose();
    observationsController.dispose();
    totalController.dispose();
    quantidadeController.dispose();
    pilhaController.dispose();
    altura1Controller.dispose();
    altura2Controller.dispose();
    altura3Controller.dispose();
    altura4Controller.dispose();
    altura5Controller.dispose();
    altura6Controller.dispose();
    larguraController.dispose();
    comprimentoController.dispose();
    alturaJulieta1Controller.dispose();
    alturaJulieta2Controller.dispose();
    alturaJulieta3Controller.dispose();
    alturaJulieta4Controller.dispose();
    alturaJulieta5Controller.dispose();
    alturaJulieta6Controller.dispose();
    larguraJulietaController.dispose();
    comprimentoJulietaController.dispose();
    totalCavaloController.dispose();
    totalJulietaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != entryDate) {
      setState(() {
        entryDate = picked;
      });
    }
  }

  void updateSelectedMaterials() {
    selectedMaterialsList = selectedMaterials.entries
        .where((entry) => entry.value['selected'])
        .map((entry) =>
            entry.value['codigo'].toString()) // Obter código como String
        .toList(); // Converter em lista de strings

    selectedMaterialsController.text =
        selectedMaterialsList.join(', '); // Atualizar o controller
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(icon),
    );
  }

  Future<void> initializeData() async {
    setState(() {
      userDataLoaded = true;
    });
    await _fetchClientes('');
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    loadSavedData();
    loadSavedDriverName();
  }

  Future<List<Map<String, dynamic>>> _fetchClientes(String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    final codigoEmpresa = prefs.getString('codigo_empresa') ?? 0;

    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-clientes'),
      body: json.encode({"codigo_empresa": '0084', "search_text": searchText}),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        throw Exception(
            "Falha ao carregar os clientes: dados não são uma lista");
      }
    } else {
      throw Exception("Falha ao carregar os clientes");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDepositos(String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    final codigoEmpresa = prefs.getString('codigo_empresa') ?? 0;

    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-depositos'),
      body: json.encode({"codigo_empresa": '0084', "search_text": searchText}),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        throw Exception(
            "Falha ao carregar os depositos: dados não são uma lista");
      }
    } else {
      throw Exception("Falha ao carregar os depositos");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPlacas(String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    final codigoEmpresa = prefs.getString('codigo_empresa') ?? 0;

    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-placas'),
      body: json.encode({"codigo_empresa": '0084', "search_text": searchText}),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        throw Exception("Falha ao carregar as placas: dados não são uma lista");
      }
    } else {
      throw Exception("Falha ao carregar as placas");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPlacasCarretas(
      String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    final codigoEmpresa = prefs.getString('codigo_empresa') ?? 0;

    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-carretas'),
      body: json.encode({"codigo_empresa": '0084', "search_text": searchText}),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        throw Exception(
            "Falha ao carregar as carretas: dados não são uma lista");
      }
    } else {
      throw Exception("Falha ao carregar as carretas");
    }
  }

  Future<void> _fetchProdutos(String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    final codigoEmpresa = prefs.getString('codigo_empresa') ?? 0;

    // Verifique se há produtos salvos em SharedPreferences
    final String? cachedProdutos = prefs.getString('cached_produtos');

    // Se há produtos em cache e não há texto de busca, use o cache
    if (cachedProdutos != null && searchText.isEmpty) {
      final List<dynamic> responseData = json.decode(cachedProdutos);
      setState(() {
        produtos = List<Map<String, dynamic>>.from(responseData);
      });
      return;
    }

    // Se não há produtos em cache ou há texto de busca, faça a chamada de rede
    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-produtos-at'),
      body: json.encode({"codigo_empresa": '0084', "search_text": searchText}),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        setState(() {
          produtos = List<Map<String, dynamic>>.from(responseData);
        });

        // Salve os produtos em SharedPreferences se não há texto de busca
        if (searchText.isEmpty) {
          await prefs.setString('cached_produtos', json.encode(responseData));
        }
      } else {
        throw Exception(
            "Falha ao carregar os produtos: dados não são uma lista");
      }
    } else {
      throw Exception("Falha ao carregar os produtos");
    }
  }

  Future<void> clearProdutosCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_produtos');
  }

  Future<List<Map<String, dynamic>>> _fetchFuncionario(
      String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    final codigoEmpresa = prefs.getString('codigo_empresa') ?? 0;

    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-funcionarios'),
      body: json.encode({"codigo_empresa": '0084', "search_text": searchText}),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        setState(() {
          produtos = List<Map<String, dynamic>>.from(
              responseData); // Armazene os produtos na lista
        });
        return produtos;
      } else {
        throw Exception(
            "Falha ao carregar os produtos: dados não são uma lista");
      }
    } else {
      throw Exception("Falha ao carregar os produtos");
    }
  }

  Future<void> loadSavedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedPlateNumber = prefs.getString('plateNumber');
    if (savedPlateNumber != null) {
      setState(() {
        plateNumberController.text = savedPlateNumber;
      });
    }
  }

  Future<void> loadSavedDriverName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedDriverName = prefs.getString('driverName');
    if (savedDriverName != null) {
      setState(() {
        driverNameController.text = savedDriverName;
      });
    }
  }

  Future<void> enviarDados() async {
    final prefs = await SharedPreferences.getInstance();
    var url = Uri.parse('${ApiConfig.apiUrl}/store-ticket');
    var produtos = produtosSelecionados;

    double pilhaValue;
    try {
      pilhaValue = double.parse(pilhaController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O valor da pilha deve ser um número válido: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var corpo = jsonEncode({
      "numero_ci": ciNumberController.text,
      "codigo_cliente": _clienteController.text,
      "cliente": _clienteController.text,
      "motorista": driverNameController.text,
      "data_entrada": entryDate.toString(),
      "peso_liquido": netWeightController.text,
      "volume": volumeController.text,
      "observacoes": observationsController.text,
      "total": totalController.text,
      'codigo_deposito': _depositoController.text,
      'placa_veiculo': _placaVeiculoController.text,
      'placa_carreta': _placaCarretaController.text,
      'pilha': pilhaValue,
      "materiais": produtos.isNotEmpty ? produtos : [],
      'altura1': altura1Controller.text,
      'altura2': altura2Controller.text,
      'altura3': altura3Controller.text,
      'altura4': altura4Controller.text,
      'altura5': altura5Controller.text,
      'altura6': altura6Controller.text,
      'largura': larguraController.text,
      'comprimento': comprimentoController.text,
      'alturaJulieta1': alturaJulieta1Controller.text,
      'alturaJulieta2': alturaJulieta2Controller.text,
      'alturaJulieta3': alturaJulieta3Controller.text,
      'alturaJulieta4': alturaJulieta4Controller.text,
      'alturaJulieta5': alturaJulieta5Controller.text,
      'alturaJulieta6': alturaJulieta6Controller.text,
      'larguraJulieta': larguraJulietaController.text,
      'comprimentoJulieta': comprimentoJulietaController.text,
      'totalCavalo': totalCavaloController.text,
      'totalJulieta': totalJulietaController.text,
    });

    try {
      var resposta = await http.post(
        url,
        body: corpo,
        headers: {"Content-Type": "application/json"},
      );

      if (resposta.statusCode == 200) {
        var ticket = jsonDecode(resposta.body);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TicketListAllPage(),
          ),
        );
      } else {
        throw Exception('Falha ao enviar dados');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao enviar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, Map<String, dynamic>> selectedMaterials = {
    'Cavaco Eucalipto': {'codigo': '00000028', 'selected': false},
    'Cavaco Pinus': {'codigo': '00000183', 'selected': false},
    'Serragem Pinus': {'codigo': '0000013', 'selected': false},
  };

  String? validateCiNumber(String value) {
    if (value.isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  void _openModal(BuildContext context) async {
    await _fetchProdutos(''); // Busque os produtos antes de abrir o modal

    String? selectedProduto; // Variável para armazenar o produto selecionado

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleção de Produtos'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return DropdownButton<String>(
                      value: selectedProduto,
                      hint: const Text('Selecione um produto'),
                      items: produtos.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> produto) {
                        return DropdownMenuItem<String>(
                          value: produto['codigo_produto']?.toString() ?? '',
                          child: Text(
                              produto['descricao_produto'] ?? 'Sem descrição'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProduto = newValue;
                          selectedMaterials.forEach((key, value) {
                            selectedMaterials[key]?['selected'] =
                                key == selectedProduto;
                          });
                          updateSelectedMaterials();
                        });
                      },
                      isExpanded: true,
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: true,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedProduto != null &&
                        quantidadeController.text.isNotEmpty) {
                      var produto = produtos.firstWhere((element) =>
                          element['codigo_produto']?.toString() ==
                          selectedProduto);
                      setState(() {
                        produtosSelecionados.add({
                          'descricao':
                              produto['descricao_produto'] ?? 'Sem descrição',
                          'quantidade': int.parse(quantidadeController.text),
                          'preco_custo_produto':
                              produto['preco_custo_produto'] != null
                                  ? produto['preco_custo_produto'].toDouble()
                                  : 0.0, // Trate o caso onde o preço é nulo
                        });
                        // Atualizar total
                        atualizarTotal();

                        // Limpar campos após adicionar
                        quantidadeController.clear();

                        // Fechar o modal
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void atualizarTotal() {
    double total = 0;
    for (var produto in produtosSelecionados) {
      double preco = (produto['preco_custo_produto'] as num).toDouble();
      int quantidade = produto['quantidade'];
      total += preco * quantidade;
    }
    setState(() {
      totalController.text = total.toStringAsFixed(2);
    });
  }

  void calcularTotais() {
    try {
      // Calcula total do cavalo
      List<double> alturasCavalo = [
        double.tryParse(altura1Controller.text.replaceAll(',', '.')) ?? 0,
        double.tryParse(altura2Controller.text.replaceAll(',', '.')) ?? 0,
        double.tryParse(altura3Controller.text.replaceAll(',', '.')) ?? 0,
        double.tryParse(altura4Controller.text.replaceAll(',', '.')) ?? 0,
        double.tryParse(altura5Controller.text.replaceAll(',', '.')) ?? 0,
        double.tryParse(altura6Controller.text.replaceAll(',', '.')) ?? 0,
      ];

      // Filtra apenas as alturas preenchidas (diferentes de 0)
      List<double> alturasPreenchidas =
          alturasCavalo.where((altura) => altura > 0).toList();

      double mediaAlturaCavalo = alturasPreenchidas.isNotEmpty
          ? alturasPreenchidas.reduce((a, b) => a + b) /
              alturasPreenchidas.length
          : 0;

      double largura =
          double.tryParse(larguraController.text.replaceAll(',', '.')) ?? 0;
      double comprimento =
          double.tryParse(comprimentoController.text.replaceAll(',', '.')) ?? 0;

      double totalCavalo = mediaAlturaCavalo * largura * comprimento;

      // Calcula total da julieta separadamente
      List<double> alturasJulieta = [
        double.tryParse(alturaJulieta1Controller.text.replaceAll(',', '.')) ??
            0,
        double.tryParse(alturaJulieta2Controller.text.replaceAll(',', '.')) ??
            0,
        double.tryParse(alturaJulieta3Controller.text.replaceAll(',', '.')) ??
            0,
        double.tryParse(alturaJulieta4Controller.text.replaceAll(',', '.')) ??
            0,
        double.tryParse(alturaJulieta5Controller.text.replaceAll(',', '.')) ??
            0,
        double.tryParse(alturaJulieta6Controller.text.replaceAll(',', '.')) ??
            0,
      ];

      // Filtra apenas as alturas preenchidas (diferentes de 0)
      List<double> alturasJulietaPreenchidas =
          alturasJulieta.where((altura) => altura > 0).toList();

      double mediaAlturaJulieta = alturasJulietaPreenchidas.isNotEmpty
          ? alturasJulietaPreenchidas.reduce((a, b) => a + b) /
              alturasJulietaPreenchidas.length
          : 0;

      double larguraJ =
          double.tryParse(larguraJulietaController.text.replaceAll(',', '.')) ??
              0;
      double comprimentoJ = double.tryParse(
              comprimentoJulietaController.text.replaceAll(',', '.')) ??
          0;

      double totalJulieta = mediaAlturaJulieta * larguraJ * comprimentoJ;

      setState(() {
        // Atualiza os totais com 2 casas decimais
        totalCavaloController.text = formatarNumero(totalCavalo);
        totalJulietaController.text = formatarNumero(totalJulieta);
        totalController.text = formatarNumero(totalCavalo + totalJulieta);
      });
    } catch (e) {
      print('Erro ao calcular totais: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF043259),
        title: const Text(
          'AT - TICKET',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTextFormField(
                controller: ciNumberController,
                label: 'Número da C.I.',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo é obrigatório' : null,
              ),
              const SizedBox(height: 10),
              CustomTypeAheadField(
                controller: _clienteController,
                label: 'Cliente',
                icon: Icons.person,
                suggestionsCallback: _fetchClientes,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _clienteController.text = suggestion['codigo_cliente'];
                  });
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['razao_social'] ?? ''),
                    subtitle: Row(
                      children: [
                        Text(suggestion['cnpj_cpf'] ?? ''),
                        const SizedBox(width: 10),
                        Text(suggestion['cidade'] ?? ''),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomTypeAheadField(
                controller: _depositoController,
                label: 'Deposito',
                icon: Icons.home,
                suggestionsCallback: _fetchDepositos,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _depositoController.text = suggestion['codigo_deposito'];
                  });
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['nome_fantasia'] ?? ''),
                    subtitle: Row(
                      children: [
                        Text(suggestion['codigo_deposito'] ?? ''),
                        const SizedBox(width: 10),
                        Text(suggestion['ativo'] ?? ''),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomTypeAheadField(
                controller: _placaVeiculoController,
                label: 'Placa veiculo',
                icon: Icons.car_rental,
                suggestionsCallback: _fetchPlacas,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _placaVeiculoController.text = suggestion['placa_veiculo'];
                  });
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['placa_veiculo'] ?? ''),
                    subtitle: Row(
                      children: [
                        Text(suggestion['categoria_veiculo'] ?? ''),
                        const SizedBox(width: 10),
                        Text(suggestion['ativo'] ?? ''),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomTypeAheadField(
                controller: _placaCarretaController,
                label: 'Placa Carreta',
                icon: Icons.tram,
                suggestionsCallback: _fetchPlacasCarretas,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _placaCarretaController.text = suggestion['placa_veiculo'];
                  });
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['placa_veiculo'] ?? ''),
                    subtitle: Row(
                      children: [
                        Text(suggestion['marca'] ?? ''),
                        const SizedBox(width: 10),
                        Text(suggestion['ativo'] ?? ''),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomTypeAheadField(
                controller: driverNameController,
                label: 'Motorista',
                icon: Icons.home,
                suggestionsCallback: _fetchFuncionario,
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    driverNameController.text =
                        suggestion['codigo_funcionario'];
                  });
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['nome_funcionario'] ?? ''),
                    subtitle: Row(
                      children: [
                        Text(suggestion['codigo_funcionario'] ?? ''),
                        const SizedBox(width: 10),
                        Text(suggestion['ativo'] ?? ''),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: CustomTextFormField(
                  controller: TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(entryDate),
                  ),
                  label: 'Data de Entrada',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: pilhaController,
                label: 'Tamanho da pilha',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo é obrigatório' : null,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: observationsController,
                label: 'Observações',
                icon: Icons.comment,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Medidas do Cavalo:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: altura1Controller,
                      label: 'Altura 1',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: altura2Controller,
                      label: 'Altura 2',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: altura3Controller,
                      label: 'Altura 3',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: altura4Controller,
                      label: 'Altura 4',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: altura5Controller,
                      label: 'Altura 5',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: altura6Controller,
                      label: 'Altura 6',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: larguraController,
                      label: 'Largura',
                      icon: Icons.width_normal,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: comprimentoController,
                      label: 'Comprimento',
                      icon: Icons.straighten,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: totalCavaloController,
                      label: 'Total Cavalo',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      enabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Medidas da Julieta:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: alturaJulieta1Controller,
                      label: 'Altura 1',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: alturaJulieta2Controller,
                      label: 'Altura 2',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: alturaJulieta3Controller,
                      label: 'Altura 3',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: alturaJulieta4Controller,
                      label: 'Altura 4',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: alturaJulieta5Controller,
                      label: 'Altura 5',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: alturaJulieta6Controller,
                      label: 'Altura 6',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: larguraJulietaController,
                      label: 'Largura',
                      icon: Icons.width_normal,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: comprimentoJulietaController,
                      label: 'Comprimento',
                      icon: Icons.straighten,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => calcularTotais(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: totalJulietaController,
                      label: 'Total Julieta',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      enabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _openModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF043259),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Selecionar Produtos',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Produtos Selecionados:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: produtosSelecionados.length,
                itemBuilder: (context, index) {
                  final produto = produtosSelecionados[index];
                  return ListTile(
                    title: Text(produto['descricao']),
                    subtitle: Text(
                        'Quantidade: ${produto['quantidade']}, Preço: R\$ ${produto['preco_custo_produto']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmação'),
                              content:
                                  const Text('Deseja remover este produto?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Remover'),
                                  onPressed: () {
                                    setState(() {
                                      produtosSelecionados.removeAt(index);
                                      atualizarTotal(); // Atualizar total após remover
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              CustomTextFormField(
                controller: totalController,
                label: 'Total',
                icon: Icons.attach_money,
                enabled: false,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await enviarDados();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dados enviados com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Navigator.of(context).pushNamed('/home');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Falha ao enviar dados: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 155, 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final Function(String)? onChanged;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class CustomTypeAheadField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Future<List<Map<String, dynamic>>> Function(String) suggestionsCallback;
  final void Function(Map<String, dynamic>) onSuggestionSelected;
  final Widget Function(BuildContext, Map<String, dynamic>) itemBuilder;

  const CustomTypeAheadField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.suggestionsCallback,
    required this.onSuggestionSelected,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, dynamic>>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
      ),
      suggestionsCallback: suggestionsCallback,
      onSuggestionSelected: onSuggestionSelected,
      itemBuilder: itemBuilder,
    );
  }
}
