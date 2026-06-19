"""State management service for match analysis."""

import 'package:flutter/foundation.dart';
import 'package:shuttlecoach/models/shot_evaluation.dart';
import 'package:shuttlecoach/services/api_client.dart';

class AnalysisProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClientProvider.getInstance();
  
  List<ShotEvaluation> shots = [];
  MatchStatistics? statistics;
  bool isLoading = false;
  String? error;
  
  Future<void> loadMatchAnalysis(String matchId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final shotsFuture = _apiClient.getMatchShots(matchId);
      final statsFuture = _apiClient.getMatchStatistics(matchId);
      
      final results = await Future.wait([shotsFuture, statsFuture]);
      shots = results[0] as List<ShotEvaluation>;
      statistics = results[1] as MatchStatistics;
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
  
  ShotEvaluation? getShotAt(Duration position) {
    try {
      final ms = position.inMilliseconds;
      return shots.firstWhere(
        (shot) => shot.timestampMs ~/ 1000 == ms ~/ 1000,
        orElse: () => ShotEvaluation(
          shotId: '',
          matchId: '',
          playerId: '',
          opponentId: '',
          shotType: ShotType.unknown,
          timestampMs: 0,
          classification: ShotClassification.good,
          executionScore: 0,
          decisionScore: 0,
          overallScore: 0,
          explanation: '',
          tacticalInsight: '',
          improvementTip: '',
          modelVersion: '',
          confidence: 0,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}

class CoachProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClientProvider.getInstance();
  
  List<CoachMessage> messages = [];
  bool isLoading = false;
  String? error;
  
  Future<void> askCoach({
    required String question,
    required CoachFilterCategory category,
    String? matchId,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.queryCoach({
        'question': question,
        'category': category.name,
        'match_id': matchId,
      });
      
      messages.add(response);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
