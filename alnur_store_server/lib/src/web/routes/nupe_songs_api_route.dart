import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

/// Dedicated Nupe Songs Studio admin account.
///
/// Completely separate from Al-Nur Store admin accounts. Credentials are read
/// from `config/passwords.yaml` (`nupeStudioAdminEmail`,
/// `nupeStudioAdminPassword`, optional `nupeStudioAdminName`). Outside of
/// production, a development default is used when they are not configured.
class _StudioAdminAuth {
  static const _devEmail = 'admin@nupesongs.com';
  static const _devPassword = 'nupe2026admin';
  static const _sessionTtl = Duration(hours: 12);
  static const _rememberTtl = Duration(days: 30);

  static final Random _random = Random.secure();

  /// token -> session info
  static final Map<String, _StudioSession> _sessions = {};

  static ({String email, String password, String name})? credentials(
    Session session,
  ) {
    final email = session.passwords['nupeStudioAdminEmail']?.trim();
    final password = session.passwords['nupeStudioAdminPassword'];
    final name =
        session.passwords['nupeStudioAdminName']?.trim() ?? 'Nupe Studio Admin';

    if (email != null &&
        email.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      return (email: email.toLowerCase(), password: password, name: name);
    }
    if (session.serverpod.runMode == ServerpodRunMode.production) {
      return null; // Never fall back to default credentials in production.
    }
    return (email: _devEmail, password: _devPassword, name: name);
  }

  /// Constant-time string comparison to avoid timing leaks.
  static bool _secureEquals(String a, String b) {
    final aa = utf8.encode(a);
    final bb = utf8.encode(b);
    var diff = aa.length ^ bb.length;
    for (var i = 0; i < aa.length; i++) {
      diff |= aa[i] ^ (i < bb.length ? bb[i] : 0);
    }
    return diff == 0;
  }

  static _StudioSession? login(
    Session session,
    String email,
    String password, {
    bool remember = false,
  }) {
    final creds = credentials(session);
    if (creds == null) return null;

    final emailOk = _secureEquals(email.trim().toLowerCase(), creds.email);
    final passwordOk = _secureEquals(password, creds.password);
    if (!emailOk || !passwordOk) return null;

    _purgeExpired();
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final token = base64Url.encode(bytes).replaceAll('=', '');
    final studioSession = _StudioSession(
      token: token,
      email: creds.email,
      name: creds.name,
      expiresAt: DateTime.now().add(remember ? _rememberTtl : _sessionTtl),
    );
    _sessions[token] = studioSession;
    return studioSession;
  }

  static _StudioSession? validate(Request request) {
    String? token;
    try {
      final header = request.headers.authorization;
      if (header is BearerAuthorizationHeader) token = header.token;
    } catch (_) {
      return null;
    }
    if (token == null) return null;

    final studioSession = _sessions[token];
    if (studioSession == null) return null;
    if (studioSession.expiresAt.isBefore(DateTime.now())) {
      _sessions.remove(token);
      return null;
    }
    return studioSession;
  }

  static void logout(Request request) {
    final studioSession = validate(request);
    if (studioSession != null) _sessions.remove(studioSession.token);
  }

  static void _purgeExpired() {
    final now = DateTime.now();
    _sessions.removeWhere((_, s) => s.expiresAt.isBefore(now));
  }
}

class _StudioSession {
  _StudioSession({
    required this.token,
    required this.email,
    required this.name,
    required this.expiresAt,
  });

  final String token;
  final String email;
  final String name;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'role': 'nupe_studio_admin',
        'expires_at': expiresAt.toUtc().toIso8601String(),
      };
}

class NupeSongsApiRoute extends Route {
  NupeSongsApiRoute()
      : super(
          methods: {
            Method.get,
            Method.post,
            Method.put,
            Method.delete,
            Method.options,
          },
        );

  // In-memory counters and state
  static final Map<String, int> _streamCounts = {
    '1': 142,
    '2': 98,
    '3': 215,
  };

