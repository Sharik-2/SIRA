import 'package:flutter/material.dart';
import '../models/aprendiz.dart';
import '../models/ciudad.dart';
import '../models/departamento.dart';
import '../services/aprendiz_service.dart';
import '../services/catalog_service.dart';
import '../widgets/app_text_field.dart';

class AprendizFormScreen extends StatefulWidget {
  final Aprendiz? aprendiz;

  const AprendizFormScreen({super.key, this.aprendiz});

  @override
  State<AprendizFormScreen> createState() => _AprendizFormScreenState();
}

class _AprendizFormScreenState extends State<AprendizFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre1 = TextEditingController();
  final _nombre2 = TextEditingController();
  final _apellido1 = TextEditingController();
  final _apellido2 = TextEditingController();
  final _celular = TextEditingController();
  final _email = TextEditingController();
  final _catalog = CatalogService();
  final _service = AprendizService();

  List<Departamento> _departamentos = [];
  List<Ciudad> _ciudades = [];
  String? _departamento;
  String? _ciudad;
  bool _loadingCatalogos = true;
  bool _loadingCiudades = false;
  bool _saving = false;

  bool get _editing => widget.aprendiz != null;

  @override
  void initState() {
    super.initState();
    final a = widget.aprendiz;
    if (a != null) {
      _nombre1.text = a.nombre1;
      _nombre2.text = a.nombre2 ?? '';
      _apellido1.text = a.apellido1;
      _apellido2.text = a.apellido2 ?? '';
      _celular.text = a.celular;
      _email.text = a.email;
      _departamento = a.departamento;
      _ciudad = a.ciudad;
    }
    _loadDepartamentos();
  }

  @override
  void dispose() {
    for (final c in [
      _nombre1,
      _nombre2,
      _apellido1,
      _apellido2,
      _celular,
      _email,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDepartamentos() async {
    try {
      final data = await _catalog.getDepartamentos();
      if (!mounted) return;
      setState(() {
        _departamentos = data;
        _loadingCatalogos = false;
      });
      if (_departamento != null) await _loadCiudades(_departamento!);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCatalogos = false);
      _showError('No se pudieron cargar los departamentos: $e');
    }
  }

  Future<void> _loadCiudades(String codigoDepartamento) async {
    setState(() {
      _loadingCiudades = true;
      _ciudades = [];
      _ciudad = null;
    });
    try {
      final data = await _catalog.getCiudades(codigoDepartamento);
      if (!mounted) return;
      final originalCity = widget.aprendiz?.ciudad;
      setState(() {
        _ciudades = data;
        _ciudad = originalCity != null &&
                data.any((c) => c.codigo == originalCity)
            ? originalCity
            : null;
        _loadingCiudades = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCiudades = false);
      _showError('No se pudieron cargar las ciudades: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departamento == null || _ciudad == null) {
      _showError('Seleccione departamento y ciudad.');
      return;
    }

    setState(() => _saving = true);
    final aprendiz = Aprendiz(
      id: widget.aprendiz?.id,
      nombre1: _nombre1.text,
      nombre2: _nombre2.text,
      apellido1: _apellido1.text,
      apellido2: _apellido2.text,
      celular: _celular.text,
      email: _email.text,
      departamento: _departamento!,
      ciudad: _ciudad!,
    );

    try {
      if (_editing) {
        await _service.actualizar(aprendiz);
      } else {
        await _service.crear(aprendiz);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editing
              ? 'Aprendiz actualizado correctamente.'
              : 'Aprendiz registrado correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError('No se pudo guardar el aprendiz: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Editar aprendiz' : 'Registrar aprendiz'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editing ? 'Actualizar información' : 'Nuevo aprendiz',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Los campos marcados con * son obligatorios.'),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final twoColumns = constraints.maxWidth >= 700;
                          final width = twoColumns
                              ? (constraints.maxWidth - 16) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width: width,
                                child: AppTextField(
                                  controller: _nombre1,
                                  label: 'Primer nombre',
                                  icon: Icons.person_outline,
                                  requiredField: true,
                                  maxLength: 50,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: AppTextField(
                                  controller: _nombre2,
                                  label: 'Segundo nombre',
                                  icon: Icons.person_outline,
                                  maxLength: 50,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: AppTextField(
                                  controller: _apellido1,
                                  label: 'Primer apellido',
                                  icon: Icons.badge_outlined,
                                  requiredField: true,
                                  maxLength: 50,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: AppTextField(
                                  controller: _apellido2,
                                  label: 'Segundo apellido',
                                  icon: Icons.badge_outlined,
                                  maxLength: 50,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: AppTextField(
                                  controller: _celular,
                                  label: 'Celular',
                                  icon: Icons.phone_outlined,
                                  requiredField: true,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 20,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico *',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Este campo es obligatorio';
                                    }
                                    if (!v.contains('@')) return 'Correo no válido';
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: _buildDepartamentoDropdown(),
                              ),
                              SizedBox(
                                width: width,
                                child: _buildCiudadDropdown(),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 12,
                          children: [
                            OutlinedButton(
                              onPressed: _saving ? null : () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(_saving ? 'Guardando...' : 'Guardar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartamentoDropdown() {
    return DropdownButtonFormField<String>(
      value: _departamento,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Departamento *',
        prefixIcon: Icon(Icons.map_outlined),
      ),
      hint: Text(_loadingCatalogos ? 'Cargando...' : 'Seleccione un departamento'),
      items: _departamentos
          .map(
            (d) => DropdownMenuItem(
              value: d.codigo,
              child: Text('${d.codigo} - ${d.nombre}'),
            ),
          )
          .toList(),
      onChanged: _loadingCatalogos
          ? null
          : (value) {
              if (value == null) return;
              setState(() => _departamento = value);
              _loadCiudades(value);
            },
      validator: (value) => value == null ? 'Seleccione un departamento' : null,
    );
  }

  Widget _buildCiudadDropdown() {
    return DropdownButtonFormField<String>(
      value: _ciudad,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Ciudad *',
        prefixIcon: Icon(Icons.location_city_outlined),
      ),
      hint: Text(_loadingCiudades
          ? 'Cargando ciudades...'
          : _departamento == null
              ? 'Seleccione primero un departamento'
              : 'Seleccione una ciudad'),
      items: _ciudades
          .map(
            (c) => DropdownMenuItem(
              value: c.codigo,
              child: Text('${c.codigo} - ${c.nombre}'),
            ),
          )
          .toList(),
      onChanged: _departamento == null || _loadingCiudades
          ? null
          : (value) => setState(() => _ciudad = value),
      validator: (value) => value == null ? 'Seleccione una ciudad' : null,
    );
  }
}
