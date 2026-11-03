import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CCTVAnalyticsScreen extends StatelessWidget {
  const CCTVAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-time CCTV & Visitor Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Menggunakan Custom Streamer HTTP Native
                child: const MjpegStreamPlayer(
                  streamUrl: 'http://10.0.2.2:5000/video_feed',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildMetricCard('Pengunjung Hari Ini', '142', Colors.blue),
                  _buildMetricCard('Kepadatan Area', 'Sedang (45%)', Colors.orange),
                  _buildMetricCard('Rekomendasi ABC', 'Restock Produk A', Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom MJPEG Stream Player menggunakan HttpClient Native Dart
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
    setState(() {
      _hasError = false;
    });

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

            // Cari marker JPEG awal (0xFF, 0xD8) dan akhir (0xFF, 0xD9)
            int start = -1;
            int end = -1;

            for (int i = 0; i < bytesBuffer.length - 1; i++) {
              if (bytesBuffer[i] == 0xFF && bytesBuffer[i + 1] == 0xD8) {
                start = i;
              }
              if (bytesBuffer[i] == 0xFF && bytesBuffer[i + 1] == 0xD9) {
                end = i + 2;
                if (start != -1 && end > start) {
                  final frameBytes = Uint8List.fromList(bytesBuffer.sublist(start, end));
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
            const Icon(Icons.videocam_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 8),
            const Text(
              'Gagal Terhubung ke Stream (10.0.2.2:5000)',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                _subscription?.cancel();
                _client?.close();
                _connectStream();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Hubungkan Ulang'),
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
            Text('Memuat Stream CCTV...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return Image.memory(
      _currentFrame!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}