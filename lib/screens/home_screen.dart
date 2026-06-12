import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables de estado
  String? _nombreArchivo;
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _modeloSeleccionado = 'base (balanceado)';
  bool _usarIA = false;

  final List<String> _modelos = [
    'tiny (rápido)',
    'base (balanceado)',
    'small (mejor calidad)',
    'medium (alta calidad)',
  ];

  // Nueva variable para guardar la ruta completa del archivo
  String? _rutaArchivo;
  bool _isLoading = false;

  // ── FUNCIÓN: Seleccionar Archivo ──
  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp3', 'wav', 'm4a', 'ogg', 'flac', 'aac', // Audios
        'mp4', 'mkv', 'avi', 'mov', // Videos
      ],
    );

    if (result != null) {
      setState(() {
        _nombreArchivo = result.files.single.name;
        _rutaArchivo = result.files.single.path;
      });
    }
  }

  // ── FUNCIÓN: Validar e Iniciar ──
  void _iniciarTranscripcion() {
    if (_rutaArchivo == null) {
      _mostrarAlerta(
        'Falta archivo',
        'Por favor seleccioná un audio o video para transcribir.',
      );
      return;
    }
    if (_tituloController.text.trim().isEmpty) {
      _mostrarAlerta(
        'Falta título',
        'Por favor ingresá un título para tu documento.',
      );
      return;
    }
    if (_usarIA && _keyController.text.trim().isEmpty) {
      _mostrarAlerta(
        'Falta API Key',
        'Activaste la mejora con IA. Necesitamos tu API Key de Groq para continuar.',
      );
      return;
    }

    // Si pasa todas las validaciones, mostramos un mensaje temporal de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Todo listo! Conectando con la API...'),
        backgroundColor: AppColors.success,
      ),
    );

    // Acá luego llamaremos a la API de Groq
  }

  // ── FUNCIÓN: Mostrar Alertas ──
  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          titulo,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(mensaje, style: const TextStyle(color: AppColors.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Container(
              width: double.infinity,
              color: AppColors.card,
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 24.0,
              ),
              child: const Text(
                '✦  Transcriptor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  fontFamily: 'Georgia',
                ),
              ),
            ),

            // ── BODY (Scrollable) ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TARJETA 1: Archivo
                    _buildCard(
                      title: '1 · Archivo de Audio o Video',
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _nombreArchivo ?? 'Ningún archivo seleccionado',
                              style: TextStyle(
                                color: _nombreArchivo == null
                                    ? AppColors.subtext
                                    : AppColors.text,
                                fontStyle: _nombreArchivo == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed:
                                _seleccionarArchivo, // <-- CONECTADO AQUÍ
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.folder_open, size: 18),
                            label: const Text(
                              'Elegir',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TARJETA 2: Detalles y Modelo
                    _buildCard(
                      title: '2 · Configuración de Transcripción',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _tituloController,
                            style: const TextStyle(color: AppColors.text),
                            decoration: InputDecoration(
                              hintText: 'Ej: Clase 3 Economía',
                              hintStyle: const TextStyle(
                                color: AppColors.subtext,
                              ),
                              filled: true,
                              fillColor: AppColors.card2,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.card2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _modeloSeleccionado,
                                isExpanded: true,
                                dropdownColor: AppColors.card2,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 15,
                                ),
                                items: _modelos.map((String modelo) {
                                  return DropdownMenuItem<String>(
                                    value: modelo,
                                    child: Text(modelo),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(
                                      () => _modeloSeleccionado = newValue,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TARJETA 3: Mejora con IA
                    _buildCard(
                      title: '3 · Mejora con IA (Groq)',
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Activar corrección inteligente',
                                style: TextStyle(color: AppColors.text),
                              ),
                              Switch(
                                value: _usarIA,
                                activeColor: AppColors.accent,
                                onChanged: (value) {
                                  setState(() => _usarIA = value);
                                },
                              ),
                            ],
                          ),
                          if (_usarIA) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _keyController,
                              obscureText: true,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontFamily: 'monospace',
                              ),
                              decoration: InputDecoration(
                                hintText: 'API Key (gsk_...)',
                                hintStyle: const TextStyle(
                                  color: AppColors.subtext,
                                ),
                                filled: true,
                                fillColor: AppColors.card2,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // BOTÓN PRINCIPAL
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _iniciarTranscripcion, // <-- CONECTADO AQUÍ
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text(
                          'Transcribir y guardar PDF',
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

  // Widget auxiliar para crear las tarjetas de forma limpia
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
