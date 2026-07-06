import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Mirrors frontend getSessionId() — persistent device session in local storage.
class SessionService {
  SessionService(this._prefs);

  static const sessionKey = 'rokkhakoboch_session_id';

  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  String getSessionId() {
    var id = _prefs.getString(sessionKey);
    if (id == null || id.isEmpty) {
      id = _uuid.v4();
      _prefs.setString(sessionKey, id);
    }
    return id;
  }
}
