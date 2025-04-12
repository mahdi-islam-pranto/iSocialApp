import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenImageView extends StatelessWidget {
  final String? imageUrl;
  final String? localFilePath;
  final String heroTag;

  const FullScreenImageView({
    Key? key,
    this.imageUrl,
    this.localFilePath,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set system overlay style to ensure visibility of status bar icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image with interactive viewer for zoom and pan
          GestureDetector(
            onTap: () {
              // Toggle app bar visibility on tap
              Navigator.pop(context);
            },
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: heroTag,
                  child: _buildImage(),
                ),
              ),
            ),
          ),
          
          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (localFilePath != null && localFilePath!.isNotEmpty) {
      return Image.file(
        File(localFilePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("Error loading local image: $error");
          return const Center(
            child: Text(
              "Error loading image",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("Error loading network image: $error");
          return const Center(
            child: Text(
              "Error loading image",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text(
          "No image available",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
