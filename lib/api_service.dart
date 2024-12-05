import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'https://opentdb.com/')
abstract class RestClient {
  factory RestClient(Dio dio, {String? baseUrl}) = _RestClient;

  @GET('/api.php?amount=10&category=9&difficulty=medium&type=boolean')
  Future<ApiResponse> getTasks(); // Retorna a estrutura completa
}

@JsonSerializable()
class ApiResponse {
  const ApiResponse({required this.responseCode, required this.results});

  @JsonKey(name: 'response_code')
  final int responseCode;

  final List<Task> results;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}

@JsonSerializable()
class Task {
  const Task({this.type, this.difficulty, this.category, this.question, this.correct_answer});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  final String? type;
  final String? difficulty;
  final String? category;
  final String? question;
  final String? correct_answer;

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
