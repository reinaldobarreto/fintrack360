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
  <img src="./assets/images/tela_principal_mobile.png" width="240" alt="Principal" />
  <img src="./assets/images/tela_adicionar_lancamento_mobile.png" width="240" alt="Adicionar Lançamento" />
  <img src="./assets/images/tela_relatorios_mobile.png" width="240" alt="Relatórios" />
</p>
<p align="center">
  <img src="./assets/images/tela_categorias_mobile.png" width="240" alt="Categorias" />
  <img src="./assets/images/tela_contas_mobile.png" width="240" alt="Contas" />
  <img src="./assets/images/tela_cadastro_usuario_mobile.png" width="240" alt="Cadastro de Usuário" />
</p>

## Como usar (local)
- Requisitos: Flutter `stable` instalado.
```bash
flutter pub get
flutter run -d chrome
```

## Imagens do Funcionamento
Para explicar visualmente o funcionamento no GitHub, inclua capturas de tela na pasta `assets/images/` usando nomes padronizados:

![Principal](./assets/images/tela_principal_mobile.png)
![Adicionar Lançamento](./assets/images/tela_adicionar_lancamento_mobile.png)
![Relatórios](./assets/images/tela_relatorios_mobile.png)

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
  <img src="./assets/images/tela_principal_mobile.png" width="240" alt="Principal" />
  <img src="./assets/images/tela_adicionar_lancamento_mobile.png" width="240" alt="Adicionar Lançamento" />
  <img src="./assets/images/tela_relatorios_mobile.png" width="240" alt="Relatórios" />
  
</p>

Observação: as imagens no README aparecem diretamente no GitHub (independente do GitHub Pages). GitHub Pages afeta apenas a demo publicada em `gh-pages`.

### Outras telas (já no projeto)
Para já mostrar o que existe hoje no repositório, você pode referenciar estas capturas:

![Principal](./assets/images/tela_principal_mobile.png)
![Adicionar Lançamento](./assets/images/tela_adicionar_lancamento_mobile.png)
![Relatórios](./assets/images/tela_relatorios_mobile.png)
![Categorias](./assets/images/tela_categorias_mobile.png)
![Contas](./assets/images/tela_contas_mobile.png)
![Cadastro de Usuário](./assets/images/tela_cadastro_usuario_mobile.png)
![Recuperar Senha](./assets/images/tela_recuperar_senha_mobile.png)
![Ajustes](./assets/images/tela_ajustes_mobile.png)

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
