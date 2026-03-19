# hardlist

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuracao de ambiente (Supabase)

Para executar sem chave hardcoded no codigo, informe as variaveis no comando:

```powershell
flutter run --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON
```

Opcionalmente, em release:

```powershell
flutter build apk --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON
```