  static final Map<String, int> _downloadCounts = {
    '1': 45,
    '2': 31,
    '3': 80,
  };

  static final List<Map<String, dynamic>> _genres = [
    {'id': 1, 'name': 'Traditional / Folk', 'description': 'Roots & cultural folk songs'},
    {'id': 2, 'name': 'Afrobeats', 'description': 'Modern afro-fusion & pop'},
    {'id': 3, 'name': 'Love & Romance', 'description': 'Ballads & acoustic rhythms'},
    {'id': 4, 'name': 'Praise & Heritage', 'description': 'Tribute to Nupe kingdom and elders'},
    {'id': 5, 'name': 'Remixes & DJ Mixes', 'description': 'Club & party tracks'},
  ];

  static final List<Map<String, dynamic>> _artists = [
    {
      'id': 1,
      'name': 'Mahmud Mokwa',
      'image': 'https://res.cloudinary.com/dnexiputv/image/upload/artists/Mahmud_Mokwa.png',
      'bio': 'Legendary Nupe folk and traditional recording artist from Mokwa.',
    },
    {
      'id': 2,
      'name': 'Prince Ahmad Chado',
      'image': 'https://res.cloudinary.com/dnexiputv/image/upload/artists/Prince_Ahmad_Chado.png',
      'bio': 'Renowned modern Nupe singer and performer.',
    },
    {
      'id': 3,
      'name': 'Bala MJ',
      'image': 'https://res.cloudinary.com/dnexiputv/image/upload/artists/Bala_MJ.png',
      'bio': 'Dynamic vocalist blending traditional Nupe rhythm with Afrobeats.',
    },
    {
      'id': 4,
      'name': 'Sadisu Mohammed',
      'image': 'https://res.cloudinary.com/dnexiputv/image/upload/artists/Sadisu_Mohammed.png',
      'bio': 'Nupe cultural musician and community voice.',
    },
    {
      'id': 7,
      'name': 'Salihu Unity',
      'image': 'https://res.cloudinary.com/dnexiputv/image/upload/artists/Salihu_Unity.png',
      'bio': 'Pioneer of unity-themed Nupe peace melodies.',
    },
    {
      'id': 8,
      'name': 'Prince MK',
      'image': 'https://res.cloudinary.com/dnexiputv/image/upload/artists/Prince_Mk.png',
      'bio': 'Contemporary Nupe Afro-pop rising sensation.',
    },
    {
      'id': 9,
      'name': 'DJ Zubis',
      'image': 'https://res.cloudinary.com/dnexiputv/image/upload/artists/DJ_Zubis.png',
      'bio': 'Leading DJ and remix producer for Nupe hits.',
    },
  ];

  static final List<Map<String, dynamic>> _albums = [
    {
      'id': 6,
      'name': 'Emigun',
      'artist': {
        'id': 1,
        'name': 'Mahmud Mokwa',
      },
      'artwork': 'https://res.cloudinary.com/dnexiputv/image/upload/albums/Emigun_Cover.png',
      'release_year': 2005,
      'songs': [
        {'id': 1},
        {'id': 2},
        {'id': 3},
      ],
    },
  ];

