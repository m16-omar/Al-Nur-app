import 'package:serverpod/serverpod.dart';

/// HTTP hardening shared by the API server and the web server:
/// security headers, a CORS origin allowlist and no-store caching for API
/// responses.
class HttpSecurity {
  HttpSecurity._();

  /// Browser origins allowed to call the APIs. Requests without an `Origin`
  /// header (mobile apps, server-to-server, curl) are not affected.
  ///
  /// Extra origins can be added without a code change through the
  /// `corsAllowedOrigins` password (comma separated), e.g.
  /// `scloud password set corsAllowedOrigins "https://nupesongs.com"`.
  static const _defaultOrigins = {
    'https://alnur-store.serverpod.space',
    'https://alnur-store.api.serverpod.space',
    'https://al-nur-tau.vercel.app',
  };

  static Set<String>? _origins;

  static bool get _isProduction {
    try {
      return Serverpod.instance.runMode == ServerpodRunMode.production;
    } catch (_) {
      return true;
    }
  }

  static Set<String> get allowedOrigins {
    if (_origins != null) return _origins!;
    final extra = <String>{};
    try {
      final configured = Serverpod.instance.getPassword('corsAllowedOrigins');
      if (configured != null) {
        extra.addAll(configured
            .split(',')
            .map((o) => o.trim().replaceAll(RegExp(r'/+$'), ''))
            .where((o) => o.startsWith('https://') || o.startsWith('http://')));
      }
    } catch (_) {}
    return _origins = {..._defaultOrigins, ...extra};
  }

  static final RegExp _localOrigin =
      RegExp(r'^http://(localhost|127\.0\.0\.1)(:\d+)?$');

  static bool isAllowedOrigin(String origin) {
    if (allowedOrigins.contains(origin)) return true;
    // Local development (Flutter web dev server, local admin pages).
    return !_isProduction && _localOrigin.hasMatch(origin);
  }

  static String? _origin(Request req) {
    try {
      final values = req.headers['origin'];
      if (values == null || values.isEmpty) return null;
      return values.first.trim();
    } catch (_) {
      return null;
    }
  }

  /// Replaces the wildcard `Access-Control-Allow-Origin` with the request
  /// origin when it is trusted, and removes it when it is not.
  static Response _applyCors(Request req, Response res) {
    final origin = _origin(req);
    if (origin == null) return res;
    final allowed = isAllowedOrigin(origin);
    return res.copyWith(
      headers: res.headers.transform((mh) {
        mh.remove('access-control-allow-origin');
        if (allowed) {
          mh['Access-Control-Allow-Origin'] = [origin];
          mh['Vary'] = ['Origin'];
        }
      }),
    );
  }

  /// Content-Security-Policy for the two admin panels. Inline scripts are
  /// still allowed because both panels use inline event handlers, but scripts
  /// may only come from this site and the two pinned CDNs, the pages cannot be
  /// framed, and form posts / base URLs cannot be redirected elsewhere.
  static String _adminCsp() {
    final connect = [
      "'self'",
      'https://*.serverpod.space',
      if (!_isProduction) ...['http://localhost:8080', 'http://127.0.0.1:8080', 'http://localhost:8082'],
    ].join(' ');
    return [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' https://cdn.tailwindcss.com https://unpkg.com",
      "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
      "font-src 'self' https://fonts.gstatic.com data:",
      "img-src 'self' data: blob: https:",
      "media-src 'self' blob: https:",
      'connect-src $connect',
      "frame-src 'self'",
      "frame-ancestors 'none'",
      "form-action 'self'",
      "base-uri 'self'",
      "object-src 'none'",
    ].join('; ');
  }

  static bool _isAdminPath(String path) =>
      path == '/admin' ||
      path.startsWith('/admin/') ||
      path == '/nupe-admin' ||
      path.startsWith('/nupe-admin/');

  static void _baseHeaders(MutableHeaders mh, {required bool denyFraming}) {
    mh['X-Content-Type-Options'] = ['nosniff'];
    mh['Referrer-Policy'] = ['strict-origin-when-cross-origin'];
    mh['X-Frame-Options'] = [denyFraming ? 'DENY' : 'SAMEORIGIN'];
    mh['Permissions-Policy'] = ['camera=(), microphone=(), geolocation=(), payment=(), usb=()'];
    if (_isProduction) {
      mh['Strict-Transport-Security'] = ['max-age=31536000; includeSubDomains'];
    }
    mh.remove('x-powered-by');
    mh.remove('server');
  }

  /// Middleware for the web server (admin pages, Flutter web app, /api/**).
  static Handler webMiddleware(Handler next) {
    return (Request req) async {
      final result = await next(req);
      if (result is! Response) return result;
      final path = req.url.path;
      final admin = _isAdminPath(path);
      final api = path.startsWith('/api/');
      var res = result.copyWith(
        headers: result.headers.transform((mh) {
          _baseHeaders(mh, denyFraming: admin || api);
          if (admin) {
            mh['Content-Security-Policy'] = [_adminCsp()];
            mh['Cross-Origin-Opener-Policy'] = ['same-origin'];
          } else if (!api) {
            mh['Content-Security-Policy'] = ["frame-ancestors 'self'; object-src 'none'; base-uri 'self'"];
          }
          if (api) mh['Cache-Control'] = ['no-store'];
        }),
      );
      if (api) res = _applyCors(req, res);
      return res;
    };
  }

  /// Middleware for the Serverpod API server (endpoint calls).
  static Handler apiMiddleware(Handler next) {
    return (Request req) async {
      final result = await next(req);
      if (result is! Response) return result;
      final res = result.copyWith(
        headers: result.headers.transform((mh) {
          _baseHeaders(mh, denyFraming: true);
          if (!req.url.path.startsWith('/serverpod_cloud_storage')) {
            mh['Cache-Control'] = ['no-store'];
          }
        }),
      );
      return _applyCors(req, res);
    };
  }
}
