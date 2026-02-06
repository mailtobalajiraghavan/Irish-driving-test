import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final int id;
  final String text;
  final String? image;
  final List<String> options;
  final int correctIndex;
  final String category;
  final String? explanation;
  @JsonKey(defaultValue: 10)
  final int xpReward;

  Question({
    required this.id,
    required this.text,
    this.image,
    required this.options,
    required this.correctIndex,
    required this.category,
    this.explanation,
    this.xpReward = 10,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
