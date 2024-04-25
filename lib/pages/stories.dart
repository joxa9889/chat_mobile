import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_project/datas/data.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StoriesPage extends StatefulWidget {
  final allStorieses;
  final which_user;

  const StoriesPage({
    super.key,
    required this.allStorieses,
    required this.which_user,
  });

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> with SingleTickerProviderStateMixin{
  PageController? _pageController;
  late AnimationController _animationController;
  VideoPlayerController? _videoController;
  int currentIndex = 0;
  String strUrl = '';
  

  videoSettings() {
    _pageController = PageController();
    _animationController = AnimationController(vsync: this);
    print(strUrl + 'media/' + widget.which_user['storieses'][currentIndex]['video']);
    _videoController = VideoPlayerController.networkUrl(Uri.parse(
      strUrl + 'media/' + widget.which_user['storieses'][currentIndex]['video']))
    ..initialize().then((_) { setState(() {});});
    _videoController!.play();
    print(widget.which_user);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          if (currentIndex + 1 < widget.which_user['storieses'][currentIndex]) {
            currentIndex += 1;
            _loadStory(story: widget.which_user['storieses'][[currentIndex]]);
          } else {
            Navigator.of(context).pop();
            currentIndex = 0;
            _loadStory(story: widget.which_user['storieses'][[currentIndex]]);
          }
        });
      }
    });
  }

  gettingUrl() async {
    var url = await Rooms().getStrUrl();
    setState(() {
      strUrl = url;
      print(strUrl);
    });
    videoSettings();
  }

  @override
  void initState() {
    super.initState();
    gettingUrl();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.which_user['storieses'][currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.which_user['storieses'].length,
          itemBuilder: (context, i) {
            String story = strUrl + 'media/' + widget.which_user['storieses'][i]['video'];
            if (widget.which_user['storieses'][i]['is_img']) {
              return CachedNetworkImage(
                imageUrl: story,
                fit: BoxFit.cover,
              );
            } else {
              if (_videoController != null && _videoController!.value.isInitialized) {
                return FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details, story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    
    if (dx < screenWidth / 3) {
      setState(() {
        if (currentIndex - 1 >= 0) {
          currentIndex -= 1;
          _loadStory(story: widget.which_user['storieses'][currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth) {
      setState(() {
        if (currentIndex + 1 < widget.which_user['storieses'].length) {
          currentIndex += 1;
          _loadStory(story: widget.which_user['storieses'][currentIndex]);
        } else {
          Navigator.of(context).pop();
          currentIndex = 0;
          _loadStory(story: widget.which_user['storieses'][currentIndex]);
        }
      });
    } else {
      if (!story['is_img']) {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _animationController.stop();
        } else {
          _videoController!.play();
          _animationController.forward();
        }
      }
    }
  }

  void _loadStory({story, bool animateToPage = true}) {
    _animationController.stop();
    _animationController.reset();
    if (story['is_img']) {
      _animationController.duration = Duration(seconds: 4);
      _animationController.forward();
    } else {
      _videoController = null;
      _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(Uri.parse('${strUrl + 'media/' + story['video']}'))
       ..initialize().then((_) {
        setState(() {});
        if (_videoController!.value.isInitialized) {
          _animationController.duration = _videoController!.value.duration;
          _videoController!.play();
          _animationController.forward();
        }
      });
    }
    if (animateToPage) {
      _pageController!.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 1), 
        curve: Curves.easeInOut
      );
    }
  }
}
