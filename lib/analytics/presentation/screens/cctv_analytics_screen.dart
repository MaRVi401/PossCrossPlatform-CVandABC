import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/main_drawer.dart';

class CCTVAnalyticsScreen extends StatefulWidget {
  const CCTVAnalyticsScreen({super.key});

  @override
  State<CCTVAnalyticsScreen> createState() => _CCTVAnalyticsScreenState();
}

class _CCTVAnalyticsScreenState extends State<CCTVAnalyticsScreen> {
  final Dio _cctvDio = sl<ApiClient>().cctvClient;

  Timer? _statsTimer;

  int _visitorCount = 0;
  double _avgHeight = 0.0;
  bool _isStatsLoading = true;
  bool _isStreamPaused = false;
  bool _isLiveConnected = false;
  DateTime? _lastUpdatedTime;

  @override
  void initState() {
    super.initState();
    _fetchYoloStats();

    _statsTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _fetchYoloStats(),
    );
  }

  Future<void> _fetchYoloStats() async {
    try {
      final response = await _cctvDio.get('/api/stats');

      if (response.statusCode == 200 && mounted) {
        final data = response.data;

        setState(() {
          _visitorCount = data['detected_count'] ??
              data['total_detected'] ??
              0;

          _avgHeight =
              (data['avg_height_cm'] as num?)?.toDouble() ?? 0.0;

          _isStatsLoading = false;
          _lastUpdatedTime = DateTime.now();
        });
      }
    } catch (e) {
      // Abaikan error sementara saat polling
    }
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _cctvDio.close();
    super.dispose();
  }

  void _showFullscreenStream() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: MjpegStreamPlayer(
                  streamUrl: '${ApiClient.cctvBaseUrl}/video_feed',
                  onStatusChanged: (connected) {},
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'CCTV Analytics (YOLOv8)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data Manual',
            onPressed: () {
              _fetchYoloStats();
            },
          ),
        ],
      ),
      drawer: const MainDrawer(
        currentRoute: 'cctv',
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _isStreamPaused
                        ? Container(
                            color: Colors.black87,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pause_circle_filled_rounded,
                                      color: Colors.white70, size: 48),
                                  SizedBox(height: 8),
                                  Text(
                                    'Stream Dihentikan (Paused)',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : MjpegStreamPlayer(
                            streamUrl: '${ApiClient.cctvBaseUrl}/video_feed',
                            onStatusChanged: (connected) {
                              if (_isLiveConnected != connected && mounted) {
                                setState(() => _isLiveConnected = connected);
                              }
                            },
                          ),
                  ),

                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isLiveConnected
                              ? const Color(0xFF10B981)
                              : Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isLiveConnected
                                  ? const Color(0xFF10B981)
                                  : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isLiveConnected ? 'LIVE FEED' : 'RECONNECTING',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              _isStreamPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isStreamPaused = !_isStreamPaused;
                              });
                            },
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _showFullscreenStream,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistik Real-time Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (_lastUpdatedTime != null)
                  Text(
                    'Updated: ${DateFormat('HH:mm:ss').format(_lastUpdatedTime!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pengunjung Terdeteksi',
                    value: '$_visitorCount',
                    unit: 'Orang',
                    icon: Icons.people_alt_outlined,
                    color: Colors.indigo.shade700,
                    bgColor: Colors.indigo.shade50,
                    isLoading: _isStatsLoading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Rata-Rata Tinggi',
                    value: _avgHeight.toStringAsFixed(1),
                    unit: 'cm',
                    icon: Icons.straighten_rounded,
                    color: Colors.purple.shade700,
                    bgColor: Colors.purple.shade50,
                    isLoading: _isStatsLoading,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildDensityStatusCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 10),
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
                        color: color.withAlpha(200),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDensityStatusCard() {
    String statusText = 'Normal';
    Color statusColor = Colors.green.shade700;
    Color statusBg = Colors.green.shade50;
    IconData statusIcon = Icons.check_circle_outline_rounded;

    if (_visitorCount > 10) {
      statusText = 'Sangat Ramai (High Traffic)';
      statusColor = Colors.red.shade700;
      statusBg = Colors.red.shade50;
      statusIcon = Icons.warning_amber_rounded;
    } else if (_visitorCount > 5) {
      statusText = 'Sedang (Moderate Traffic)';
      statusColor = Colors.orange.shade800;
      statusBg = Colors.orange.shade50;
      statusIcon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withAlpha(30),
            child: Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Kepadatan Area',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MjpegStreamPlayer extends StatefulWidget {
  final String streamUrl;
  final ValueChanged<bool>? onStatusChanged;

  const MjpegStreamPlayer({
    super.key,
    required this.streamUrl,
    this.onStatusChanged,
  });

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

      final request = await _client!.getUrl(
        Uri.parse(widget.streamUrl),
      );

      request.headers.add(
        'ngrok-skip-browser-warning',
        'true',
      );

      final response = await request.close();

      if (response.statusCode == 200) {
        if (widget.onStatusChanged != null) {
          widget.onStatusChanged!(true);
        }

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
                  final frameBytes = Uint8List.fromList(
                    bytesBuffer.sublist(start, end),
                  );

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
            _handleError();
          },
          onDone: () {
            _handleError();
          },
          cancelOnError: true,
        );
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
    }
  }

  void _handleError() {
    if (mounted) {
      setState(() => _hasError = true);
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!(false);
      }
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
            const Icon(
              Icons.videocam_off,
              size: 40,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 8),
            const Text(
              'Gagal Terhubung ke Stream CCTV',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _subscription?.cancel();
                _client?.close();
                _connectStream();
              },
              icon: const Icon(
                Icons.refresh,
                size: 16,
              ),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentFrame == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 12),
            Text(
              'Memuat Stream CCTV (YOLOv8)...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
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