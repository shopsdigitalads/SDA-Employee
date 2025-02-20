import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdaemployee/Services/State/admin_ads_state.dart';
import 'package:video_player/video_player.dart';

class AdsCarousel extends StatefulWidget {
  @override
  _AdsCarouselState createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  int _currentIndex = 0; // Track the active index

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    double screenHeight = MediaQuery.of(context).size.height;

    if (adProvider.isLoading) {
      return CarouselSlider(
          options: CarouselOptions(
            height: screenHeight * 0.23,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset("assets/logo.png"),
            )
          ]);
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: screenHeight * 0.23,
        autoPlay: true,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      items: adProvider.ads.isEmpty
          ? [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset("assets/logo.png"),
              )
            ]
          : adProvider.ads.asMap().entries.map((entry) {
              int index = entry.key;
              var ad = entry.value;

              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ad.type == "mp4"
                    ? VideoAdWidget(
                        videoPath: ad.filename,
                        isActive: _currentIndex == index)
                    : Image.file(
                        File(ad.filename),
                        fit: BoxFit.fill,
                      ),
              );
            }).toList(),
    );
  }
}

class VideoAdWidget extends StatefulWidget {
  final String videoPath;
  final bool isActive; // To check if the video should play

  VideoAdWidget({required this.videoPath, required this.isActive});

  @override
  _VideoAdWidgetState createState() => _VideoAdWidgetState();
}

class _VideoAdWidgetState extends State<VideoAdWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        if (widget.isActive) {
          _controller.play();
        }
        _controller.setLooping(true);
      });
  }

  @override
  void didUpdateWidget(VideoAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: VideoPlayer(_controller),
          )
        : Center(
            child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset("assets/logo.png"),
          ));
  }
}
