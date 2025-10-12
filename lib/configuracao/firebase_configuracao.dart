import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Configuração do Firebase para diferentes plataformas
class FirebaseConfiguracao {
  // Flags de ambiente para uso do Emulador (definidas via --dart-define)
  // Emulador do Firebase desativado por padrão.
  // Ative somente passando --dart-define=USE_FIREBASE_EMULATOR=true.
  static const bool usarEmulador = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
    defaultValue: false,
  );
  static const String hostEmulador =
      String.fromEnvironment('FIREBASE_EMULATOR_HOST', defaultValue: 'localhost');
  static const int portaAuthEmulador =
      int.fromEnvironment('FIREBASE_AUTH_EMULATOR_PORT', defaultValue: 9099);
  static const int portaFirestoreEmulador =
      int.fromEnvironment('FIREBASE_FIRESTORE_EMULATOR_PORT', defaultValue: 8080);

  // No Android emulador, "localhost" aponta para o próprio AVD.
  // Para alcançar o host da máquina, usamos 10.0.2.2.
  static String get hostEmuladorEfetivo {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return hostEmulador;
  }
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
      // Logs de diagnóstico: credenciais ativas (Web)
      try {
        final opts = Firebase.app().options;
        print('[Firebase Web] projectId=${opts.projectId} appId=${opts.appId} authDomain=${opts.authDomain} apiKey=${opts.apiKey}');
      } catch (_) {}
      // Ajustes de compatibilidade Web: desabilita persistência para evitar
      // problemas de rede (long polling/proxies) que podem causar ERR_ABORTED
      // em canais de escuta do Firestore.
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: false,
        );
      } catch (_) {
        // Ignorar caso não suportado ou já configurado
      }
    } else {
      await Firebase.initializeApp();
      // Logs de diagnóstico: credenciais ativas (Mobile/Desktop)
      try {
        final opts = Firebase.app().options;
        print('[Firebase ${defaultTargetPlatform}] projectId=${opts.projectId} appId=${opts.appId}');
      } catch (_) {}
    }

    // Conectar aos Emuladores quando habilitado
    if (usarEmulador) {
      try {
        FirebaseAuth.instance.useAuthEmulator(hostEmuladorEfetivo, portaAuthEmulador);
        print('[Auth Emulator] host=$hostEmuladorEfetivo port=$portaAuthEmulador');
      } catch (_) {
        // Ignorar se já estiver conectado ou plataforma não suportar
      }
      try {
        FirebaseFirestore.instance.useFirestoreEmulator(
          hostEmuladorEfetivo,
          portaFirestoreEmulador,
        );
        print('[Firestore Emulator] host=$hostEmuladorEfetivo port=$portaFirestoreEmulador');
      } catch (_) {
        // Ignorar se já estiver conectado ou plataforma não suportar
      }
    }
  }
}