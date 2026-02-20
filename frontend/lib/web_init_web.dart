import 'dart:html' as html;
import 'config.dart';

void injectGoogleMapsScript() {
  final String apiKey = Config.googleApiKey;
  if (html.document.getElementById('google-maps-script') == null) {
    final script = html.ScriptElement()
      ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places'
      ..id = 'google-maps-script';
    html.document.head?.append(script);
  }
}
