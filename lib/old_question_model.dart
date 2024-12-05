// import 'package:json_annotation/json_annotation.dart';
//
// part 'question_model.g.dart';
//
// @JsonSerializable()
// class Question {
//   final String type;
//   final String difficulty;
//   final String category;
//
//   @JsonKey(name: 'question')
//   final String question; // A questão em si
//
//   @JsonKey(name: 'correct_answer')
//   final String correctAnswer; // Resposta correta
//
//   @JsonKey(name: 'incorrect_answers')
//   final List<String> incorrectAnswers; // Respostas incorretas
//
//   Question({
//     required this.type,
//     required this.difficulty,
//     required this.category,
//     required this.question,
//     required this.correctAnswer,
//     required this.incorrectAnswers,
//   });
//
//   factory Question.fromJson(Map<String, dynamic> json) =>
//       _$QuestionFromJson(json);
//   Map<String, dynamic> toJson() => _$QuestionToJson(this);
// }
//
// @JsonSerializable()
// class ApiResponse {
//   @JsonKey(name: 'response_code')
//   final int responseCode;
//
//   final List<Question> results;
//
//   ApiResponse({required this.responseCode, required this.results});
//
//   factory ApiResponse.fromJson(Map<String, dynamic> json) =>
//       _$ApiResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
// }
