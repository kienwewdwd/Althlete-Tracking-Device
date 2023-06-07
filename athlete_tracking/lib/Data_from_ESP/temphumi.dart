import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'temphumi.g.dart';

@JsonSerializable(explicitToJson: true)
class DataRunning {
  DataRunning(this.heartRate, this.distance, this.speedRunning,
      this.heart_rate_average, this.speed_average, this.time_activity, this.ECG_signal);
  double heartRate;
  double distance;
  double speedRunning;
  double speed_average;
  double heart_rate_average;
  double time_activity;
  double ECG_signal;

  factory DataRunning.fromJson(Map<String, dynamic> json) =>
      _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}