  static final List<Map<String, dynamic>> _songs = [
    {
      'id': 1,
      'title': 'Dabe Dabe',
      'artist': {
        'id': 1,
        'name': 'Mahmud Mokwa',
      },
      'album': {
        'id': 6,
        'name': 'Emigun',
      },
      'genre': {
        'id': 7,
        'name': 'Love',
      },
      'audio_file': 'https://res.cloudinary.com/dnexiputv/video/upload/songs/Dabe_Dabe_SNz37Wi.mp3',
      'stream_url': 'https://res.cloudinary.com/dnexiputv/video/upload/songs/Dabe_Dabe_SNz37Wi.mp3',
      'artwork': 'https://res.cloudinary.com/dnexiputv/image/upload/songs/artwork/Dabe_Dabe_Cover_Album.png',
      'artwork_url': 'https://res.cloudinary.com/dnexiputv/image/upload/songs/artwork/Dabe_Dabe_Cover_Album.png',
      'duration_ms': 240000,
      'lyrics': '[00:00.00] (Intro Music)\r\n[00:04.00] Dabe Dabe, egi Nupe\r\n[00:08.00] Gbakako wo, ezhi be kpokpo\r\n[00:12.00] Dabe Dabe, egi Nupe\r\n[00:16.00] Wo yi nupe, de wun na a\r\n[00:20.00] (Melodious Instrumental)\r\n[00:24.00] Gently, gently, child of Nupe\r\n[00:28.00] Walk with pride, the land is bright\r\n[00:32.00] Gently, gently, child of Nupe\r\n[00:36.00] You are Nupe, never forget your roots\r\n[00:40.00] (Instrumental Bridge)\r\n[00:44.00] Ezhingi gwa, de emi gwa\r\n[00:48.00] Soko be kpe, na wo ba lo\r\n[00:52.00] Ka ji awo, Ka ji awo\r\n[00:56.00] Nupe ye bo, yi de laka\r\n[01:00.00] (English Translation)\r\n[01:04.00] Hold my hand, hold my home\r\n[01:08.00] Only God knows where you will go\r\n[01:12.00] Do your best, do your best\r\n[01:16.00] Nupe is loved, we have pride\r\n[01:20.00] (Melodious Instrumental Solo)\r\n[01:30.00] Dabe Dabe, egi Nupe\r\n[01:34.00] Gbakako wo, ezhi be kpokpo\r\n[01:38.00] Dabe Dabe, egi Nupe\r\n[01:42.00] Wo yi nupe, de wun na a\r\n[01:46.00] (English Chorus Repeat)\r\n[01:50.00] Gently, gently, child of Nupe\r\n[01:54.00] Walk with pride, the land is bright\r\n[01:58.00] Gently, gently, child of Nupe\r\n[02:02.00] You are Nupe, never forget your roots\r\n[02:06.00] (Bridge Repeat)\r\n[02:10.00] Ezhingi gwa, de emi gwa\r\n[02:14.00] Soko be kpe, na wo ba lo\r\n[02:18.00] Ka ji awo, Ka ji awo\r\n[02:22.00] Nupe ye bo, yi de laka\r\n[02:26.00] (Outro Music to end)\r\n[02:35.00] (Song completed)\r\n',
      'is_favorited': false,
    },
    {
      'id': 2,
      'title': 'Eganzuma',
      'artist': {
        'id': 1,
        'name': 'Mahmud Mokwa',
      },
      'album': {
        'id': 6,
        'name': 'Emigun',
      },
      'genre': {
        'id': 7,
        'name': 'Love',
      },
      'audio_file': 'https://res.cloudinary.com/dnexiputv/video/upload/songs/Eganzuma.mp3',
      'stream_url': 'https://res.cloudinary.com/dnexiputv/video/upload/songs/Eganzuma.mp3',
      'artwork': 'https://res.cloudinary.com/dnexiputv/image/upload/songs/artwork/Eganzuma.jpeg',
      'artwork_url': 'https://res.cloudinary.com/dnexiputv/image/upload/songs/artwork/Eganzuma.jpeg',
      'duration_ms': 419000,
      'lyrics': '[00:00.00] (Intro Beat)\n[00:08.00] Eganzuma, eganzuma\n[00:13.00] Egan na wo ba na, de gbari a\n[00:18.00] Eganzuma, eganzuma\n[00:23.00] Wo da a kpa, egan nda ye\n[00:28.00] (Drum Roll Instrumental)\n[00:33.00] Words of wisdom, words of wisdom\n[00:38.00] The words you speak have weight\n[00:43.00] Words of wisdom, words of wisdom\n[00:48.00] Remember the sayings of the elders\n[00:53.00] (Instrumental Interlude)\n[00:58.00] Soko da, wun yi gaba\n[01:03.00] Enchi le yi, wun la wo gwa\n[01:08.00] Gbako na wo ji, wun ge be\n[01:13.00] Nupe ye bo, ezhi ge!\n[01:18.00] (Traditional Flutes Solo)\n[01:30.00] Walk high, speak true, child of Nupe\n[01:35.00] For the ancestors stand with you\n[01:40.00] Soko be ya wo, de nna ya\n[01:45.00] Eganzuma, Nupe heritage!\n[01:50.00] (Extended Rhythm Interlude)\n[02:10.00] Eganzuma, eganzuma\n[02:15.00] Egan na wo ba na, de gbari a\n[02:20.00] Eganzuma, eganzuma\n[02:25.00] Wo da a kpa, egan nda ye\n[02:30.00] (Drum and Flutes Chorus)\n[02:40.00] Words of wisdom, words of wisdom\n[02:45.00] The words you speak have weight\n[02:50.00] Words of wisdom, words of wisdom\n[02:55.00] Remember the sayings of the elders\n[03:00.00] (Acoustic Guitar Bridge)\n[03:20.00] Soko da, wun yi gaba\n[03:25.00] Enchi le yi, wun la wo gwa\n[03:30.00] Gbako na wo ji, wun ge be\n[03:35.00] Nupe ye bo, ezhi ge!\n[03:40.00] (Melodic Flutes Solo)\n[04:00.00] Walk high, speak true, child of Nupe\n[04:05.00] For the ancestors stand with you\n[04:10.00] Soko be ya wo, de nna ya\n[04:15.00] Eganzuma, Nupe heritage!\n[04:20.00] (Traditional Beat & Chants)\n[04:40.00] Eganzuma, eganzuma\n[04:45.00] Egan na wo ba na, de gbari a\n[04:50.00] Eganzuma, eganzuma\n[04:55.00] Wo da a kpa, egan nda ye\n[05:00.00] (English Verse Repeat)\n[05:05.00] Words of wisdom, words of wisdom\n[05:10.00] The words you speak have weight\n[05:15.00] Words of wisdom, words of wisdom\n[05:20.00] Remember the sayings of the elders\n[05:25.00] (Percussion and Flutes Solo)\n[05:45.00] Soko da, wun yi gaba\n[05:50.00] Enchi le yi, wun la wo gwa\n[05:55.00] Gbako na wo ji, wun ge be\n[06:00.00] Nupe ye bo, ezhi ge!\n[06:05.00] (Traditional Flutes Outro)\n[06:20.00] Eganzuma, Nupe heritage!\n[06:30.00] (Outro Drums Fade)\n[06:40.00] (Song completed)',
      'is_favorited': false,
    },
    {
      'id': 3,
      'title': 'Mokwaci',
      'artist': {
        'id': 3,
        'name': 'Bala MJ',
      },
      'album': {
        'id': 6,
        'name': 'Emigun',
      },
      'genre': {
        'id': 3,
        'name': 'Afrobeats',
      },
      'audio_file': 'https://res.cloudinary.com/dnexiputv/video/upload/songs/Mokwa.mp3',
      'stream_url': 'https://res.cloudinary.com/dnexiputv/video/upload/songs/Mokwa.mp3',
      'artwork': 'https://res.cloudinary.com/dnexiputv/image/upload/songs/artwork/Sanwo.png',
      'artwork_url': 'https://res.cloudinary.com/dnexiputv/image/upload/songs/artwork/Sanwo.png',
      'duration_ms': 200000,
      'lyrics': '[00:00.00] (Highlife Beat Intro)\n[00:05.00] Mokwa, ezhi gege\n[00:10.00] Mokwa, ezhi nupe\n[00:15.00] Mokwa, na yi da na\n[00:20.00] Ezhi ge, na wo kpa na\n[02:45.00] (Outro Horns to end)\n[02:59.00] (Song completed)',
      'is_favorited': false,
    },
  ];

