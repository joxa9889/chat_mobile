import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({
    super.key,
  });

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {

  int currentStoryIndex = 0;

  List<Map<String, dynamic>> stories = [
    {
      'watched_precent': 0.0,
      'color': Colors.red,
    },
    {
      'watched_precent': 0.0,
      'color': Colors.deepOrange
    },
    {
      'watched_precent': 0.0,
      'color': Colors.deepPurple
    },
  ];

  @override
  void initState() {
    super.initState();
    startWatching();
  }

  void startWatching() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (stories[currentStoryIndex]['watched_precent'] + 0.01 <= 1){
          stories[currentStoryIndex]['watched_precent'] += 0.01;
        } else {
          stories[currentStoryIndex]['watched_precent'] = 1.0;
          timer.cancel();
          if (currentStoryIndex < stories.length -1) {
            currentStoryIndex ++;
            startWatching();
          } else {
            Navigator.pop(context);
          }
        }
      });
      
    });
  }

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double position = details.globalPosition.dx;
    if (screenWidth / 2 > position) {
      if (currentStoryIndex > 0) {
        stories[currentStoryIndex-1]['watched_precent'] = 0.0;
        stories[currentStoryIndex]['watched_precent'] = 0.0;
        currentStoryIndex --;
      }
    } else {
        if (currentStoryIndex < stories.length - 1) {
          stories[currentStoryIndex]['watched_precent'] = 1.0;
          currentStoryIndex ++;
        } else {
          if (currentStoryIndex < stories.length - 1) {
            stories[currentStoryIndex]['watched_precent'] = 1.0;
            currentStoryIndex++;
          } else {
            stories[currentStoryIndex]['watched_precent'] = 1.0;
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _onTapDown(details),
      child: Scaffold(
        backgroundColor: Colors.deepOrange,
        body: Stack(
          children: [
            Container(
              color: stories[currentStoryIndex]['color'],
            ),
            Container(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                children: List.generate(
                  stories.length, 
                  (index) => Expanded(
                    child: LinearPercentIndicator(
                      lineHeight: 15,
                      percent: stories[index]['watched_precent'],
                      progressColor: const Color.fromARGB(255, 140, 139, 139),
                      barRadius: const Radius.circular(10),
                    ),
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}