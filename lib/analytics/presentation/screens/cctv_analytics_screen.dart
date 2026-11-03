import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_drawer.dart';

class CCTVAnalyticsScreen extends StatefulWidget {
  const CCTVAnalyticsScreen({super.key});

  @override
  State<CCTVAnalyticsScreen> createState() => _CCTVAnalyticsScreenState();
}

class _CCTVAnalyticsScreenState extends State<CCTVAnalyticsScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000'));
  Timer? _statsTimer;

  int _visitorCount = 0;
  double _avgHeight = 0.0;
  bool _isStatsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchYoloStats();
    // Polling data statistik dari Flask /api/stats setiap 1 detik
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchYoloStats();
    });
  }

  Future<void> _fetchYoloStats() async {
    try {
      final response = await _dio.get(
        '/api/stats',
        options: Options(headers: {'ngrok-skip-browser-warning': 'true'}),
      );

      if (response.statusCode == 200 && mounted) {
        final data = response.data;
        setState(() {
          _visitorCount = data['detected_count'] ?? data['total_detected'] ?? 0;
          _avgHeight = (data['avg_height_cm'] as num?)?.toDouble() ?? 0.0;
          _isStatsLoading = false;
        });
      }
    } catch (e) {
      // Abaikan error koneksi sementara saat polling
    }
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time CCTV & Visitor Analytics'),
        elevation: 1,
      ),
      drawer: const MainDrawer(currentRoute: '/dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tampilan CCTV Stream dengan Format Landscape (16:9)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              color: Colors.black,
              child: const AspectRatio(
                aspectRatio: 16 / 9, // Format landscape standar CCTV
                child: MjpegStreamPlayer(
                  streamUrl: 'http://10.0.2.2:5000/video_feed',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Card Statistik Real-time dari YOLOv8
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pengunjung Terdeteksi',
                    value: '$_visitorCount',
                    unit: 'Orang',
                    color: Colors.blue.shade700,
                    bgColor: Colors.blue.shade50,
                    isLoading: _isStatsLoading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Rata-Rata Tinggi',
                    value: _avgHeight.toStringAsFixed(1),
                    unit: 'cm',
                    color: Colors.purple.shade700,
                    bgColor: Colors.purple.shade50,
                    isLoading: _isStatsLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required Color bgColor,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          isLoading
              ? SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

/// Custom Stream Player menggunakan HttpClient Native
class MjpegStreamPlayer extends StatefulWidget {
  final String streamUrl;
  const MjpegStreamPlayer({super.key, required this.streamUrl});

  @override
  State<MjpegStreamPlayer> createState() => _MjpegStreamPlayerState();
}

class _MjpegStreamPlayerState extends State<MjpegStreamPlayer> {
  Uint8List? _currentFrame;
  bool _hasError = false;
  StreamSubscription? _subscription;
  HttpClient? _client;

  @override
  void initState() {
    super.initState();
    _connectStream();
  }

  void _connectStream() async {
    if (!mounted) return;
    setState(() => _hasError = false);

    try {
      _client = HttpClient();
      _client!.connectionTimeout = const Duration(seconds: 5);
      final request = await _client!.getUrl(Uri.parse(widget.streamUrl));
      request.headers.add('ngrok-skip-browser-warning', 'true');

      final response = await request.close();

      if (response.statusCode == 200) {
        List<int> bytesBuffer = [];

        _subscription = response.listen(
          (data) {
            bytesBuffer.addAll(data);

            int start = -1;
            int end = -1;

            for (int i = 0; i < bytesBuffer.length - 1; i++) {
              if (bytesBuffer[i] == 0xFF && bytesBuffer[i + 1] == 0xD8) {
                start = i;
              }
              if (bytesBuffer[i] == 0xFF && bytesBuffer[i + 1] == 0xD9) {
                end = i + 2;
                if (start != -1 && end > start) {
                  final frameBytes =
                      Uint8List.fromList(bytesBuffer.sublist(start, end));
                  if (mounted) {
                    setState(() {
                      _currentFrame = frameBytes;
                      _hasError = false;
                    });
                  }
                  bytesBuffer = bytesBuffer.sublist(end);
                  break;
                }
              }
            }
          },
          onError: (error) {
            if (mounted) setState(() => _hasError = true);
          },
          onDone: () {
            if (mounted) setState(() => _hasError = true);
          },
          cancelOnError: true,
        );
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            const Text(
              'Gagal Terhubung ke Stream',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                _subscription?.cancel();
                _client?.close();
                _connectStream();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi', style: TextStyle(fontSize: 12)),
            )
          ],
        ),
      );
    }

    if (_currentFrame == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text('Memuat Stream CCTV...',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
    }

    return Image.memory(
      _currentFrame!,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }
}