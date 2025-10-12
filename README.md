# FinTrack360 — Flutter/Dart demo (GitHub Pages)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/)

[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-222?logo=github&logoColor=white)](https://pages.github.com/)

[![Deploy Status](https://github.com/reinaldobarreto/fintrack360/actions/workflows/deploy.yml/badge.svg)](https://github.com/reinaldobarreto/fintrack360/actions/workflows/deploy.yml)

Aplicativo Flutter para controle financeiro pessoal/familiar. Foco em mobile-first e teste rápido via web.

## Overview
- Stack principal: **Flutter/Dart** (mobile-first + build web para demo)
- Deploy: **GitHub Pages** automatizado via **GitHub Actions**
- Backend opcional: **Firebase** (Auth/Firestore)
- Screenshots e assets padronizados em `assets/images/` (tela_*)

## Demo
- `https://reinaldobarreto.github.io/fintrack360/` (será publicado automaticamente após o primeiro push para `main`).

### Galeria rápida
Visual do app em uma grade compacta para leitura rápida:
<p align="center">
  <img src="assets/images/tela_principal_mobile.png" width="240" alt="Principal" />
  <img src="assets/images/tela_adicionar_lancamento_mobile.png" width="240" alt="Adicionar Lançamento" />
  <img src="assets/images/tela_relatorios_mobile.png" width="240" alt="Relatórios" />
</p>
<p align="center">
  <img src="assets/images/tela_categorias_mobile.png" width="240" alt="Categorias" />
  <img src="assets/images/tela_contas_mobile.png" width="240" alt="Contas" />
  <img src="assets/images/tela_cadastro_usuario_mobile.png" width="240" alt="Cadastro de Usuário" />
</p>

## Como usar (local)
- Requisitos: Flutter `stable` instalado.
```bash
flutter pub get
flutter run -d chrome
```

## Imagens do Funcionamento
Para explicar visualmente o funcionamento no GitHub, inclua capturas de tela na pasta `assets/images/` usando nomes padronizados:

![Principal](assets/images/tela_principal_mobile.png)
![Adicionar Lançamento](assets/images/tela_adicionar_lancamento_mobile.png)
![Relatórios](assets/images/tela_relatorios_mobile.png)

### O que cada imagem mostra
- Login Mobile: campos de e‑mail/senha, ação de entrar e opção de pular login (debug).
- Dashboard Mobile: KPIs, gráficos e saldo por período (receitas − despesas).
- Lançamentos Mobile: lista com filtros/ordenação, tipos (RECEITA/DESPESA) e categorias.

### Como adicionar rapidamente
1. Faça as capturas no dispositivo/emulador (PNG/JPG).
2. Rode o script para copiar/renomear automaticamente:
   ```bash
   pwsh -File ./fintrack360/scripts/rename_screenshots.ps1
   ```
3. Confirme os arquivos gerados em `assets/images/` e faça commit/push.

### Dica: imagens lado a lado
Você pode usar HTML no README para controlar largura/posição:
<p align="center">
  <img src="assets/images/tela_principal_mobile.png" width="240" alt="Principal" />
  <img src="assets/images/tela_adicionar_lancamento_mobile.png" width="240" alt="Adicionar Lançamento" />
  <img src="assets/images/tela_relatorios_mobile.png" width="240" alt="Relatórios" />
  
</p>

Observação: as imagens no README aparecem diretamente no GitHub (independente do GitHub Pages). GitHub Pages afeta apenas a demo publicada em `gh-pages`.

### Outras telas (já no projeto)
Para já mostrar o que existe hoje no repositório, você pode referenciar estas capturas:

![Principal](assets/images/tela_principal_mobile.png)
![Adicionar Lançamento](assets/images/tela_adicionar_lancamento_mobile.png)
![Relatórios](assets/images/tela_relatorios_mobile.png)
![Categorias](assets/images/tela_categorias_mobile.png)
![Contas](assets/images/tela_contas_mobile.png)
![Cadastro de Usuário](assets/images/tela_cadastro_usuario_mobile.png)
![Recuperar Senha](assets/images/tela_recuperar_senha_mobile.png)
![Ajustes](assets/images/tela_ajustes_mobile.png)

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
## 📝 Observações
- O login demo é somente local e não cria contas reais.
- O login padrão (`admin@fintrack.com` / `admin1234`) segue disponível, mas você pode usar apenas o demo na Web.

## 🚀 Publicar no GitHub Pages (gh-pages)
1) Habilite Web no Flutter (uma vez):
   - `flutter config --enable-web`
2) Construa a versão Web com modo demo local ativado:
   - `flutter build web --release --dart-define=USE_LOCAL_DEMO_AUTH=true`
3) Ajuste o `base href` para seu repositório (GitHub Pages):
   - Edite `web/index.html` e defina `<base href="/<nome-do-repo>/">`.
   - Exemplo: se publicar em `seuusuario.github.io/fintrack360`, use `<base href="/fintrack360/">`.
