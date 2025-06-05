import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  // --- Controladores para los campos de texto ---
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _nombrePacienteController = TextEditingController();
  final TextEditingController _cedulaPacienteController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _nombreBeneficiarioController = TextEditingController();
  final TextEditingController _cedulaBeneficiarioController = TextEditingController();
  final TextEditingController _numeroContactoController = TextEditingController();
  final TextEditingController _numeroContactoAdicionalController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _requerimientoController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _proveedorSaludController = TextEditingController();

  // --- Variables para los DropdownButtons ---
  String _tipoAseguradoSelectedValue = 'Jubilado Cobertura 100%';
  String _primeraConsultaSelectedValue = 'No';

  final ScreenshotController screenshotController = ScreenshotController();

  final List<String> _tipoAseguradoOptions = [
    'Jubilado Cobertura 100%',
    'Activo',
    'Sobreviviente'
  ];
  final List<String> _primeraConsultaOptions = ['Si', 'No'];

  // Ancho para la columna de etiquetas. Se mantiene el valor de 280.0
  static const double _labelColumnWidth = 280.0;

  // Nuevo padding a la izquierda para desplazar todo el contenido
  static const double _contentLeftPadding = 60.0; // AJUSTADO de 50.0 a 60.0

  @override
  void dispose() {
    _estadoController.dispose();
    _nombrePacienteController.dispose();
    _cedulaPacienteController.dispose();
    _direccionController.dispose();
    _nombreBeneficiarioController.dispose();
    _cedulaBeneficiarioController.dispose();
    _numeroContactoController.dispose();
    _numeroContactoAdicionalController.dispose();
    _diagnosticoController.dispose();
    _requerimientoController.dispose();
    _especialidadController.dispose();
    _proveedorSaludController.dispose();
    super.dispose();
  }

  Future<void> _generateAndSaveImage() async {
    if (!kIsWeb) {
      if (Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de almacenamiento denegado')),
            );
          }
          return;
        }
      }
    }

    await screenshotController.captureFromWidget(
      InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.white,
          child: Stack(
            children: [
              // Marca de agua de la bandera
              Center(
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/bandera_zulia.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Añadimos un Padding adicional a la izquierda para desplazar el contenido
              Padding(
                padding: const EdgeInsets.only(left: _contentLeftPadding, right: 20.0, top: 20.0, bottom: 20.0), // Ajuste aquí
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Center(
                      child: Text(
                        "SOLICITUD DE CONSULTA / EXÁMEN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInfoRow('Estado:', _estadoController.text),
                    _buildInfoRow('Nombre del paciente:', _nombrePacienteController.text),
                    _buildInfoRow('Cédula:', _cedulaPacienteController.text),
                    _buildInfoRow('Dirección:', _direccionController.text),
                    _buildInfoRow('Nombre del beneficiario:', _nombreBeneficiarioController.text),
                    _buildInfoRow('Cédula del beneficiario:', _cedulaBeneficiarioController.text),
                    _buildInfoRow('Tipo de asegurado:', _tipoAseguradoSelectedValue),
                    _buildInfoRow('Número Contacto:', _numeroContactoController.text),
                    _buildInfoRow('Número contacto adicional opcional:', _numeroContactoAdicionalController.text),
                    _buildInfoRow('Diagnóstico:', _diagnosticoController.text),
                    _buildInfoRow('Requerimiento:', _requerimientoController.text),
                    _buildInfoRow('Especialidad:', _especialidadController.text),
                    _buildInfoRow('Primera Consulta:', _primeraConsultaSelectedValue),
                    _buildInfoRow('Proveedor de servicios de salud:', _proveedorSaludController.text),

                    const SizedBox(height: 30),

                    const Text(
                      "Este Impreso se debe enviar con la documentación requerida, cuando aplique.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      pixelRatio: 2.0,
    ).then((Uint8List? imageBytes) async {
      if (imageBytes != null) {
        if (kIsWeb) {
          final blob = html.Blob([imageBytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = 'solicitud_consulta_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.jpg';
          html.document.body?.children.add(anchor);
          anchor.click();
          html.document.body?.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imagen guardada en Descargas')),
            );
          }
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final String filePath = '${directory.path}/solicitud_consulta_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.jpg';
          final file = File(filePath);
          await file.writeAsBytes(imageBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imagen guardada en: $filePath')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al generar la imagen')),
          );
        }
      }
    }).catchError((onError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar el widget: $onError')),
        );
      }
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelColumnWidth,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF800020)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de Solicitud',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTextField(
              controller: _estadoController,
              labelText: 'Estado',
              maxLength: 15,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _nombrePacienteController,
              labelText: 'Nombre del paciente',
              maxLength: 30,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _cedulaPacienteController,
              labelText: 'Cédula',
              maxLength: 15,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _direccionController,
              labelText: 'Dirección',
              maxLength: 30,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _nombreBeneficiarioController,
              labelText: 'Nombre del beneficiario',
              maxLength: 30,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _cedulaBeneficiarioController,
              labelText: 'Cédula del beneficiario',
              maxLength: 15,
            ),
            _buildSpacer(),

            _buildDropdownField(
              labelText: 'Tipo de asegurado',
              value: _tipoAseguradoSelectedValue,
              items: _tipoAseguradoOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tipoAseguradoSelectedValue = newValue!;
                });
              },
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _numeroContactoController,
              labelText: 'Número Contacto',
              maxLength: 12,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _numeroContactoAdicionalController,
              labelText: 'Número contacto adicional opcional',
              maxLength: 12,
              isOptional: true,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _diagnosticoController,
              labelText: 'Diagnóstico',
              maxLength: 30,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _requerimientoController,
              labelText: 'Requerimiento',
              maxLength: 30,
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _especialidadController,
              labelText: 'Especialidad',
              maxLength: 25,
            ),
            _buildSpacer(),

            _buildDropdownField(
              labelText: 'Primera Consulta',
              value: _primeraConsultaSelectedValue,
              items: _primeraConsultaOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _primeraConsultaSelectedValue = newValue!;
                });
              },
            ),
            _buildSpacer(),

            _buildTextField(
              controller: _proveedorSaludController,
              labelText: 'Proveedor de servicios de salud',
              maxLength: 40,
            ),
            _buildSpacer(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateAndSaveImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Generar JPG'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _clearAllFields();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Campos limpiados para nueva solicitud')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Nueva Solicitud'),
                  ),
                ),
              ],
            ),
            _buildSpacer(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Salir'),
              ),
            ),
            _buildSpacer(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isOptional = false,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: isOptional ? '$labelText (Opcional)' : labelText,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.orange.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        counterText: '',
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.orange.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      isEmpty: value == '',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          isExpanded: true,
          onChanged: onChanged,
          dropdownColor: Colors.white,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.black87),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSpacer({double height = 15.0}) {
    return SizedBox(height: height);
  }

  void _clearAllFields() {
    _estadoController.clear();
    _nombrePacienteController.clear();
    _cedulaPacienteController.clear();
    _direccionController.clear();
    _nombreBeneficiarioController.clear();
    _cedulaBeneficiarioController.clear();
    _numeroContactoController.clear();
    _numeroContactoAdicionalController.clear();
    _diagnosticoController.clear();
    _requerimientoController.clear();
    _especialidadController.clear();
    _proveedorSaludController.clear();

    setState(() {
      _tipoAseguradoSelectedValue = 'Jubilado Cobertura 100%';
      _primeraConsultaSelectedValue = 'No';
    });
  }
}