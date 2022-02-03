import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_character_entities/html_character_entities.dart';

//import './quiz.dart';
//import './result.dart';

class Trivia {
  final String question;
  final String correct_answer;
  final List<String> incorrect_answers;
  final List<String> answers;

  Trivia({
    required this.question,
    required this.correct_answer,
    required this.incorrect_answers,
    required this.answers,
  });

  factory Trivia.fromJson(Map<String, dynamic> json) => Trivia(
        question: json["question"],
        correct_answer: json["correct_answer"],
        incorrect_answers:
            List<String>.from(json["incorrect_answers"].map((x) => x)),
        answers: List<String>.from(json['incorrect_answers'])
          ..add(json['correct_answer'])
          ..shuffle(),
      );
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  late Future<List<Trivia>> futureTrivia;
  List<dynamic> question = [];
  List<Trivia> questions = [];
  var html = HtmlCharacterEntities.decode;
  //converts HTML entities in the string to their corresponding characters

  Future<List<Trivia>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://opentdb.com/api.php?amount=5&category=22&difficulty=easy&type=multiple'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      List jsonResponse = json.decode(response.body)['results'];
      setState(() {
        question = jsonResponse;
      });
      questions = jsonResponse.map((data) => Trivia.fromJson(data)).toList();
      return questions;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureTrivia = fetchData();
  }

  var _questionIndex = 0;
  var selectedAnswer = 0;
  var _score = 0;

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      // reset question
      displayData();
      _score = 0;
    });
  }

  /*void _answerQuestion(int score) {

    _totalScore += score;

    setState(() {
      _questionIndex = _questionIndex + 1;
    });
    print(_questionIndex);
    if (_questionIndex < _questions.length) {
      print('We have more questions!');
    } else {
      print('No more questions!');
    }
  }*/

  void _answerQuestion(String selectedAnswer) {
    setState(() {
      if (selectedAnswer == questions[_questionIndex].correct_answer) {
        _score = _score + 1;
      }
      _questionIndex = _questionIndex + 1;
    });
    print(_questionIndex);
    if (_questionIndex < questions.length) {
      print('We have more questions!');
    } else {
      print('No more questions!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My First App'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(30.0),
            child:
                _questionIndex < questions.length ? displayData() : result()),
      ),

      /*? Quiz(
                answerQuestion: _answerQuestion,
                questionIndex: _questionIndex,
                questions: _questions,
              )
            : Result(_totalScore, _resetQuiz),*/

      debugShowCheckedModeBanner: false,
    );
  }

  Widget displayData() {
    return FutureBuilder<List<Trivia>>(
      future: futureTrivia,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //List<Trivia> data = snapshot.data as List<Trivia>;
          return Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              child: Column(children: [
                Text(
                    '${_questionIndex + 1}. ${html(snapshot.data![_questionIndex].question)}'),
                ...(snapshot.data![_questionIndex].answers)
                    .map(
                      (data) => Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text(html(data)),
                          onPressed: () => _answerQuestion(data),
                        ),
                      ),
                    )
                    .toList(),
              ]));
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }

  Widget result() {
    return Column(children: [
      Text('Score: ${_score}/10'),
      SizedBox(height: 20,),
      FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text('Restart Quiz'),
        onPressed: _resetQuiz,
      )
    ]);
  }
}
