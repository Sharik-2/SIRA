import 'package:flutter/material.dart';
import '../main.dart';
import '../models/aprendiz.dart';
import '../models/ciudad.dart';
import '../models/departamento.dart';
import '../services/aprendiz_service.dart';
import '../services/catalog_service.dart';
import 'aprendiz_form_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = AprendizService();
  final _catalog = CatalogService();
  final _search = TextEditingController();

  List<Aprendiz> _aprendices = [];
  List<Aprendiz> _filtered = [];
  Map<String, String> _depNames = {};
  Map<String, String> _cityNames = {};

  bool _loading = true;
  String? _error;

  int _selectedMenu = 0;

  @override
  void initState() {
    super.initState();
    _search.addListener(_filter);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.listar(),
        _catalog.getDepartamentos(),
      ]);

      final aprendices = results[0] as List<Aprendiz>;
      final departamentos = results[1] as List<Departamento>;

      final depNames = {for (final d in departamentos) d.codigo: d.nombre};

      final cities = <Ciudad>[];

      for (final d in departamentos) {
        try {
          cities.addAll(await _catalog.getCiudades(d.codigo));
        } catch (_) {}
      }

      final cityNames = {for (final c in cities) c.codigo: c.nombre};

      if (!mounted) return;

      setState(() {
        _aprendices = aprendices;
        _depNames = depNames;
        _cityNames = cityNames;
        _loading = false;
      });

      _filter();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'No se pudo cargar la información: $e';
      });
    }
  }

  void _filter() {
    final q = _search.text.trim().toLowerCase();

    setState(() {
      _filtered = q.isEmpty
          ? List.of(_aprendices)
          : _aprendices.where((a) {
              final text = [
                a.id,
                a.nombre1,
                a.nombre2,
                a.apellido1,
                a.apellido2,
                a.celular,
                a.email,
                _depNames[a.departamento],
                _cityNames[a.ciudad],
              ].join(' ').toLowerCase();

              return text.contains(q);
            }).toList();
    });
  }

  Future<void> _openForm([Aprendiz? aprendiz]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AprendizFormScreen(aprendiz: aprendiz),
      ),
    );

    if (changed == true) {
      _load();
    }
  }

  Future<void> _delete(Aprendiz a) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar aprendiz'),
        content: Text(
          '¿Está seguro de eliminar a ${a.nombre1} ${a.apellido1}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || a.id == null) return;

    try {
      await _service.eliminar(a.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aprendiz eliminado correctamente.'),
        ),
      );

      _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar: $e'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  void _selectMenu(int index) {
    setState(() {
      _selectedMenu = index;
    });

    // En móvil cerramos el Drawer automáticamente.
    if (MediaQuery.of(context).size.width < 900) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SIRA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: _selectedMenu == 0
          ? _buildAprendices()
          : _buildAdministrativosOperativos(),
    );
  }

  Widget _buildDrawer() {
    final email = supabase.auth.currentUser?.email ?? 'Usuario';

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              24,
              45,
              24,
              25,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.school_rounded,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'SIRA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: ListTile(
              selected: _selectedMenu == 0,
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              leading: const Icon(
                Icons.school_outlined,
              ),
              title: const Text(
                'Aprendices',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _selectMenu(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: ListTile(
              selected: _selectedMenu == 1,
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              leading: const Icon(
                Icons.admin_panel_settings_outlined,
              ),
              title: const Text(
                'Administrativos y Operativos',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _selectMenu(1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              0,
              10,
              15,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _logout,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAprendices() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestión de aprendices',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Registra, consulta, actualiza y elimina información de aprendices.',
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(
                          Icons.person_add_alt_1,
                        ),
                        label: const Text(
                          'Nuevo aprendiz',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(
                          hintText:
                              'Buscar por nombre, correo, celular, departamento o ciudad...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => _search.clear(),
                                  icon: const Icon(
                                    Icons.clear,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_loading)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 14),
                              Text(
                                'Cargando aprendices...',
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_error != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 46,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _load,
                              icon: const Icon(
                                Icons.refresh,
                              ),
                              label: const Text(
                                'Reintentar',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_filtered.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(42),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 60,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _aprendices.isEmpty
                                  ? 'No hay aprendices registrados'
                                  : 'No se encontraron resultados',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _aprendices.isEmpty
                                  ? 'Registra el primer aprendiz para comenzar.'
                                  : 'Prueba con otro término de búsqueda.',
                            ),
                            if (_aprendices.isEmpty) ...[
                              const SizedBox(height: 18),
                              FilledButton.icon(
                                onPressed: () => _openForm(),
                                icon: const Icon(
                                  Icons.person_add,
                                ),
                                label: const Text(
                                  'Registrar aprendiz',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 850) {
                            return Column(
                              children: _filtered.map(_mobileCard).toList(),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: Text('ID'),
                                ),
                                DataColumn(
                                  label: Text('Aprendiz'),
                                ),
                                DataColumn(
                                  label: Text('Celular'),
                                ),
                                DataColumn(
                                  label: Text('Correo'),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Departamento',
                                  ),
                                ),
                                DataColumn(
                                  label: Text('Ciudad'),
                                ),
                                DataColumn(
                                  label: Text('Acciones'),
                                ),
                              ],
                              rows: _filtered.map((a) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${a.id ?? '-'}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${a.nombre1} ${a.apellido1}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(a.celular),
                                    ),
                                    DataCell(
                                      Text(a.email),
                                    ),
                                    DataCell(
                                      Text(
                                        _depNames[a.departamento] ??
                                            a.departamento,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _cityNames[a.ciudad] ?? a.ciudad,
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Editar',
                                            onPressed: () => _openForm(a),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Eliminar',
                                            onPressed: () => _delete(a),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: ${_filtered.length} ${_filtered.length == 1 ? 'aprendiz' : 'aprendices'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrativosOperativos() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(45),
              child: Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Administrativos y Operativos',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'En esta sección se gestionarán los usuarios administrativos y operativos del sistema.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.people_alt),
                    label: const Text(
                      'Gestión de usuarios',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileCard(Aprendiz a) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 6,
      ),
      leading: CircleAvatar(
        child: Text(
          a.nombre1.isEmpty ? '?' : a.nombre1[0].toUpperCase(),
        ),
      ),
      title: Text(
        '${a.nombre1} ${a.apellido1}',
      ),
      subtitle: Text(
        '${a.email}\n'
        '${_cityNames[a.ciudad] ?? a.ciudad}, '
        '${_depNames[a.departamento] ?? a.departamento}',
      ),
      isThreeLine: true,
      trailing: Wrap(
        spacing: 0,
        children: [
          IconButton(
            onPressed: () => _openForm(a),
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
          IconButton(
            onPressed: () => _delete(a),
            icon: const Icon(
              Icons.delete_outline,
            ),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
