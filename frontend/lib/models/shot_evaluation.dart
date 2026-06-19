import 'package:json_annotation/json_annotation.dart';

part 'shot_evaluation.g.dart';

// ============================================================================
// Enums
// ============================================================================

enum ShotClassification {
  @JsonValue('brilliant')
  brilliant,
  @JsonValue('excellent')
  excellent,
  @JsonValue('good')
  good,
  @JsonValue('inaccuracy')
  inaccuracy,
  @JsonValue('mistake')
  mistake,
  @JsonValue('blunder')
  blunder,
}

enum ShotType {
  @JsonValue('clear')
  clear,
  @JsonValue('drop')
  drop,
  @JsonValue('smash')
  smash,
  @JsonValue('push')
  push,
  @JsonValue('net_shot')
  netShot,
  @JsonValue('lob')
  lob,
  @JsonValue('drive')
  drive,
  @JsonValue('slice')
  slice,
  @JsonValue('block')
  block,
  @JsonValue('unknown')
  unknown,
}

enum CoachFilterCategory {
  @JsonValue('tactics_strategy')
  tacticsStrategy,
  @JsonValue('technique_form')
  techniqueForm,
  @JsonValue('match_analytics')
  matchAnalytics,
  @JsonValue('general_equipment')
  generalEquipment,
}

// ============================================================================
// Spatial Data
// ============================================================================

@JsonSerializable()
class Point2D {
  final double x;
  final double y;

  Point2D({required this.x, required this.y});

  factory Point2D.fromJson(Map<String, dynamic> json) => _$Point2DFromJson(json);
  Map<String, dynamic> toJson() => _$Point2DToJson(this);
}

@JsonSerializable()
class CourtPosition {
  final double x;
  final double y;

  CourtPosition({required this.x, required this.y});

  factory CourtPosition.fromJson(Map<String, dynamic> json) =>
      _$CourtPositionFromJson(json);
  Map<String, dynamic> toJson() => _$CourtPositionToJson(this);
}

@JsonSerializable()
class ShuttlecockTrajectory {
  final CourtPosition launchPoint;
  final CourtPosition landingPoint;
  final double? maxHeight;
  final int? flightTimeMs;

  ShuttlecockTrajectory({
    required this.launchPoint,
    required this.landingPoint,
    this.maxHeight,
    this.flightTimeMs,
  });

  factory ShuttlecockTrajectory.fromJson(Map<String, dynamic> json) =>
      _$ShuttlecockTrajectoryFromJson(json);
  Map<String, dynamic> toJson() => _$ShuttlecockTrajectoryToJson(this);
}

@JsonSerializable()
class PosePoint {
  final String jointName;
  final double x;
  final double y;
  final double? z;
  final double confidence;

  PosePoint({
    required this.jointName,
    required this.x,
    required this.y,
    this.z,
    required this.confidence,
  });

  factory PosePoint.fromJson(Map<String, dynamic> json) =>
      _$PosePointFromJson(json);
  Map<String, dynamic> toJson() => _$PosePointToJson(this);
}

@JsonSerializable()
class PlayerPoseSnapshot {
  final String playerId;
  final int timestampMs;
  final List<PosePoint> joints;
  final CourtPosition? courtPosition;

  PlayerPoseSnapshot({
    required this.playerId,
    required this.timestampMs,
    required this.joints,
    this.courtPosition,
  });

  factory PlayerPoseSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PlayerPoseSnapshotFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerPoseSnapshotToJson(this);
}

// ============================================================================
// Shot Evaluation
// ============================================================================

@JsonSerializable()
class ShotEvaluation {
  final String shotId;
  final String matchId;
  final String playerId;
  final String opponentId;
  final ShotType shotType;
  final int timestampMs;
  final ShotClassification classification;
  final double executionScore;
  final double decisionScore;
  final double overallScore;
  final PlayerPoseSnapshot? playerPose;
  final PlayerPoseSnapshot? opponentPose;
  final ShuttlecockTrajectory? shuttlecockTrajectory;
  final CourtPosition? opponentCourtPosition;
  final CourtPosition? shotTargetPosition;
  final String explanation;
  final String tacticalInsight;
  final String improvementTip;
  final String modelVersion;
  final double confidence;
  final DateTime createdAt;

  ShotEvaluation({
    required this.shotId,
    required this.matchId,
    required this.playerId,
    required this.opponentId,
    required this.shotType,
    required this.timestampMs,
    required this.classification,
    required this.executionScore,
    required this.decisionScore,
    required this.overallScore,
    this.playerPose,
    this.opponentPose,
    this.shuttlecockTrajectory,
    this.opponentCourtPosition,
    this.shotTargetPosition,
    required this.explanation,
    required this.tacticalInsight,
    required this.improvementTip,
    required this.modelVersion,
    required this.confidence,
    required this.createdAt,
  });

  factory ShotEvaluation.fromJson(Map<String, dynamic> json) =>
      _$ShotEvaluationFromJson(json);
  Map<String, dynamic> toJson() => _$ShotEvaluationToJson(this);

  // Helper method to get color based on classification
  String get colorHex {
    switch (classification) {
      case ShotClassification.brilliant:
        return '#7C3AED'; // Purple
      case ShotClassification.excellent:
        return '#06B6D4'; // Cyan
      case ShotClassification.good:
        return '#10B981'; // Green
      case ShotClassification.inaccuracy:
        return '#F59E0B'; // Amber
      case ShotClassification.mistake:
        return '#EF4444'; // Red
      case ShotClassification.blunder:
        return '#DC2626'; // Dark Red
    }
  }
}

@JsonSerializable()
class MatchStatistics {
  final String matchId;
  final String playerId;
  final int totalShots;
  final int brilliantCount;
  final int excellentCount;
  final int goodCount;
  final int inaccuracyCount;
  final int mistakeCount;
  final int blunderCount;
  final double averageExecutionScore;
  final double averageDecisionScore;
  final double averageOverallScore;
  final Map<String, int> shotDistribution;
  final double firstHalfAvgScore;
  final double secondHalfAvgScore;
  final String scoreTrend;

  MatchStatistics({
    required this.matchId,
    required this.playerId,
    required this.totalShots,
    required this.brilliantCount,
    required this.excellentCount,
    required this.goodCount,
    required this.inaccuracyCount,
    required this.mistakeCount,
    required this.blunderCount,
    required this.averageExecutionScore,
    required this.averageDecisionScore,
    required this.averageOverallScore,
    required this.shotDistribution,
    required this.firstHalfAvgScore,
    required this.secondHalfAvgScore,
    required this.scoreTrend,
  });

  factory MatchStatistics.fromJson(Map<String, dynamic> json) =>
      _$MatchStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$MatchStatisticsToJson(this);
}

@JsonSerializable()
class CoachMessage {
  final String messageId;
  final String? matchId;
  final String question;
  final CoachFilterCategory category;
  final String answer;
  final double confidence;
  final List<String> sources;
  final DateTime createdAt;

  CoachMessage({
    required this.messageId,
    this.matchId,
    required this.question,
    required this.category,
    required this.answer,
    required this.confidence,
    required this.sources,
    required this.createdAt,
  });

  factory CoachMessage.fromJson(Map<String, dynamic> json) =>
      _$CoachMessageFromJson(json);
  Map<String, dynamic> toJson() => _$CoachMessageToJson(this);
}
