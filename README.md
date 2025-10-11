# FinTrack360 — Flutter/Dart demo (GitHub Pages)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/)

[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)

[![Deploy Status](https://github.com/reinaldobarreto/fintrack360/actions/workflows/deploy.yml/badge.svg)](https://github.com/reinaldobarreto/fintrack360/actions/workflows/deploy.yml)

Aplicativo Flutter para controle financeiro pessoal/familiar. Foco em mobile-first e teste rápido via web.

## Demo
- `https://reinaldobarreto.github.io/fintrack360/` (será publicado automaticamente após o primeiro push para `main`).

## Como usar (local)
- Requisitos: Flutter `stable` instalado.
```bash
flutter pub get
flutter run -d chrome
```

## Screenshots
Coloque suas imagens em `assets/images/` com esses nomes:

![Login Mobile](assets/images/tela_login_mobile.png)
![Dashboard Mobile](assets/images/tela_dashboard_mobile.png)
![Lançamentos Mobile](assets/images/tela_lancamentos_mobile.png)

## Publicação (GitHub Pages)
- Já existe um workflow em `.github/workflows/deploy.yml` que compila e publica automaticamente na branch `gh-pages`.
- O `base-href` é dinâmico e usa o nome do repositório.
- Passos:
  1. Crie o repositório no GitHub.
  2. Faça push para `main`.
  3. Verifique em “Settings → Pages” se a publicação está ativa na `gh-pages`.

## Desenvolvimento (opcional)
- Emulador do Firebase sem custos: consulte `README_flutter.md` para instruções completas.

## Autor
- Reinaldo Barreto — Flutter/Dart
