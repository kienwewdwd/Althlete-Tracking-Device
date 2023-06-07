part of 'temphumi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataRunning _$DataFromJson(Map<String, dynamic> json) => DataRunning(
      (json['heartRate'] as num).toDouble(),
      (json['distance'] as num).toDouble(),
      (json['speedRunning'] as num).toDouble(),
      (json['Speed_Average'] as num).toDouble(),
      (json['heartRate_Average'] as num).toDouble(),
      (json['TimeAcitivity'] as num).toDouble(),
      (json['ECGSignal'] as num).toDouble(),
      
    );

Map<String, dynamic> _$DataToJson(DataRunning instance) => <String, dynamic>{
      'heartRate': instance.heartRate,
      'distance': instance.distance,
      'speedRunning': instance.speedRunning,
      'Speed_Average': instance.speed_average,
      'heartRate_Average': instance.heart_rate_average,
      'TimeAcitivity': instance.time_activity,
      'ECGSignal': instance.ECG_signal
    };
