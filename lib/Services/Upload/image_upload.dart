import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUpload extends StatefulWidget {
  final String labelText;
  final Function(File? image) onImagePicked;
  final File? selectedImage;
  final double imageHeight;
  final double imageWidth;

  const ImageUpload({
    Key? key,
    required this.labelText,
    required this.onImagePicked,
    this.selectedImage,
    this.imageHeight = 100.0,
    this.imageWidth = 100.0,
  }) : super(key: key);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.selectedImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => isLoading = true);
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        
        // Compress the image if needed
        File? compressedFile = await compressImageIfNeeded(imageFile);

        setState(() {
          selectedImage = compressedFile;
        });

        widget.onImagePicked(compressedFile);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showImageSourceDialog() {
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
                  leading: const Icon(Icons.camera_alt, size: 28, color: Colors.black),
                  title: const Text("Camera",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo, size: 28, color: Colors.black),
                  title: const Text("Gallery",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
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
              onTap: _showImageSourceDialog,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: widget.imageHeight,
                    width: widget.imageWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 10, // Set desired height
                            width: 10, // Set desired width
                            child: CircularProgressIndicator(),
                          )
                        : (selectedImage == null
                            ? const Icon(Icons.add_a_photo,
                                color: Colors.grey)
                            : const Icon(Icons.check, color: Colors.grey)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedImage == null
                    ? "No image selected"
                    : "Image selected successfully",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        if (selectedImage != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(
                    child: Image.file(selectedImage!),
                  ),
                ),
              );
            },
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(selectedImage!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  /// Compress image to max 10MB
  Future<File?> compressImageIfNeeded(File file, {int maxSizeInMB = 10}) async {
    int fileSizeMB = file.lengthSync() ~/ (1024 * 1024);

    if (fileSizeMB <= maxSizeInMB) {
      print("No compression needed. Image size: ${fileSizeMB}MB");
      return file;
    }

    print("Compressing... Original Size: ${fileSizeMB}MB");
    return await compressImageToMaxSize(file, maxSizeInMB);
  }

  /// Compress image iteratively until it's ≤ 10MB
  Future<File?> compressImageToMaxSize(File file, int maxSizeInMB) async {
    int maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    int quality = 100;
    final tempDir = await getTemporaryDirectory();
    String targetPath = '${tempDir.path}/compressed.jpg';

    // Resize first if image is too large
    Uint8List resizedBytes = await resizeImage(file, maxWidth: 1920);
    File resizedFile = await saveUint8ListToFile(resizedBytes, '${tempDir.path}/resized.jpg');

    File? compressedFile = resizedFile;

    // Iteratively compress until ≤ 10MB
    while (compressedFile!.lengthSync() > maxSizeInBytes && quality > 10) {
      quality -= 10;
      final result = await FlutterImageCompress.compressAndGetFile(
        compressedFile.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result != null) {
        compressedFile = File(result.path);
      }
    }

    print("Compressed Size: ${compressedFile.lengthSync() / (1024 * 1024)}MB");
    return compressedFile;
  }

  /// Resize image
  Future<Uint8List> resizeImage(File file, {int maxWidth = 1920}) async {
    final imageBytes = await file.readAsBytes();
    img.Image image = img.decodeImage(imageBytes)!;

    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 100));
  }

  /// Save Uint8List to file
  Future<File> saveUint8ListToFile(Uint8List bytes, String filePath) async {
    File file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }
}
