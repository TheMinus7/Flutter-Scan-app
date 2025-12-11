import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

class LocalShareServer {
  static final LocalShareServer _i = LocalShareServer._();
  LocalShareServer._();
  factory LocalShareServer() => _i;

  HttpServer? _server;
  int? _port;
  final Map<String, File> _routes = {};

  Future<void> _start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _port = _server!.port;
    unawaited(_server!.listen((HttpRequest req) async {
      final file = _routes[req.uri.path];
      if (file == null || !await file.exists()) {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
        return;
      }
      final ext = p.extension(file.path).toLowerCase();
      final mime = switch (ext) {
        '.pdf' => 'application/pdf',
        '.png' => 'image/png',
        '.jpg' || '.jpeg' => 'image/jpeg',
        _ => 'application/octet-stream',
      };
      req.response.headers.contentType = ContentType.parse(mime);
      await req.response.addStream(file.openRead());
      await req.response.close();
    }).asFuture());
  }

  Future<String> addFile(File file) async {
    await _start();
    final token = '/f_${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    _routes[token] = file;
    final ip = await _firstLanIp();
    return 'http://$ip:${_port!}$token';
  }

  Future<String> _firstLanIp() async {
    final ifs = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: true);
    for (final i in ifs) {
      for (final a in i.addresses) {
        final s = a.address;
        final isLan = s.startsWith('192.168.') ||
            s.startsWith('10.') ||
            RegExp(r'^172\.(1[6-9]|2\d|3[0-1])\.').hasMatch(s);
        if (!a.isLoopback && isLan) return s;
      }
    }
    for (final i in ifs) {
      for (final a in i.addresses) {
        if (!a.isLoopback) return a.address;
      }
    }
    return '127.0.0.1';
  }
}
