import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _markReadOnScrollKey = 'mark_read_on_scroll';
  static const _localPersistenceKey = 'local_persistence_shadow_write';

  static Future<bool> getMarkReadOnScroll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_markReadOnScrollKey) ?? false;
  }

  static Future<void> setMarkReadOnScroll(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_markReadOnScrollKey, value);
  }

  /// Fase 1 da evolução do FeedFlow (ver docs/EVOLUTION-PLAN.md): grava os
  /// artigos carregados também no banco local (`WorkItem`), em paralelo ao
  /// fluxo normal, sem nenhuma mudança visível na UI ainda. Flag existe para
  /// permitir desligar rapidamente caso a escrita local cause problema.
  static Future<bool> getLocalPersistenceEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_localPersistenceKey) ?? true;
  }

  static Future<void> setLocalPersistenceEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localPersistenceKey, value);
  }
}
