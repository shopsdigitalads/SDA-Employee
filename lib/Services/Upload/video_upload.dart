import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/ErrorContainer.dart';
import 'package:video_player/video_player.dart';

class VideoUpload {
  final ImagePicker _picker = ImagePicker();

  Widget videoPickerField({
    required BuildContext context,
    required String labelText,
    required void Function(File? video) onVideoPicked,
    File? selectedVideo,
    double videoHeight = 100.0,
    double videoWidth = 100.0,
  }) {
    try {
       return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                File? video = await _showVideoSourceDialog(context);
                onVideoPicked(video);
              },
              child: Container(
                height: videoHeight,
                width: videoWidth,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: selectedVideo == null
                    ? Icon(
                        Icons.video_library,
                        color: Colors.grey,
                      )
                    : FutureBuilder<VideoPlayerController>(
                        future: _initializeVideoController(selectedVideo),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio:
                                    snapshot.data!.value.aspectRatio,
                                child: VideoPlayer(snapshot.data!),
                              ),
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
              ),
            ),
            SizedBox(width: 10),
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
      ],
    );
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: "Something Went Wrong");
       return ErrorContainer(errorMessage: 'An unexpected error occurred. Please try again.');
    }
   
  }

  /// Show dialog to select video source
  Future<File?> _showVideoSourceDialog(BuildContext context) async {
    
    try {
      final Completer<File?> completer = Completer<File?>();

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
                Text(
                  "Select Source",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                SizedBox(height: 12),
                ListTile(
                  leading:
                      Icon(Icons.videocam, size: 28, color: Colors.black),
                  title: Text("Camera",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: () async {
                    final video = await _pickVideo(ImageSource.camera);
                    Navigator.pop(context); // Close the dialog
                    completer.complete(video);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.video_library, size: 28, color: Colors.black),
                  title: Text("Gallery",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: () async {
                    final video = await _pickVideo(ImageSource.gallery);
                    Navigator.pop(context); // Close the dialog
                    completer.complete(video);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    return completer.future;
    } catch (e) {
      throw Exception("Error Occured");
    }
    
  }

  /// Pick a video from the specified source
  Future<File?> _pickVideo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
      throw Exception("Error Occured");
    }
    return null;
  }

  /// Initialize a video player controller for the selected video
  Future<VideoPlayerController> _initializeVideoController(File video) async {
    VideoPlayerController controller = VideoPlayerController.file(video);
    await controller.initialize();
    return controller;
  }
}
