import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import '../class/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assinatura.dart';

class AbastecimentoPage extends StatefulWidget {
  const AbastecimentoPage({super.key});

  @override
  State<AbastecimentoPage> createState() => _AbastecimentoPageState();
}

class _AbastecimentoPageState extends State<AbastecimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _veiculoController = TextEditingController();
  final _placaController = TextEditingController();
  final _litrosController = TextEditingController();
  final _kmController = TextEditingController();
  final _contBombaController = TextEditingController();
  final _localController = TextEditingController();
  final _motoristaController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<Map<String, dynamic>> _placas = [];
  List<Map<String, dynamic>> _depositos = [];
  List<Map<String, dynamic>> _funcionarios = [];
  bool _isLoading = false;
  bool _isLoadingDepositos = false;
  bool _isLoadingFuncionarios = false;
  Uint8List? _assinaturaData;
  String? _numeroDocumento;
  String? _codigoDepositoSelecionado;
  String? _codigoFuncionarioSelecionado;

  // Cores personalizadas
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryColor = Color(0xFF2962FF);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF263238);
  static const Color lightGrey = Color(0xFFECEFF1);

  @override
  void initState() {
    super.initState();
    _carregarPlacas();
    _carregarDepositos();
    _carregarFuncionarios();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _carregarPlacas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? codigoEmpresa = prefs.getString('codigo_empresa');
      print(codigoEmpresa);


      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/get-placas'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'codigo_empresa': '0084',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _placas = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        print(response.body);
        _showError('Erro ao carregar placas');
      }
    } catch (e) {
      print(e);
      _showError('Erro ao carregar placas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarDepositos() async {
    setState(() {
      _isLoadingDepositos = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? codigoEmpresa = prefs.getString('codigo_empresa');
      print(codigoEmpresa);

      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/get-deposito'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'codigo_empresa': '0084',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _depositos = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        print(response.body);
        _showError('Erro ao carregar depósitos');
      }
    } catch (e) {
      print(e);
      _showError('Erro ao carregar depósitos: $e');
    } finally {
      setState(() {
        _isLoadingDepositos = false;
      });
    }
  }

  Future<void> _carregarFuncionarios() async {
    setState(() {
      _isLoadingFuncionarios = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/get-funcionarios'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'codigo_empresa': '0084',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _funcionarios = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        print(response.body);
        _showError('Erro ao carregar funcionários');
      }
    } catch (e) {
      print(e);
      _showError('Erro ao carregar funcionários: $e');
    } finally {
      setState(() {
        _isLoadingFuncionarios = false;
      });
    }
  }

  Future<String> _getToken() async {
    // Implementar a lógica para obter o token
    return '';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _abrirTelaAssinatura() async {
    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (context) => const AssinaturaPage()),
    );

    if (result != null) {
      setState(() {
        _assinaturaData = result;
      });
    }
  }

  Future<void> _salvarAbastecimento() async {
    if (_formKey.currentState!.validate()) {
      if (_assinaturaData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, faça sua assinatura'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_numeroDocumento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um local para obter o número do documento'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_codigoFuncionarioSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um motorista'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_codigoDepositoSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um local'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('token');
        final String? codigoEmpresa = prefs.getString('codigo_empresa');

        // Converter a assinatura para base64
        final String assinaturaBase64 = base64Encode(_assinaturaData!);

        final response = await http.post(
          Uri.parse('${ApiConfig.apiUrl}/store-abastecimento'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'codigo_empresa': '0084',
            'numero_documento': _numeroDocumento,
            'placa_veiculo': _placaController.text,
            'data': DateFormat('yyyy-MM-dd').format(_selectedDate),
            'hora': _selectedTime.format(context),
            'litros': _litrosController.text,
            'km': _kmController.text,
            'cont_bomba': _contBombaController.text,
            'local': _codigoDepositoSelecionado,
            'motorista': _codigoFuncionarioSelecionado,
            'assinatura': assinaturaBase64,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abastecimento registrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          print(response.body);
          _showError('Erro ao registrar abastecimento');
        }
      } catch (e) {
        print(e);
        _showError('Erro ao registrar abastecimento: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _obterNumeroDocumento(String codigoDeposito) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/get-doc-number'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'codigo_empresa': '0084',
          'codigo_deposito': codigoDeposito,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        
        // Parse do JSON retornado pela API
        final Map<String, dynamic> data = json.decode(response.body);
        final String numeroDocumento = data['numero_documento'].toString();
        
        setState(() {
          _numeroDocumento = (int.parse(numeroDocumento) + 1).toString().padLeft(8, '0');
        });
      } else {
        print(response.body);
        _showError('Erro ao obter número do documento');
      }
    } catch (e) {
      print(e);
      _showError('Erro ao obter número do documento: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Cadastro de Abastecimento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_gas_station,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nº ${_numeroDocumento ?? "..."}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPlacaSearchField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeField(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _litrosController,
                            label: 'Litros',
                            icon: Icons.water_drop,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _placaController,
                            label: 'Placa',
                            icon: Icons.credit_card,
                            textCapitalization: TextCapitalization.characters,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _kmController,
                            label: 'KM',
                            icon: Icons.speed,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _contBombaController,
                            label: 'Nº Cont. Bomba',
                            icon: Icons.confirmation_number,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDepositoSearchField(),
                    const SizedBox(height: 16),
                    _buildFuncionarioSearchField(),
                    const SizedBox(height: 24),
                    _buildAssinaturaButton(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _salvarAbastecimento,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'SALVAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacaSearchField() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: _veiculoController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Buscar Veículo',
            prefixIcon: const Icon(Icons.search, color: primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : null,
          ),
        );
      },
      suggestionsCallback: (pattern) {
        return _placas
            .where((placa) =>
                placa['placa_veiculo'].toString().toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, Map<String, dynamic> suggestion) {
        return ListTile(
          title: Text(suggestion['placa_veiculo']),
          subtitle: suggestion['categoria_veiculo'] != null && suggestion['categoria_veiculo'].isNotEmpty
              ? Text(suggestion['categoria_veiculo'])
              : null,
        );
      },
      onSelected: (Map<String, dynamic> suggestion) {
        _veiculoController.text = suggestion['placa_veiculo'];
        _placaController.text = suggestion['placa_veiculo'];
      },
    );
  }

  Widget _buildDepositoSearchField() {
    return DropdownButtonFormField<String>(
      value: _codigoDepositoSelecionado,
      decoration: InputDecoration(
        labelText: 'Local',
        prefixIcon: const Icon(Icons.location_on, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: _isLoadingDepositos
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : null,
      ),
      items: _depositos.map<DropdownMenuItem<String>>((Map<String, dynamic> deposito) {
        return DropdownMenuItem<String>(
          value: deposito['codigo_deposito'].toString(),
          child: Text(
            deposito['razao_social'].toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _isLoadingDepositos ? null : (String? value) {
        if (value != null) {
          setState(() {
            _codigoDepositoSelecionado = value;
            // Encontrar o depósito selecionado para atualizar o controller
            final depositoSelecionado = _depositos.firstWhere(
              (deposito) => deposito['codigo_deposito'].toString() == value,
            );
            _localController.text = depositoSelecionado['razao_social'].toString();
          });
          _obterNumeroDocumento(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione um local';
        }
        return null;
      },
    );
  }

  Widget _buildFuncionarioSearchField() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: _motoristaController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Motorista / Operador',
            prefixIcon: const Icon(Icons.person, color: primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: _isLoadingFuncionarios
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : null,
          ),
        );
      },
      suggestionsCallback: (pattern) {
        return _funcionarios
            .where((funcionario) =>
                funcionario['nome_funcionario'].toString().toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, Map<String, dynamic> suggestion) {
        return ListTile(
          title: Text(suggestion['nome_funcionario']),
          subtitle: Text('Código: ${suggestion['codigo_funcionario']}'),
        );
      },
      onSelected: (Map<String, dynamic> suggestion) {
        _motoristaController.text = suggestion['nome_funcionario'];
        _codigoFuncionarioSelecionado = suggestion['codigo_funcionario'];
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Data',
        prefixIcon: const Icon(Icons.calendar_today, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      controller: TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Hora',
        prefixIcon: const Icon(Icons.access_time, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      controller: TextEditingController(
        text: _selectedTime.format(context),
      ),
      onTap: () => _selectTime(context),
    );
  }

  Widget _buildAssinaturaButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assinatura',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: lightGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _assinaturaData != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _assinaturaData!,
                    fit: BoxFit.contain,
                  ),
                )
              : Center(
                  child: TextButton.icon(
                    onPressed: _abrirTelaAssinatura,
                    icon: const Icon(Icons.draw, color: primaryColor),
                    label: const Text(
                      'Assinar',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
} 