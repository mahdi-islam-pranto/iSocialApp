import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../../utilities/permission_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String fileName;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _isCompleted = false; // Track if audio playback has completed
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();

      // Configure the audio session for playback
      try {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());
      } catch (e) {
        debugPrint("Error configuring audio session: $e");
        // Continue anyway, as this is not critical
      }

      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted && state.playing != _isPlaying) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      // Listen to processing state changes to detect completion
      _audioPlayer.processingStateStream.listen((processingState) {
        if (mounted && processingState == ProcessingState.completed) {
          setState(() {
            _isCompleted = true;
            _isPlaying = false;
          });
        }
      });

      // Listen to duration changes
      _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });

      // Listen to position changes
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      // Load the audio file
      try {
        await _audioPlayer.setUrl(widget.audioUrl);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error loading audio URL: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Error loading audio: $e";
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing audio player: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Could not initialize audio player: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _downloadAudio() async {
    try {
      setState(() {
        _isDownloading = true;
      });

      // Request storage permission using the centralized permission service
      bool permissionGranted =
          await PermissionService.requestStoragePermission(context);
      if (!permissionGranted) {
        setState(() {
          _isDownloading = false;
        });
        return;
      }

      // Download the file
      final response = await http.get(Uri.parse(widget.audioUrl));
      if (response.statusCode == 200) {
        // Get the download directory
        Directory? directory;
        if (Platform.isAndroid) {
          try {
            // Try to use the Download directory first
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              // If it doesn't exist, fall back to app documents directory
              directory = await getApplicationDocumentsDirectory();
            }
          } catch (e) {
            // If there's any issue, fall back to app documents directory
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        // Create file name
        String filePath = '${directory.path}/${widget.fileName}';

        // Write the file
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Audio downloaded successfully to",
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Text(
                    filePath,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        throw Exception("Failed to download audio");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading audio: $e")),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SpinKitWave(
            color: Colors.blue,
            size: 30.sp,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red[800]),
        ),
      );
    }

// main container widget for audio in the UI
    return Container(
      // height: 90.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.audio_file, color: Colors.blue, size: 18.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.fileName,
                  style:
                      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _isDownloading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.download, size: 18.sp),
                      color: Colors.blue,
                      onPressed: _downloadAudio,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 1.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              min: 0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                final position = Duration(seconds: value.toInt());
                _audioPlayer.seek(position);

                // If the audio was completed and user seeks, reset the completed state
                if (_isCompleted) {
                  setState(() {
                    _isCompleted = false;
                  });
                }
              },
            ),
          ),

          // Duration and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(fontSize: 12.sp),
              ),
              IconButton(
                icon: Icon(
                  _isCompleted
                      ? Icons.replay_circle_filled
                      : (_isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled),
                  size: 30.sp,
                  color: Colors.blue,
                ),
                onPressed: () {
                  if (_isCompleted) {
                    // Restart the audio from the beginning
                    _audioPlayer.seek(Duration.zero);
                    _audioPlayer.play();
                    setState(() {
                      _isCompleted = false;
                      _isPlaying = true;
                    });
                  } else if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
