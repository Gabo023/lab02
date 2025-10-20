import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Paquete para formatear la fecha

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Calificaciones',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark, // Tema oscuro para mejor contraste
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
      home: const GradeCalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  // Clave para manejar el estado del formulario y la validación
  final _formKey = GlobalKey<FormState>();

  // Lista de estudiantes para el Picker/Dropdown
  final List<String> _students = [
    'Ana García',
    'Luis Pérez',
    'Sofía Torres',
    'Carlos Ruiz',
    'Elena Morales',
  ];
  String? _selectedStudent;
  DateTime? _selectedDate;

  // Controladores para los campos de texto
  final _seguimiento1Controller = TextEditingController();
  final _examen1Controller = TextEditingController();
  final _seguimiento2Controller = TextEditingController();
  final _examen2Controller = TextEditingController();

  // Variables para almacenar los resultados
  double _notaParcial1 = 0.0;
  double _notaParcial2 = 0.0;
  double _notaFinal = 0.0;
  String _estado = '';

  @override
  void dispose() {
    // Limpiar los controladores cuando el widget se destruye para liberar memoria
    _seguimiento1Controller.dispose();
    _examen1Controller.dispose();
    _seguimiento2Controller.dispose();
    _examen2Controller.dispose();
    super.dispose();
  }

  // --- LÓGICA DE LA APLICACIÓN ---

  void _calculateAndShowResults() {
    // 1. Validar que los campos del formulario y los pickers estén correctos
    if (_selectedStudent == null) {
      _showErrorSnackbar('Por favor, seleccione un estudiante.');
      return;
    }
    if (_selectedDate == null) {
      _showErrorSnackbar('Por favor, seleccione una fecha.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackbar('Por favor, corrija los errores en las notas.');
      return;
    }

    // 2. Obtener y parsear los valores de los controladores
    final seg1 = double.parse(_seguimiento1Controller.text);
    final ex1 = double.parse(_examen1Controller.text);
    final seg2 = double.parse(_seguimiento2Controller.text);
    final ex2 = double.parse(_examen2Controller.text);

    // 3. Realizar los cálculos según las ponderaciones
    final parcial1 = (seg1 * 0.3) + (ex1 * 0.2);
    final parcial2 = (seg2 * 0.3) + (ex2 * 0.2);
    final notaFinal = parcial1 + parcial2;

    // 4. Determinar el estado del estudiante
    String estado;
    if (notaFinal >= 7) {
      estado = 'APROBADO';
    } else if (notaFinal >= 5) {
      estado = 'COMPLEMENTARIO';
    } else {
      estado = 'REPROBADO';
    }

    // 5. Actualizar el estado del widget para mostrar los resultados
    setState(() {
      _notaParcial1 = parcial1;
      _notaParcial2 = parcial2;
      _notaFinal = notaFinal;
      _estado = estado;
    });

    // 6. Mostrar el diálogo de alerta con el resumen
    _showResultDialog();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showResultDialog() {
    // Formatear los resultados para mostrarlos con 2 decimales
    final formattedParcial1 = _notaParcial1.toStringAsFixed(2);
    final formattedParcial2 = _notaParcial2.toStringAsFixed(2);
    final formattedFinal = _notaFinal.toStringAsFixed(2);
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);

    // Crear el contenido del mensaje de alerta
    final String alertContent =
        'Nombre: $_selectedStudent\n'
        'Fecha: $formattedDate\n\n'
        'Nota Parcial 1: $formattedParcial1\n'
        'Nota Parcial 2: $formattedParcial2\n\n'
        'Nota Final: $formattedFinal\n'
        'Estado: $_estado';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resumen de Calificaciones'),
          content: Text(alertContent),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- INTERFAZ DE USUARIO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificaciones UISRAEL'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- seccion de formulario de datos ---
              _buildSectionTitle('Datos del Estudiante'),
              const SizedBox(height: 12),
              _buildStudentDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 24),

              // --- seccion para el primer pacial ---
              _buildSectionTitle('Primer Parcial'),
              const SizedBox(height: 12),
              _buildGradeTextField(
                _seguimiento1Controller,
                'Nota Seguimiento 1 (30%)',
              ),
              const SizedBox(height: 16),
              _buildGradeTextField(_examen1Controller, 'Nota Examen 1 (20%)'),
              const SizedBox(height: 24),

              // --- sección para el segundo parcial ---
              _buildSectionTitle('Segundo Parcial'),
              const SizedBox(height: 12),
              _buildGradeTextField(
                _seguimiento2Controller,
                'Nota Seguimiento 2 (30%)',
              ),
              const SizedBox(height: 16),
              _buildGradeTextField(_examen2Controller, 'Nota Examen 2 (20%)'),
              const SizedBox(height: 30),

              // --- El botón de calculo ---
              ElevatedButton(
                onPressed: _calculateAndShowResults,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text(
                  'Calcular Notas',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStudentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Seleccione Estudiante',
        prefixIcon: Icon(Icons.person),
      ),
      value: _selectedStudent,
      items: _students.map((String student) {
        return DropdownMenuItem<String>(value: student, child: Text(student));
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedStudent = newValue;
        });
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _selectedDate == null
                ? 'Seleccione una fecha'
                : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildGradeTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.grade),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Validador para asegurar que el dato sea numérico y esté en el rango correcto
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        final n = num.tryParse(value);
        if (n == null) {
          return 'Por favor, ingrese un número válido';
        }
        if (n < 0 || n > 10) {
          return 'La nota debe estar entre 0 y 10';
        }
        return null; // El valor es válido
      },
    );
  }
}
