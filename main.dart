import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

//import './quiz.dart';
//import './result.dart';

//nazurah: buat interface, score, random susunan answer

class Trivia {
  final String question;
  final String correct_answer;
  final List<String> incorrect_answers;

  Trivia({
    required this.question,
    required this.correct_answer,
    required this.incorrect_answers,
  });

  factory Trivia.fromJson(Map<String, dynamic> json) => Trivia(
        question: json["question"],
        correct_answer: json["correct_answer"],
        incorrect_answers:
            List<String>.from(json["incorrect_answers"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "question": question,
        "correct_answer": correct_answer,
        "incorrect_answers":
            List<dynamic>.from(incorrect_answers.map((x) => x)),
      };
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
      return jsonResponse.map((data) => Trivia.fromJson(data)).toList();

      //return Trivia.fromJson(jsonDecode(response.body));
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
  var _totalScore = 0;

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      // reset question
      futureTrivia = fetchData(); 
      //_totalScore = 0;
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

  void _answerQuestion() {
    setState(() {
      _questionIndex = _questionIndex + 1;
    });
    print(_questionIndex);
    if (_questionIndex < question.length) {
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
          child: _questionIndex < question.length
              ? displayData()
              : FlatButton(
                  color: Color(0xFF00E676),
                  textColor: Colors.white,
                  child: Text('Play again'),
                  onPressed: _resetQuiz,
                ),
        ),
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
                Text('${_questionIndex+1}. ${snapshot.data![_questionIndex].question}'),
                RaisedButton(
                  color: Color(0xFF00E676),
                  textColor: Colors.white,
                  child: Text(
                      'answer: ${snapshot.data![_questionIndex].correct_answer}'),
                  onPressed: _answerQuestion,
                ),
                RaisedButton(
                  color: Color(0xFF00E676),
                  textColor: Colors.white,
                  child: Text(
                      'incorrect answer: ${snapshot.data![_questionIndex].incorrect_answers[0]}'),
                  onPressed: _answerQuestion,
                ),
                RaisedButton(
                  color: Color(0xFF00E676),
                  textColor: Colors.white,
                  child: Text(
                      'incorrect answer: ${snapshot.data![_questionIndex].incorrect_answers[1]}'),
                  onPressed: _answerQuestion,
                ),
                RaisedButton(
                  color: Color(0xFF00E676),
                  textColor: Colors.white,
                  child: Text(
                      'incorrect answer: ${snapshot.data![_questionIndex].incorrect_answers[2]}'),
                  onPressed: _answerQuestion,
                ),
              ]));
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }
}