  Headers _corsHeaders() {
    return Headers.fromMap({
      'Access-Control-Allow-Origin': ['*'],
      'Access-Control-Allow-Methods': ['GET, POST, PUT, DELETE, OPTIONS'],
      'Access-Control-Allow-Headers': ['Content-Type, Authorization'],
      'Content-Type': ['application/json; charset=utf-8'],
    });
  }

  Response _jsonResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      statusCode,
      headers: _corsHeaders(),
      body: Body.fromString(jsonEncode(data)),
    );
  }

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    // Handle CORS pre-flight
    if (request.method == Method.options) {
      return Response.ok(headers: _corsHeaders());
    }

    final path = request.url.path;

    // Normalize path by trimming trailing slash for matching
    final normalizedPath = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;

    // ---- Nupe Studio admin authentication (separate from Al-Nur Store) ----

    // POST /api/studio/auth/login
    if (normalizedPath == '/api/studio/auth/login' &&
        request.method == Method.post) {
      String email = '';
      String password = '';
      bool remember = false;
      try {
        final data =
            jsonDecode(await request.readAsString()) as Map<String, dynamic>;
        email = (data['email'] as String?) ?? '';
        password = (data['password'] as String?) ?? '';
        remember = data['remember'] == true;
      } catch (_) {
        return _jsonResponse({'error': 'Invalid request body.'},
            statusCode: 400);
      }

      if (_StudioAdminAuth.credentials(session) == null) {
        return _jsonResponse(
          {'error': 'Nupe Studio admin account is not configured on this server.'},
          statusCode: 503,
        );
      }

      final studioSession =
          _StudioAdminAuth.login(session, email, password, remember: remember);
      if (studioSession == null) {
        session.log('Failed Nupe Studio login attempt for "$email"',
            level: LogLevel.warning);
        return _jsonResponse(
          {'error': 'Invalid studio email or password.'},
          statusCode: 401,
        );
      }
      return _jsonResponse({
        'token': studioSession.token,
        'user': studioSession.toJson(),
      });
    }

    // GET /api/studio/auth/me
    if (normalizedPath == '/api/studio/auth/me' &&
        request.method == Method.get) {
      final studioSession = _StudioAdminAuth.validate(request);
      if (studioSession == null) {
        return _jsonResponse({'error': 'Unauthorized'}, statusCode: 401);
      }
      return _jsonResponse({'user': studioSession.toJson()});
    }

    // POST /api/studio/auth/logout
    if (normalizedPath == '/api/studio/auth/logout' &&
        request.method == Method.post) {
      _StudioAdminAuth.logout(request);
      return _jsonResponse({'status': 'ok'});
    }

    // Catalog writes (create/update/delete songs, albums, artists, genres)
    // require a Nupe Studio admin session. Public listener actions
    // (play/download counters) remain open.
    final isCatalogPath = RegExp(r'^/api/(songs|albums|artists|genres)(/\d+)?$')
        .hasMatch(normalizedPath);
    final isWrite = request.method == Method.post ||
        request.method == Method.put ||
        request.method == Method.delete;
    if (isCatalogPath && isWrite && _StudioAdminAuth.validate(request) == null) {
      return _jsonResponse(
        {'error': 'Nupe Studio admin sign-in required.'},
        statusCode: 401,
      );
    }

    // 1. GET /api/songs
    if (normalizedPath == '/api/songs' && request.method == Method.get) {
      final enrichedSongs = _songs.map((s) {
        final idStr = s['id'].toString();
        return {
          ...s,
          'stream_count': _streamCounts[idStr] ?? 0,
          'download_count': _downloadCounts[idStr] ?? 0,
        };
      }).toList();
      return _jsonResponse(enrichedSongs);
    }

    // POST /api/songs (Create Song)
    if (normalizedPath == '/api/songs' && request.method == Method.post) {
      try {
        final bodyText = await request.readAsString();
        final data = jsonDecode(bodyText) as Map<String, dynamic>;
        final nextId = (_songs.map((s) => s['id'] as int).fold(0, (a, b) => a > b ? a : b)) + 1;
        
        final newSong = {
          'id': nextId,
          'title': data['title'] ?? 'Untitled Track',
          'artist': {
            'id': data['artist_id'] ?? 1,
            'name': data['artist_name'] ?? 'Unknown Artist',
          },
          'album': {
            'id': data['album_id'] ?? 6,
            'name': data['album_name'] ?? 'Singles',
          },
          'genre': {
            'id': data['genre_id'] ?? 1,
            'name': data['genre_name'] ?? 'Afrobeats',
          },
          'audio_file': data['audio_file'] ?? data['stream_url'] ?? '',
          'stream_url': data['audio_file'] ?? data['stream_url'] ?? '',
          'artwork': data['artwork'] ?? data['artwork_url'] ?? 'https://res.cloudinary.com/dnexiputv/image/upload/albums/Emigun_Cover.png',
          'artwork_url': data['artwork'] ?? data['artwork_url'] ?? 'https://res.cloudinary.com/dnexiputv/image/upload/albums/Emigun_Cover.png',
          'duration_ms': data['duration_ms'] ?? 210000,
          'lyrics': data['lyrics'] ?? '',
          'is_favorited': false,
        };
        _songs.add(newSong);
        _streamCounts[nextId.toString()] = 0;
        _downloadCounts[nextId.toString()] = 0;
        return _jsonResponse(newSong, statusCode: 201);
      } catch (e) {
        return _jsonResponse({'error': e.toString()}, statusCode: 400);
      }
    }

    // PUT /api/songs/<id>
    final songPutMatch = RegExp(r'^/api/songs/(\d+)$').firstMatch(normalizedPath);
    if (songPutMatch != null && request.method == Method.put) {
      final id = int.tryParse(songPutMatch.group(1)!);
      final index = _songs.indexWhere((s) => s['id'] == id);
      if (index == -1) return _jsonResponse({'error': 'Song not found'}, statusCode: 404);

      try {
        final bodyText = await request.readAsString();
        final data = jsonDecode(bodyText) as Map<String, dynamic>;
        final existing = _songs[index];

        final updated = {
          ...existing,
          if (data.containsKey('title')) 'title': data['title'],
          if (data.containsKey('artist_name'))
            'artist': {
              'id': existing['artist']['id'] ?? 1,
              'name': data['artist_name'],
            },
          if (data.containsKey('album_name'))
            'album': {
              'id': existing['album']['id'] ?? 6,
              'name': data['album_name'],
            },
          if (data.containsKey('genre_name'))
            'genre': {
              'id': existing['genre']['id'] ?? 1,
              'name': data['genre_name'],
            },
          if (data.containsKey('audio_file')) ...{
            'audio_file': data['audio_file'],
            'stream_url': data['audio_file'],
          },
          if (data.containsKey('artwork')) ...{
            'artwork': data['artwork'],
            'artwork_url': data['artwork'],
          },
          if (data.containsKey('duration_ms')) 'duration_ms': data['duration_ms'],
          if (data.containsKey('lyrics')) 'lyrics': data['lyrics'],
        };
        _songs[index] = updated;
        return _jsonResponse(updated);
      } catch (e) {
        return _jsonResponse({'error': e.toString()}, statusCode: 400);
      }
    }

    // DELETE /api/songs/<id>
    if (songPutMatch != null && request.method == Method.delete) {
      final id = int.tryParse(songPutMatch.group(1)!);
      final index = _songs.indexWhere((s) => s['id'] == id);
      if (index == -1) return _jsonResponse({'error': 'Song not found'}, statusCode: 404);
      _songs.removeAt(index);
      return _jsonResponse({'status': 'deleted', 'id': id});
    }

    // 2. POST /api/songs/<id>/play
    final playMatch = RegExp(r'^/api/songs/(\d+)/play$').firstMatch(normalizedPath);
    if (playMatch != null && request.method == Method.post) {
      final songId = playMatch.group(1)!;
      _streamCounts[songId] = (_streamCounts[songId] ?? 0) + 1;
      return _jsonResponse({
        'status': 'ok',
        'song_id': songId,
        'stream_count': _streamCounts[songId],
      });
    }

    // 3. POST /api/songs/<id>/download
    final downloadMatch = RegExp(r'^/api/songs/(\d+)/download$').firstMatch(normalizedPath);
    if (downloadMatch != null && request.method == Method.post) {
      final songId = downloadMatch.group(1)!;
      _downloadCounts[songId] = (_downloadCounts[songId] ?? 0) + 1;
      return _jsonResponse({
        'status': 'ok',
        'song_id': songId,
        'download_count': _downloadCounts[songId],
      });
    }

    // 4. GET & POST /api/albums
    if (normalizedPath == '/api/albums') {
      if (request.method == Method.get) {
        return _jsonResponse(_albums);
      } else if (request.method == Method.post) {
        try {
          final bodyText = await request.readAsString();
          final data = jsonDecode(bodyText) as Map<String, dynamic>;
          final nextId = (_albums.map((a) => a['id'] as int).fold(0, (a, b) => a > b ? a : b)) + 1;
          final newAlbum = {
            'id': nextId,
            'name': data['name'] ?? 'Untitled Album',
            'artist': {
              'id': data['artist_id'] ?? 1,
              'name': data['artist_name'] ?? 'Mahmud Mokwa',
            },
            'artwork': data['artwork'] ?? 'https://res.cloudinary.com/dnexiputv/image/upload/albums/Emigun_Cover.png',
            'release_year': data['release_year'] ?? DateTime.now().year,
            'songs': [],
          };
          _albums.add(newAlbum);
          return _jsonResponse(newAlbum, statusCode: 201);
        } catch (e) {
          return _jsonResponse({'error': e.toString()}, statusCode: 400);
        }
      }
    }

    // DELETE /api/albums/<id>
    final albumIdMatch = RegExp(r'^/api/albums/(\d+)$').firstMatch(normalizedPath);
    if (albumIdMatch != null && request.method == Method.delete) {
      final id = int.tryParse(albumIdMatch.group(1)!);
      _albums.removeWhere((a) => a['id'] == id);
      return _jsonResponse({'status': 'deleted', 'id': id});
    }

    // 5. GET & POST /api/artists
    if (normalizedPath == '/api/artists') {
      if (request.method == Method.get) {
        return _jsonResponse(_artists);
      } else if (request.method == Method.post) {
        try {
          final bodyText = await request.readAsString();
          final data = jsonDecode(bodyText) as Map<String, dynamic>;
          final nextId = (_artists.map((a) => a['id'] as int).fold(0, (a, b) => a > b ? a : b)) + 1;
          final newArtist = {
            'id': nextId,
            'name': data['name'] ?? 'New Artist',
            'image': data['image'] ?? 'https://res.cloudinary.com/dnexiputv/image/upload/artists/Mahmud_Mokwa.png',
            'bio': data['bio'] ?? 'Nupe recording artist.',
          };
          _artists.add(newArtist);
          return _jsonResponse(newArtist, statusCode: 201);
        } catch (e) {
          return _jsonResponse({'error': e.toString()}, statusCode: 400);
        }
      }
    }

    // DELETE /api/artists/<id>
    final artistIdMatch = RegExp(r'^/api/artists/(\d+)$').firstMatch(normalizedPath);
    if (artistIdMatch != null && request.method == Method.delete) {
      final id = int.tryParse(artistIdMatch.group(1)!);
      _artists.removeWhere((a) => a['id'] == id);
      return _jsonResponse({'status': 'deleted', 'id': id});
    }

    // 6. GET & POST /api/genres
    if (normalizedPath == '/api/genres') {
      if (request.method == Method.get) {
        return _jsonResponse(_genres);
      } else if (request.method == Method.post) {
        try {
          final bodyText = await request.readAsString();
          final data = jsonDecode(bodyText) as Map<String, dynamic>;
          final nextId = (_genres.map((g) => g['id'] as int).fold(0, (a, b) => a > b ? a : b)) + 1;
          final newGenre = {
            'id': nextId,
            'name': data['name'] ?? 'New Genre',
            'description': data['description'] ?? '',
          };
          _genres.add(newGenre);
          return _jsonResponse(newGenre, statusCode: 201);
        } catch (e) {
          return _jsonResponse({'error': e.toString()}, statusCode: 400);
        }
      }
    }

    // 7. GET /api/analytics
    if (normalizedPath == '/api/analytics' && request.method == Method.get) {
      final totalStreams = _streamCounts.values.fold(0, (a, b) => a + b);
      final totalDownloads = _downloadCounts.values.fold(0, (a, b) => a + b);

      return _jsonResponse({
        'total_songs': _songs.length,
        'total_artists': _artists.length,
        'total_albums': _albums.length,
        'total_genres': _genres.length,
        'total_streams': totalStreams,
        'total_downloads': totalDownloads,
        'active_listeners': 86,
      });
    }

    // 8. POST /api/auth/login
    if (normalizedPath == '/api/auth/login' && request.method == Method.post) {
      String username = 'User';
      try {
        final bodyText = await request.readAsString();
        if (bodyText.isNotEmpty) {
          final data = jsonDecode(bodyText) as Map<String, dynamic>;
          username = data['username'] as String? ?? 'User';
        }
      } catch (_) {}

      return _jsonResponse({
        'access': 'nupe_jwt_access_${DateTime.now().millisecondsSinceEpoch}',
        'refresh': 'nupe_jwt_refresh_${DateTime.now().millisecondsSinceEpoch}',
        'username': username,
      });
    }

    // 9. POST /api/auth/register
    if (normalizedPath == '/api/auth/register' && request.method == Method.post) {
      String username = 'User';
      String email = 'user@example.com';
      try {
        final bodyText = await request.readAsString();
        if (bodyText.isNotEmpty) {
          final data = jsonDecode(bodyText) as Map<String, dynamic>;
          username = data['username'] as String? ?? 'User';
          email = data['email'] as String? ?? 'user@example.com';
        }
      } catch (_) {}

      return _jsonResponse({
        'access': 'nupe_jwt_access_${DateTime.now().millisecondsSinceEpoch}',
        'refresh': 'nupe_jwt_refresh_${DateTime.now().millisecondsSinceEpoch}',
        'username': username,
        'email': email,
      });
    }

    // 10. GET /api/auth/me
    if (normalizedPath == '/api/auth/me' && request.method == Method.get) {
      return _jsonResponse({
        'id': 1,
        'username': 'nupe_fan',
        'email': 'fan@nupesongs.com',
        'full_name': 'Nupe Fan',
        'first_name': 'Nupe',
        'last_name': 'Fan',
        'is_staff': false,
      });
    }

    // 11. POST /api/auth/token/refresh
    if (normalizedPath == '/api/auth/token/refresh' && request.method == Method.post) {
      return _jsonResponse({
        'access': 'nupe_jwt_access_${DateTime.now().millisecondsSinceEpoch}',
        'refresh': 'nupe_jwt_refresh_${DateTime.now().millisecondsSinceEpoch}',
      });
    }

    // 12. POST /api/auth/logout
    if (normalizedPath == '/api/auth/logout' && request.method == Method.post) {
      return _jsonResponse({'status': 'ok'});
    }

    // Fallback 404 for unmatched /api routes
    return _jsonResponse(
      {'error': 'Not Found', 'path': path},
      statusCode: 404,
    );
  }
}
