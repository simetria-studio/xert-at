import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:xerp_motor/class/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final TextEditingController _numeroRomaneioController =
      TextEditingController();
  final String _codigoEmpresa = "0084";
  Map<String, dynamic>? ticketData;
  bool isLoading = false;

  Future<void> fetchTicket(String numeroRomaneio) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/get-ticket'),
      body: json.encode({
        "numero_romaneio": numeroRomaneio,
        "codigo_empresa": _codigoEmpresa
      }),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      print(responseData);
      setState(() {
        ticketData = responseData;
      });
    } else {
      throw Exception("Falha ao carregar os tickets");
    }

    setState(() {
      isLoading = false;
    });
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
            TextField(
              controller: _numeroRomaneioController,
              decoration: const InputDecoration(
                labelText: 'Número do Romaneio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchTicket(_numeroRomaneioController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF043259),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buscar Ticket',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ticketData != null
                    ? Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text(
                                  'Número da C.I.: ${ticketData!['ticket']['numero_romaneio']}'),
                              subtitle: Text(
                                  'Cliente: ${ticketData!['cliente']['razao_social']}'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TicketDetailsPage(ticket: ticketData!),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
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
    final ticketDetails = ticket['ticket'] ?? {};
    final clienteDetails = ticket['cliente'] ?? {};
    final materiais = ticket['mticket'] ?? [];

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
              Text('Número da C.I.: ${ticketDetails['numero_romaneio'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Cliente: ${clienteDetails['razao_social'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Data de Entrada: ${ticketDetails['data_romaneio'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Motorista: ${ticketDetails['codigo_transportador'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Peso Líquido: ${ticketDetails['peso_liquido'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Volume: ${ticketDetails['volume'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Total: R\$ ${ticketDetails['valor_total'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Observações: ${ticketDetails['observacao'] ?? ''}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const Text('Produtos Selecionados:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materiais.length,
                itemBuilder: (context, index) {
                  final produto = materiais[index];
                  return ListTile(
                    title: Text(produto['codigo_produto'] ?? ''),
                    subtitle: Text(
                        'Quantidade: ${produto['qtde_operador'] ?? ''}, Preço: R\$ ${produto['preco_unitario'] ?? ''}'),
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
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  'Número da C.I.: ${ticket['ticket']['numero_romaneio'] ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Text('Cliente: ${ticket['cliente']['razao_social'] ?? ''}'),
              // Incluir mais detalhes conforme necessário
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
