// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: (json['id'] as num).toInt(),
  text: json['text'] as String,
  image: json['image'] as String?,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  correctIndex: (json['correctIndex'] as num).toInt(),
  category: json['category'] as String,
  explanation: json['explanation'] as String?,
  xpReward: (json['xpReward'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'image': instance.image,
  'options': instance.options,
  'correctIndex': instance.correctIndex,
  'category': instance.category,
  'explanation': instance.explanation,
  'xpReward': instance.xpReward,
};
