import 'package:flutter/material.dart';

/// Configuração do tema da aplicação com Dark Mode e cores personalizadas
class TemaConfiguracao {
  // Cores principais do tema
  static const Color corPrimaria = Colors.amber; // Âmbar para ações principais
  static const Color corSecundaria = Colors.teal; // Turquesa para elementos secundários
  static const Color corSucesso = Colors.green; // Verde para lucro/sucesso
  static const Color corErro = Colors.red; // Vermelho para "no vermelho"/erro
  static const Color corFundo = Color(0xFF121212); // Fundo escuro
  static const Color corSuperficie = Color(0xFF1E1E1E); // Superfície escura
  static const Color corTexto = Colors.white; // Texto claro
  static const Color corTextoSecundario = Colors.white70; // Texto secundário

  /// Tema escuro personalizado da aplicação
  static ThemeData get temaEscuro {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Esquema de cores
      colorScheme: const ColorScheme.dark(
        primary: corPrimaria,
        secondary: corSecundaria,
        surface: corSuperficie,
        background: corFundo,
        error: corErro,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: corTexto,
        onBackground: corTexto,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: corSuperficie,
        foregroundColor: corTexto,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: corTexto,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Cards (atualizado para CardThemeData em versões recentes do Flutter)
      cardTheme: CardThemeData(
        color: corSuperficie,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Botões de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: corSecundaria,
        ),
      ),

      // Campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: corSuperficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corPrimaria, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corErro),
        ),
        labelStyle: const TextStyle(color: corTextoSecundario),
        hintStyle: const TextStyle(color: corTextoSecundario),
      ),

      // Navegação inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: corSuperficie,
        selectedItemColor: corPrimaria,
        unselectedItemColor: corTextoSecundario,
        type: BottomNavigationBarType.fixed,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: corPrimaria,
        foregroundColor: Colors.black,
      ),

      // Divisores
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
      ),

      // Texto
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: corTexto, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: corTexto, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: corTexto, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: corTexto),
        bodyMedium: TextStyle(color: corTexto),
        bodySmall: TextStyle(color: corTextoSecundario),
        labelLarge: TextStyle(color: corTexto),
        labelMedium: TextStyle(color: corTexto),
        labelSmall: TextStyle(color: corTextoSecundario),
      ),
    );
  }

  /// Cores para indicadores financeiros
  static Color obterCorSituacaoFinanceira(double valor) {
    return valor >= 0 ? corSucesso : corErro;
  }

  /// Cor para receitas
  static const Color corReceita = corSucesso;

  /// Cor para despesas
  static const Color corDespesa = corErro;
}