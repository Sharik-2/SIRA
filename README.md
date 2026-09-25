# SIRA - Flutter + Supabase

Aplicación web para autenticación y CRUD de aprendices.

## 1. Crear proyecto
Si ya creaste este proyecto, no vuelvas a ejecutar `flutter create` encima. Si partes desde cero:

```bash
flutter create sira_flutter
cd sira_flutter
```

Reemplaza `pubspec.yaml` y la carpeta `lib` por los archivos de este proyecto.

## 2. Instalar dependencias

```bash
flutter pub get
```

## 3. Ejecutar

```bash
flutter run -d web-server
```

o:

```bash
flutter run -d chrome
```

## 4. Tablas esperadas
La aplicación usa:

- `aprendiz`: id, nombre1, nombre2, apellido1, apellido2, celular, email, departamento, ciudad.
- `departamento`: codigo, nombre.
- `ciudad`: departamento, codigo, nombre.

La ciudad se filtra por el código del departamento seleccionado.

## 5. Autenticación
La pantalla inicial utiliza Supabase Auth con correo y contraseña. Debe existir el usuario en:

Supabase Dashboard > Authentication > Users.

La aplicación no crea usuarios desde el cliente.

## 6. Permisos/RLS
Para que el CRUD funcione, las tablas deben estar expuestas por Data API y tener políticas RLS adecuadas para el rol `authenticated`. No uses una `service_role` key en Flutter.

Ejemplo conceptual para `aprendiz` si quieres que cualquier usuario autenticado pueda hacer CRUD:

```sql
alter table public.aprendiz enable row level security;

create policy "authenticated_select_aprendiz"
on public.aprendiz for select to authenticated using (true);

create policy "authenticated_insert_aprendiz"
on public.aprendiz for insert to authenticated with check (true);

create policy "authenticated_update_aprendiz"
on public.aprendiz for update to authenticated using (true) with check (true);

create policy "authenticated_delete_aprendiz"
on public.aprendiz for delete to authenticated using (true);
```

Haz políticas equivalentes de `select` para `departamento` y `ciudad`.

## Importante sobre roles
El PRD de SIRA define Administrador y Usuario operativo. La tabla `aprendiz` suministrada no contiene el rol del usuario y no se proporcionó una tabla de usuarios/perfiles. Por eso este proyecto implementa autenticación de Supabase y el CRUD solicitado, pero la autorización RBAC real debe conectarse a una tabla de perfiles/roles o a claims de Supabase. No se debe inventar el rol desde el cliente.

## Si tus columnas de catálogo tienen otros nombres
El código asume:

`departamento(codigo, nombre)`

`ciudad(departamento, codigo, nombre)`

Si tu tabla usa `id` en vez de `codigo`, modifica únicamente `catalog_service.dart` y los modelos de catálogo.
