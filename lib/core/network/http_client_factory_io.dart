import 'package:http/http.dart' as http;

http.Client createHttpClient() => http.Client();

const bool managesCookiesAutomatically = false;
