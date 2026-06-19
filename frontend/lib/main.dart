import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

void main() {
  runApp(const ShuttlecoachApp());
}

// ============================================================================
// Shot Model
// ============================================================================

class Shot {
  final int shotNumber;
  final double timestamp; // seconds
  final String quality; // 'Brilliant', 'Excellent', 'Good', 'Inaccuracy', 'Mistake', 'Blunder'
  final String type; // 'Drive', 'Clear', 'Drop', 'Smash', etc.
  final List<String> feedback;

  Shot({
    required this.shotNumber,
    required this.timestamp,
    required this.quality,
    required this.type,
    required this.feedback,
  });

  Color getQualityColor() {
    switch (quality) {
      case 'Brilliant':
        return Colors.purple;
      case 'Excellent':
        return Colors.blue;
      case 'Good':
        return Colors.green;
      case 'Inaccuracy':
        return Colors.orange;
      case 'Mistake':
        return Colors.red;
      case 'Blunder':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }
}

// ============================================================================
// Match Model
// ============================================================================

class Match {
  final String id;
  final String filename;
  final String videoPath;
  final DateTime uploadedAt;
  final String accuracy;
  final String performance;
  final List<String> issues;
  final int shotsAnalyzed;
  final List<Shot> shots;
  final String detailedAnalysis;

  Match({
    required this.id,
    required this.filename,
    required this.videoPath,
    required this.uploadedAt,
    required this.accuracy,
    required this.performance,
    required this.issues,
    required this.shotsAnalyzed,
    List<Shot>? shots,
    String? detailedAnalysis,
  })  : shots = shots ?? [],
        detailedAnalysis = detailedAnalysis ?? 'No detailed analysis available.';
}

// ============================================================================
// App State (Global match storage)
// ============================================================================

class AppState extends ChangeNotifier {
  List<Match> _matches = [];

  List<Match> get matches => _matches;

  void addMatch(Match match) {
    _matches.insert(0, match);
    notifyListeners();
  }

  void deleteMatch(String id) {
    _matches.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}

class ShuttlecoachApp extends StatelessWidget {
  const ShuttlecoachApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Shuttlecoach',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C3AED), // Purple
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'GoogleSans',
          scaffoldBackgroundColor: const Color(0xFFF8F7FF),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C3AED),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'GoogleSans',
          scaffoldBackgroundColor: const Color.fromARGB(255, 15, 15, 15),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shuttlecoach',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? Colors.transparent : Colors.white.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.0),
                    const Color(0xFF06B6D4).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color.fromARGB(255, 15, 15, 15),
                    const Color.fromARGB(255, 15, 15, 15),
                  ]
                : [
                    const Color(0xFFF8F7FF),
                    const Color(0xFFEFF6FF),
                  ],
          ),
        ),
        child: _buildBody(),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.0)
                : Colors.white.withOpacity(0.0),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.video_library),
                label: 'Upload',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Analysis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy),
                label: 'Coach',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const VideoDashboardScreen();
      case 1:
        return const AnalysisScreen();
      case 2:
        return const CoachScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Unknown page'));
    }
  }
}

// ============================================================================
// Liquid Glass Widget Helper
// ============================================================================

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsets padding;

  const GlassCard({
    Key? key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.2 : 0.2),
            ),
            // REMOVED THE BOX SHADOW HERE
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// Web Video Player Widget
// ============================================================================

// ============================================================================

class VideoDashboardScreen extends StatefulWidget {
  const VideoDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VideoDashboardScreen> createState() => _VideoDashboardScreenState();
}

