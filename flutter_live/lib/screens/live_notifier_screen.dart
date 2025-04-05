import 'package:flutter/material.dart';
import '../models/live_session.dart';
import '../widgets/header_widget.dart';
import '../widgets/calender_selector.dart';
import '../widgets/live_chart.dart';
import '../widgets/filter_widget.dart';
import '../widgets/live_detail_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LiveNotifierScreen extends StatefulWidget {
  final String username;
  const LiveNotifierScreen({
    Key? key,
    required this.username,
  }) : super(key: key);
  @override
  _LiveNotifierScreenState createState() => _LiveNotifierScreenState();
}

class _LiveNotifierScreenState extends State<LiveNotifierScreen> {
  late DateTime _selectedDay;
  List<LiveSession>? _allLiveSessions; // Bisa null sebelum data diterima
  List<LiveSession>? _filteredSessions; // Bisa null sebelum filtering
  bool _isLoading = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadLiveSessions(); // Ambil data dari API saat widget dimuat
  }

  Future<void> _loadLiveSessions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _isOffline = connectivityResult == ConnectivityResult.none;
        });
      }

      // Gunakan fungsi yang sudah ada di file live_session.dart
      List<LiveSession> sessions = await fetchLiveSessions();

      if (mounted) {
        setState(() {
          // Filter hanya sesi dengan username yang sesuai
          _allLiveSessions = sessions
              .where((session) => session.username == widget.username)
              .toList();
          _filterSessionsByDate(); // Filter setelah data diterima
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading live sessions: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar();
      }
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOffline
            ? 'Anda sedang offline. Menampilkan data terakhir.'
            : 'Gagal memuat data. Silakan coba lagi.'),
        action: SnackBarAction(
          label: 'Coba Lagi',
          onPressed: _loadLiveSessions,
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  // Filter sesi berdasarkan tanggal yang dipilih
  void _filterSessionsByDate() {
    if (_allLiveSessions == null) return; // Jangan filter jika data belum ada

    setState(() {
      _filteredSessions = _allLiveSessions!.where((session) {
        final localTime = session.startTime.toUtc().add(Duration(hours: 7));
        final sessionDate = DateTime(
          localTime.year,
          localTime.month,
          localTime.day,
        );
        final selectedDate = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        );
        return sessionDate.isAtSameMomentAs(selectedDate);
      }).toList();
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
      _filterSessionsByDate();
    });
  }

  Future<void> _refreshData() async {
    try {
      // Check network connectivity first
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isOffline = connectivityResult == ConnectivityResult.none;

      setState(() {
        _isLoading = true;
        _selectedDay = DateTime.now();
      });

      if (isOffline) {
        // If offline, don't try to fetch from network
        final cachedSessions = await LiveSessionCache.getCachedLiveSessions();
        if (cachedSessions != null) {
          setState(() {
            _allLiveSessions = cachedSessions
                .where((session) => session.username == widget.username)
                .toList();
            _filterSessionsByDate();
            _isLoading = false;
            _isOffline = true;
          });
          _showErrorSnackBar(); // Show the offline message
          return;
        }
      } else {
        // Only clear cache if we're online
        await LiveSessionCache.clearCache();
      }

      await _loadLiveSessions();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderWidget(username: widget.username),
                      if (_isOffline)
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off,
                                  size: 16, color: Colors.orange[800]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Anda sedang offline. Menampilkan data yang tersimpan.',
                                  style: TextStyle(
                                      color: Colors.orange[800], fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              CalendarSelector(
                                selectedDay: _selectedDay,
                                onDaySelected: _onDaySelected,
                                liveSessions: _allLiveSessions!,
                              ),
                              LiveSessionLegend(),
                              SizedBox(height: 16),
                              LiveChart(
                                liveSessions: _filteredSessions ?? [],
                              ),
                              SizedBox(height: 16),
                              FiltersWidget(
                                liveSessions: _allLiveSessions ?? [],
                                username: widget.username,
                              ),
                              SizedBox(height: 16),
                              LiveDetailsWidget(
                                liveSessions: _filteredSessions ?? [],
                                username: widget.username,
                                allSessions: _allLiveSessions ?? [],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class LiveSessionLegend extends StatelessWidget {
  const LiveSessionLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Durasi Live: ',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          SizedBox(width: 8),
          _buildLegendItem('Rendah', 0.2),
          SizedBox(width: 4),
          _buildLegendItem('Sedang', 0.5),
          SizedBox(width: 4),
          _buildLegendItem('Tinggi', 1.0),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double opacity) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4A6CF7).withOpacity(opacity),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
