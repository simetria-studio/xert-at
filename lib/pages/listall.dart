import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xerp_motor/class/api_config.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TicketListAllPage extends StatefulWidget {
  const TicketListAllPage({super.key});

  @override
  _TicketListAllPageState createState() => _TicketListAllPageState();
}

class _TicketListAllPageState extends State<TicketListAllPage> {
  final String _codigoEmpresa = "0084";
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> tickets = [];
  bool isLoading = false;

  Future<void> fetchTickets({String? numeroRomaneio}) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-all-tickets'),
      body: json.encode({
        "codigo_empresa": _codigoEmpresa,
        if (numeroRomaneio != null) "numero_romaneio": numeroRomaneio,
      }),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List) {
        setState(() {
          tickets = List<Map<String, dynamic>>.from(responseData);
        });
      } else if (responseData is Map && responseData['tickets'] is List) {
        setState(() {
          tickets = List<Map<String, dynamic>>.from(responseData['tickets']);
        });
      } else {
        throw Exception(
            "Falha ao carregar os tickets: dados não são uma lista");
      }
    } else {
      throw Exception("Falha ao carregar os tickets");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF043259),
        title: const Text(
          'Listagem de Tickets',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Número do Romaneio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    fetchTickets(numeroRomaneio: _searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF043259),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Text(
                                'Número do Romaneio: ${ticket['numero_romaneio']}'),
                            subtitle: Text(
                                'Cliente: ${ticket['cliente']['razao_social']}'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TicketDetailsPage(ticket: ticket),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class TicketDetailsPage extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailsPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final ticketDetails = ticket ?? {};
    final clienteDetails = ticket['cliente'] ?? {};
    final depositoDetails = ticket['deposito'] ?? {};
    final List<dynamic> mticketDetails = ticket['mticket'] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF043259),
        title: const Text(
          'Detalhes do Ticket',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Número do Romaneio: ${ticketDetails['numero_romaneio'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Cliente: ${clienteDetails['razao_social'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Data de Romaneio: ${ticketDetails['data_romaneio'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Placa do Veículo: ${ticketDetails['placa_veiculo'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                  'Transportador: ${ticketDetails['codigo_transportador'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Observação: ${ticketDetails['observacao'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const Text('Detalhes do Depósito:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Nome Fantasia: ${depositoDetails['nome_fantasia'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              Text('Endereço: ${depositoDetails['endereco'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const Text('Produtos Selecionados:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mticketDetails.length,
                itemBuilder: (context, index) {
                  final produto = mticketDetails[index]['produto'] ?? {};
                  return ListTile(
                    title: Text(produto['descricao_produto'] ?? ''),
                    subtitle: Text(
                        'Quantidade: ${mticketDetails[index]['qtde_operador'] ?? ''}, Preço: R\$ ${mticketDetails[index]['preco_unitario'] ?? ''}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _printTicketDetails,
        backgroundColor: const Color(0xFF043259),
        child: const Icon(Icons.print),
      ),
    );
  }

  void _printTicketDetails() async {
    final ticketDetails = ticket ?? {};
    final clienteDetails = ticket['cliente'] ?? {};
    final depositoDetails = ticket['deposito'] ?? {};
    final List<dynamic> mticketDetails = ticket['mticket'] ?? [];

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  'Número do Romaneio: ${ticketDetails['numero_romaneio'] ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Text('Cliente: ${clienteDetails['razao_social'] ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Data de Romaneio: ${ticketDetails['data_romaneio'] ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Placa do Veículo: ${ticketDetails['placa_veiculo'] ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Transportador: ${ticketDetails['codigo_transportador'] ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Text('Observação: ${ticketDetails['observacao'] ?? ''}'),
              pw.SizedBox(height: 20),
              pw.Text('Detalhes do Depósito:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Nome Fantasia: ${depositoDetails['nome_fantasia'] ?? ''}'),
              pw.Text('Endereço: ${depositoDetails['endereco'] ?? ''}'),
              pw.SizedBox(height: 20),
              pw.Text('Produtos Selecionados:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...mticketDetails.map((item) {
                final produto = item['produto'] ?? {};
                return pw.Text(
                    '${produto['descricao_produto'] ?? ''}: Quantidade: ${item['qtde_operador'] ?? ''}, Preço: R\$ ${item['preco_unitario'] ?? ''}');
              }).toList(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