4) Publique o conteúdo de `build/web` na branch `gh-pages`:
   - Crie a branch `gh-pages` e copie os arquivos de `build/web` para a raiz.
   - Faça push da branch e, nas configurações do GitHub, ative Pages apontando para `gh-pages`/`root`.
5) Alternativa (automática): use o workflow em `.github/workflows/deploy-gh-pages.yml` com ação manual (`workflow_dispatch`).
## 🔗 Demo Web (GitHub Pages)
- Acesse: https://reinaldobarreto.github.io/fintrack360/
- Na primeira visita, use “Pular login (demo local)” para avaliar rapidamente sem Firebase.

<p>
  <a href="https://reinaldobarreto.github.io/fintrack360/" target="_blank">
    <img src="https://img.shields.io/badge/Demo%20Web-Abrir-2ea44f?style=for-the-badge&logo=google-chrome" alt="Demo Web" />
  </a>
  <a href="https://github.com/reinaldobarreto/fintrack360" target="_blank">
    <img src="https://img.shields.io/badge/Reposit%C3%B3rio-GitHub-000000?style=for-the-badge&logo=github" alt="Repositório GitHub" />
  </a>
</p>

## 📌 Sobre o Projeto
- App Flutter focado em Mobile (Android/iOS) com suporte a Web.
- Para testes públicos (GitHub Pages), o login demo é local e não cria contas reais.
- Login padrão disponível: `admin@fintrack.com` / `admin1234`.

### Tecnologias (perfil)
<p>
  <a href="https://developer.mozilla.org/docs/Web/JavaScript" target="_blank"><img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=000" alt="JavaScript" /></a>
  <a href="https://nodejs.org/" target="_blank"><img src="https://img.shields.io/badge/Node.js-339933?style=flat&logo=node.js&logoColor=fff" alt="Node.js" /></a>
  <a href="https://angular.io/" target="_blank"><img src="https://img.shields.io/badge/Angular-DD0031?style=flat&logo=angular&logoColor=fff" alt="Angular" /></a>
  <a href="https://www.typescriptlang.org/" target="_blank"><img src="https://img.shields.io/badge/TypeScript-3178C6?style=flat&logo=typescript&logoColor=fff" alt="TypeScript" /></a>
  <a href="https://react.dev/" target="_blank"><img src="https://img.shields.io/badge/React-61DAFB?style=flat&logo=react&logoColor=000" alt="React" /></a>
  <a href="https://developer.mozilla.org/docs/Web" target="_blank"><img src="https://img.shields.io/badge/Web-4285F4?style=flat&logo=google-chrome&logoColor=fff" alt="Web" /></a>
  <a href="https://reactnative.dev/" target="_blank"><img src="https://img.shields.io/badge/React%20Native-61DAFB?style=flat&logo=react&logoColor=000" alt="React Native" /></a>
</p>

## 🧪 Como o recrutador pode avaliar
- Abra a Demo Web no link acima.
- Clique em “Pular login (demo local)” para acessar o dashboard.
- Navegue pelos lançamentos, contas e gráficos; o estado é local ao navegador.

## 📱 Build Mobile
- Android APK: `flutter build apk --release`
- Android AppBundle (Play Store): `flutter build appbundle --release`
- iOS (requer macOS e Xcode): `flutter build ios --release` e Archive pelo Xcode.