class _VideoDashboardScreenState extends State<VideoDashboardScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedVideoPath;
  bool _isProcessing = false;
  String? _analysisResult;

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        setState(() => _selectedVideoPath = video.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: ${video.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _analyzeVideo() async {
    if (_selectedVideoPath == null) return;

    setState(() => _isProcessing = true);

    try {
      // Simulate backend processing (replace with actual API call)
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _analysisResult = '''Analysis Complete ✓

Shots Analyzed: 23
Accuracy: 87%
Performance: Good

Top Issues:
• Backhand grip adjustment
• Net clearance on returns

Next: Review detailed breakdown in Analysis tab''';
      });

      // Create sample shots
      final shots = [
        Shot(
          shotNumber: 1,
          timestamp: 2.5,
          quality: 'Excellent',
          type: 'Serve',
          feedback: [
            'Great serve placement',
            'Good power distribution',
            'Opponent pushed back',
          ],
        ),
        Shot(
          shotNumber: 2,
          timestamp: 5.2,
          quality: 'Good',
          type: 'Clear',
          feedback: [
            'Decent depth',
            'Could improve follow-through',
            'Positioned well for next shot',
          ],
        ),
        Shot(
          shotNumber: 3,
          timestamp: 8.1,
          quality: 'Inaccuracy',
          type: 'Drop Shot',
          feedback: [
            'Shot was too high',
            'Gave opponent attacking opportunity',
            'Better deception needed',
          ],
        ),
        Shot(
          shotNumber: 4,
          timestamp: 11.3,
          quality: 'Brilliant',
          type: 'Smash',
          feedback: [
            'Excellent positioning',
            'Perfect timing and execution',
            'Unreturnable shot - point won',
            'Great court awareness',
          ],
        ),
        Shot(
          shotNumber: 5,
          timestamp: 14.7,
          quality: 'Good',
          type: 'Drive',
          feedback: [
            'Solid drive placement',
            'Good racket control',
            'Caught opponent off guard',
          ],
        ),
      ];

      final detailedAnalysis = '''
COMPREHENSIVE MATCH BREAKDOWN

Overall Performance: Good (87% Accuracy)

SHOT DISTRIBUTION
• Serves: 4 (100% in)
• Clears: 8 (90% accuracy)
• Drops: 5 (75% accuracy)
• Smashes: 3 (100% accuracy)
• Drives: 3 (85% accuracy)

KEY STRENGTHS
✓ Excellent serve consistency and placement
✓ Strong court positioning after shots
✓ Good anticipation of opponent movement
✓ Effective smash execution
✓ Solid net play transitions

AREAS FOR IMPROVEMENT
⚠ Backhand grip needs adjustment on clears
⚠ Drop shot net clearance inconsistent
⚠ Follow-through on cross-court drives
⚠ Court recovery timing on defensive shots

TACTICAL ANALYSIS
The player showed strong fundamentals with good serve and smash execution. Court positioning was generally solid, indicating good game sense. The main weakness was in drop shot consistency and some backhand drive placement. Opponent was often put on defensive, showing good strategy.

RECOMMENDATIONS
1. Practice backhand grip transitions (especially on clears)
2. Improve drop shot touch and control
3. Work on faster court recovery drills
4. Focus on disguising shots to prevent opponent anticipation
5. Strengthen weak backhand side consistency

Next practice focus: Backhand drills, drop shot accuracy
''';

      // Save match to app state
      final appState = Provider.of<AppState>(context, listen: false);
      final videoName = _selectedVideoPath!.split('/').last;
      
      final match = Match(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filename: videoName,
        videoPath: _selectedVideoPath!,
        uploadedAt: DateTime.now(),
        accuracy: '87%',
        performance: 'Good',
        issues: [
          'Backhand grip adjustment',
          'Net clearance on returns',
        ],
        shotsAnalyzed: 23,
        shots: shots,
        detailedAnalysis: detailedAnalysis,
      );
      
      appState.addMatch(match);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video analyzed successfully! Check Analysis tab.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing video: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            if (_analysisResult == null) ...[
              GlassCard(
                blur: 20,
                opacity: 0.08,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF7C3AED).withOpacity(0.3),
                            const Color(0xFF06B6D4).withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.video_library,
                        size: 64,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Upload Match Video',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'For AI analysis\nand shot evaluation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_selectedVideoPath != null)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedVideoPath!.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (_isProcessing)
                GlassCard(
                  child: Column(
                    children: const [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Analyzing video...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Column(
                  children: [
                    UploadVideoButton(
                      onTap: _pickVideo,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Choose Video",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Select from gallery",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // Fix #1: Removed the two extra `),` that were right here
              ]
            ] else ...[
              GlassCard(
                blur: 20,
                opacity: 0.08,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF7C3AED).withOpacity(0.3),
                                const Color(0xFF06B6D4).withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 32,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analysis Complete',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Video processed successfully',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _analysisResult!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() {
                                  _selectedVideoPath = null;
                                  _analysisResult = null;
                                }),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.upload_file,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Upload Another',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ), // Fix #2: Added the missing closing parenthesis for SizedBox here
    );
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? _selectedMatchId;

  void _seekToShot(double timestamp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Timestamp: ${timestamp}s - Click to navigate in video player',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.matches.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                GlassCard(
                  blur: 20,
                  opacity: 0.08,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF7C3AED).withOpacity(0.3),
                              const Color(0xFF06B6D4).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.assessment,
                          size: 64,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Matches Yet',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Upload and analyze your first badminton match\nin the Videos tab to see results here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        }

        if (_selectedMatchId != null) {
          final match = appState.matches.firstWhere(
            (m) => m.id == _selectedMatchId,
            orElse: () => appState.matches.first,
          );
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedMatchId = null;
                  }),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 8),
                        Text('Back to Matches'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Video Player Section
                GlassCard(
                  blur: 20,
                  opacity: 0.08,
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.black,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 64,
                                color: Colors.white30,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Click shots below to jump to timestamp',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Shot Timeline
                if (match.shots.isNotEmpty)
                  GlassCard(
                    blur: 20,
                    opacity: 0.08,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shot Analysis Timeline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...match.shots.map((shot) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              _seekToShot(shot.timestamp);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Shot ${shot.shotNumber}: ${shot.type} - ${shot.quality} (${shot.timestamp}s)',
                                  ),
                                  duration: const Duration(milliseconds: 800),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: shot.getQualityColor().withOpacity(0.1),
                                border: Border.all(
                                  color: shot.getQualityColor().withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: shot.getQualityColor(),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${shot.shotNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              shot.type,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    shot.getQualityColor(),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                shot.quality,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${shot.timestamp}s',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          shot.feedback.join(' • '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // Stats Section
                GlassCard(
                  blur: 20,
                  opacity: 0.08,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shots Analyzed',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            match.shotsAnalyzed.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Accuracy',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            match.accuracy,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Overall Performance',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              match.performance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Detailed Analysis
                GlassCard(
                  blur: 20,
                  opacity: 0.08,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detailed Analysis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match.detailedAnalysis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appState.matches.length,
          itemBuilder: (context, index) {
            final match = appState.matches[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedMatchId = match.id),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match.filename,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Shots: ${match.shotsAnalyzed} • Accuracy: ${match.accuracy}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            match.performance,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          match.uploadedAt.toString().split('.')[0],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CoachScreen extends StatelessWidget {
  const CoachScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassCard(
            blur: 20,
            opacity: 0.08,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7C3AED).withOpacity(0.3),
                        const Color(0xFF06B6D4).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 40,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI Coach',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask about tactics, technique, and match insights',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoryButtons(),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildChatMessage(
                isUser: false,
                text: 'Hey! I\'m your personal badminton coach. Ask me anything about your game, tactics, or technique.',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: GlassCard(
                  blur: 10,
                  opacity: 0.05,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask your coach...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButtons() {
    final categories = [
      ('Tactics', Icons.lightbulb),
      ('Technique', Icons.sports_martial_arts),
      ('Analytics', Icons.analytics),
      ('General', Icons.info),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories
          .map((cat) => GlassCard(
                blur: 10,
                opacity: 0.05,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.$2, size: 18),
                    const SizedBox(width: 6),
                    Text(cat.$1, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildChatMessage({required bool isUser, required String text}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GlassCard(
        blur: isUser ? 0 : 10,
        opacity: isUser ? 0 : 0.08,
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : null,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          GlassCard(
            blur: 20,
            opacity: 0.08,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7C3AED).withOpacity(0.3),
                        const Color(0xFF06B6D4).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 64,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Player Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Career statistics and progress tracking\ncoming soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.edit, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class UploadVideoButton extends StatefulWidget {
  final VoidCallback onTap;

  const UploadVideoButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<UploadVideoButton> createState() => _UploadVideoButtonState();
}

class _UploadVideoButtonState extends State<UploadVideoButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _rotationController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _glowAnimation = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _scaleController.forward();
    _glowController.forward();
    _rotationController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    // Smoothly reverses back to the original state without any extra bounce
    _scaleController.reverse();
    _glowController.reverse();
    _rotationController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
    _glowController.reverse();
    _rotationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _glowController,
        _rotationController,
      ]),
      builder: (context, child) {
        // Calculate scale: shrink on press, smoothly returns to 1.0 on release
        double scale = 1.0 - (_scaleController.value * 0.35); // Adjusted to 0.15 to match your intended max shrink target of 0.85
        
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated Glow Layer
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(_glowAnimation.value),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // Outer Ring with animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15 + (_glowAnimation.value * 0.15)),
                      width: 2.0,
                    ),
                  ),
                ),

                // Main Button with enhanced ripple
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    splashColor: Colors.white.withOpacity(0.4),
                    highlightColor: Colors.white.withOpacity(0.2),
                    onTap: widget.onTap,
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    child: Ink(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(
                              const Color(0xFF7C3AED),
                              const Color(0xFF9D5CFF),
                              _scaleController.value,
                            )!,
                            Color.lerp(
                              const Color(0xFF06B6D4),
                              const Color(0xFF00D4FF),
                              _scaleController.value,
                            )!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(_glowAnimation.value),
                            blurRadius: 25 + (_glowController.value * 10),
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Colors.white.withOpacity(1.0 - (_scaleController.value * 0.2)),
                            size: 36,
                          ),
                          const SizedBox(height: 2),
                          Icon(
                            Icons.video_library_rounded,
                            color: Colors.white.withOpacity(1.0 - (_scaleController.value * 0.2)),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}