import 'dart:async';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';

import 'widgets/trivia.dart';
import 'widgets/result.dart';
import 'api.dart';
import 'models/question.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  late Future<List<Trivia>> _futureTrivia;
  List<Trivia> _questions = [];
  late API data = API();

  var html = HtmlCharacterEntities.decode;
  //converts HTML entities in the string to their corresponding characters

  @override
  void initState() {
    super.initState();
    _futureTrivia = data.fetchData();
  }

  var _questionIndex = 0;
  var _score = 0;

  void _answerQuestion(String selectedAnswer) {
    var correctAnswer = _questions[_questionIndex].correct_answer;

    print('Question: ' + (_questionIndex + 1).toString());
    print('Answer: ' + correctAnswer);

    //check answer
    if (selectedAnswer == correctAnswer) {
      print('Correct');
      setState(() {
        _score = _score + 1;
      });
    } else {
      print('Wrong');
    }
    setState(() {
      _questionIndex = _questionIndex + 1;
    });
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      // reset question
      _futureTrivia = data.fetchData();
      _score = 0;
    });
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
            child: futureWidget() //Display the questions and answers
            ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget futureWidget() {
    return FutureBuilder<List<Trivia>>(
      future: _futureTrivia,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //List<Trivia> data = snapshot.data as List<Trivia>;
          _questions = snapshot.data!;
          return Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              child: Column(children: [
                _questionIndex < _questions.length
                    ? TriviaWidget(
                        questionIndex: _questionIndex,
                        questions: _questions,
                        answerQuestion: (String val) => _answerQuestion(val),
                      )
                    : Result(_score, _resetQuiz)
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
