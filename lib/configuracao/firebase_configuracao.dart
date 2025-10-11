import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Configuração do Firebase para diferentes plataformas
class FirebaseConfiguracao {
  // Flags de ambiente para uso do Emulador (definidas via --dart-define)
  static const bool usarEmulador =
      bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);
  static const String hostEmulador =
      String.fromEnvironment('FIREBASE_EMULATOR_HOST', defaultValue: 'localhost');
  static const int portaAuthEmulador =
      int.fromEnvironment('FIREBASE_AUTH_EMULATOR_PORT', defaultValue: 9099);
  static const int portaFirestoreEmulador =
      int.fromEnvironment('FIREBASE_FIRESTORE_EMULATOR_PORT', defaultValue: 8080);
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdpWyJYBwcD9i2Tonk-2IMxXNDJa-fRuo',
    appId: '1:171178762369:android:8bf627c9336e3e72086d80',
    messagingSenderId: '171178762369',
    projectId: 'fintrack360',
    storageBucket: 'fintrack360.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzPAWjmMaYrUNI12Qju17BP1fm8xsCGb4',
    appId: '1:171178762369:ios:8fb80c80919c2f62086d80',
    messagingSenderId: '171178762369',
    projectId: 'fintrack360',
    storageBucket: 'fintrack360.firebasestorage.app',
    iosBundleId: 'com.rbtech.fintrack360',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBY5pZTUlMIApKGcKdvFViPSQc4boFjEpE',
    appId: '1:171178762369:web:34ba1fa266cf32d7086d80',
    messagingSenderId: '171178762369',
    projectId: 'fintrack360',
    authDomain: 'fintrack360.firebaseapp.com',
    storageBucket: 'fintrack360.firebasestorage.app',
    measurementId: 'G-M8WKZ0N5RL',
  );

  /// Retorna as opções do Firebase baseado na plataforma atual
  static FirebaseOptions get opcoesPorPlataforma {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Opções do Firebase não foram configuradas para esta plataforma.',
        );
    }
  }

  /// Inicializa o Firebase
  static Future<void> inicializar() async {
    // No Android/iOS, usar os arquivos de configuração nativos
    // (google-services.json e GoogleService-Info.plist) para evitar
    // divergência de chaves/APIs. No Web, usar as opções explícitas.
    if (kIsWeb) {
      await Firebase.initializeApp(options: web);
    } else {
      await Firebase.initializeApp();
    }

    // Conectar aos Emuladores quando habilitado
    if (usarEmulador) {
      try {
        FirebaseAuth.instance.useAuthEmulator(hostEmulador, portaAuthEmulador);
      } catch (_) {
        // Ignorar se já estiver conectado ou plataforma não suportar
      }
      try {
        FirebaseFirestore.instance.useFirestoreEmulator(
          hostEmulador,
          portaFirestoreEmulador,
        );
      } catch (_) {
        // Ignorar se já estiver conectado ou plataforma não suportar
      }
    }
  }
}