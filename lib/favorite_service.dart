
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String favoriAnahtari = 'favori_etkinlikler';

  Future<Set<String>> favorileriGetir() async {
    final prefs = await SharedPreferences.getInstance();

    final liste = prefs.getStringList(favoriAnahtari) ?? [];

    return liste.toSet();
  }

  Future<void> favorileriKaydet(Set<String> favoriler) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      favoriAnahtari,
      favoriler.toList(),
    );
  }
}
