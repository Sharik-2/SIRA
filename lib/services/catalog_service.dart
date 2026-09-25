import '../main.dart';
import '../models/ciudad.dart';
import '../models/departamento.dart';

class CatalogService {
  Future<List<Departamento>> getDepartamentos() async {
    final data = await supabase
        .from('departamento')
        .select('codigo,nombre')
        .order('nombre');
    return (data as List)
        .map((e) => Departamento.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Ciudad>> getCiudades(String departamento) async {
    final data = await supabase
        .from('ciudad')
        .select('departamento,codigo,nombre')
        .eq('departamento', departamento)
        .order('nombre');
    return (data as List)
        .map((e) => Ciudad.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
