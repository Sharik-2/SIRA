import '../main.dart';
import '../models/aprendiz.dart';

class AprendizService {
  Future<List<Aprendiz>> listar() async {
    final data = await supabase
        .from('aprendiz')
        .select()
        .order('id', ascending: false);
    return (data as List)
        .map((e) => Aprendiz.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> crear(Aprendiz aprendiz) async {
    await supabase.from('aprendiz').insert(aprendiz.toMap());
  }

  Future<void> actualizar(Aprendiz aprendiz) async {
    if (aprendiz.id == null) throw Exception('El aprendiz no tiene ID.');
    await supabase
        .from('aprendiz')
        .update(aprendiz.toMap())
        .eq('id', aprendiz.id!);
  }

  Future<void> eliminar(int id) async {
    await supabase.from('aprendiz').delete().eq('id', id);
  }
}
