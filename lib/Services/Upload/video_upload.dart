import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoUpload extends StatefulWidget {
  final String labelText;
  final Function(File? video) onVideoPicked;
  final File? selectedVideo;
  final double videoHeight;
  final double videoWidth;

  const VideoUpload({
    Key? key,
    required this.labelText,
    required this.onVideoPicked,
    this.selectedVideo,
    this.videoHeight = 100.0,
    this.videoWidth = 100.0,
  }) : super(key: key);

  @override
  _VideoUploadState createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload> {
  final ImagePicker _picker = ImagePicker();
  File? selectedVideo;
  VideoPlayerController? _controller;
  bool isLoading = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedVideo != null) {
      _initializeVideo(widget.selectedVideo!);
    }
  }

  Future<void> _initializeVideo(File video) async {
    _disposeController();
    _controller = VideoPlayerController.file(video)
      ..initialize().then((_) {
        _controller!.setLooping(true);
        setState(() {});
      });
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }



  Future<void> _pickVideo(ImageSource source) async {
    try {
      setState(() => isLoading = true);

      final XFile? pickedFile = await _picker.pickVideo(source: source);
      if (pickedFile != null) {
        File videoFile = File(pickedFile.path);

        setState(() {
          selectedVideo = videoFile;
        });

        try {
          await _initializeVideo(videoFile);
        } catch (e) {
          debugPrint("Error initializing video: $e");
        }

        widget.onVideoPicked(videoFile);
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showVideoSourceDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select Source",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                const SizedBox(height: 12),
                ListTile(
                  leading:
                      const Icon(Icons.videocam, size: 28, color: Colors.black),
                  title: const Text("Camera",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library,
                      size: 28, color: Colors.black),
                  title: const Text("Gallery",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.labelText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: _showVideoSourceDialog,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: widget.videoHeight,
                    width: widget.videoWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 10, // Set desired height
                            width: 10, // Set desired width
                            child: CircularProgressIndicator(),
                          )
                        : (selectedVideo == null
                            ? const Icon(Icons.video_library,
                                color: Colors.grey)
                            : const Icon(Icons.check, color: Colors.grey)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedVideo == null
                    ? "No video selected"
                    : "Video selected successfully",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        if (selectedVideo != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: _controller != null && _controller!.value.isInitialized
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  VideoPlayer(_controller!),
                                  VideoProgressIndicator(_controller!,
                                      allowScrubbing: true),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 30),
                              onPressed: () {
                                setState(() {
                                  if (_controller!.value.isPlaying) {
                                    _controller!.pause();
                                  } else {
                                    _controller!.play();
                                  }
                                  isPlaying = _controller!.value.isPlaying;
                                });
                              },
                            ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              );
            },
            child: Container(
              height: 200,
              width: double.infinity,
              child: _controller != null && _controller!.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 50, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              if (_controller!.value.isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                              isPlaying = _controller!.value.isPlaying;
                            });
                          },
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ]
      ],
    );
  }
}
