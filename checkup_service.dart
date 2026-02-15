import '../models/question_model.dart';

class CheckupService {

  static List<Question> questions = [
    Question(
      text: "How often do you feel stressed?",
      options: ["Never", "Sometimes", "Often", "Always"],
      scores: [0, 1, 2, 3],
    ),
    Question(
      text: "Do you feel anxious without reason?",
      options: ["Never", "Rarely", "Sometimes", "Frequently"],
      scores: [0, 1, 2, 3],
    ),
    Question(
      text: "How well are you sleeping?",
      options: ["Very well", "Good", "Poor", "Very poor"],
      scores: [0, 1, 2, 3],
    ),
    Question(
      text: "Do you feel motivated daily?",
      options: ["Highly motivated", "Motivated", "Low", "Very low"],
      scores: [0, 1, 2, 3],
    ),
  ];

  static String getResult(int score) {
    if (score <= 3) {
      return "Your mental health looks good. Keep it up!";
    } else if (score <= 6) {
      return "Mild stress detected. Try relaxation and self-care.";
    } else if (score <= 9) {
      return "Moderate stress detected. Consider talking to someone.";
    } else {
      return "High stress detected. Professional help is recommended.";
    }
  }
}
