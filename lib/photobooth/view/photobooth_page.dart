import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/stickers/stickers.dart';
import 'package:photobooth_ui/photobooth_ui.dart';

const _videoConstraints = VideoConstraints(
  facingMode: FacingMode(type: CameraType.user, constrain: Constrain.ideal),
  width: VideoSize(minimum: 480, ideal: 768, maximum: 1080),
  height: VideoSize(minimum: 640, ideal: 1024, maximum: 1440),
);

const _videoConstraintsRear = VideoConstraints(
  facingMode: FacingMode(
    type: CameraType.rear,
    constrain: Constrain.ideal,
  ),
  width: VideoSize(minimum: 600, ideal: 768, maximum: 1080),
  height: VideoSize(minimum: 800, ideal: 1024, maximum: 1440),
);

class PhotoboothPage extends StatelessWidget {
  const PhotoboothPage({super.key});

  static Route<void> route() {
    return AppPageRoute(builder: (_) => const PhotoboothPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhotoboothBloc(),
      child: Navigator(
        onGenerateRoute: (_) => AppPageRoute(
          builder: (_) => const PhotoboothView(),
        ),
      ),
    );
  }
}

class PhotoboothView extends StatefulWidget {
  const PhotoboothView({super.key});

  @override
  State<PhotoboothView> createState() => _PhotoboothViewState();
}

class _PhotoboothViewState extends State<PhotoboothView> {
  Key _childKey = UniqueKey();

  void _resetChild() => setState(() => _childKey = UniqueKey());

  CameraController _controller = CameraController(
    options: const CameraOptions(
      audio: AudioConstraints(),
      video: _videoConstraints,
    ),
  );

  bool get _isCameraAvailable =>
      _controller.value.status == CameraStatus.available;

  bool _switchingCamera = false;

  Future<void> _play() async {
    if (!_isCameraAvailable) return;
    return _controller.play();
  }

  Future<void> _stop() async {
    if (!_isCameraAvailable) return;
    return _controller.stop();
  }

  @override
  void initState() {
    super.initState();
    _initializeCameraController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeCameraController() async {
    await _controller.initialize();
    await _play();
  }

  Future<void> _onSnapPressed({required double aspectRatio}) async {
    final navigator = Navigator.of(context);
    final photoboothBloc = context.read<PhotoboothBloc>();
    final picture = await _controller.takePicture();
    photoboothBloc.add(PhotoCaptured(aspectRatio: aspectRatio, image: picture));
    final stickersPage = StickersPage.route();
    await _stop();
    unawaited(navigator.pushReplacement(stickersPage));
  }

  Future<void> _onToggleCameraType() async {
    setState(() => _switchingCamera = true);

    await _stop();

    if (_controller.options.video.facingMode?.type == CameraType.rear) {
      setState(() {
        _controller = CameraController(
          options: const CameraOptions(
            audio: AudioConstraints(),
            video: _videoConstraints,
          ),
        );
      });
    } else {
      setState(() {
        _controller = CameraController(
          options: const CameraOptions(
            audio: AudioConstraints(),
            video: _videoConstraintsRear,
          ),
        );
      });
    }

    debugPrint(
      '_cameraControllerType = ${_controller.options.video.facingMode?.type}',
    );

    await _initializeCameraController();

    setState(() => _switchingCamera = false);
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final aspectRatio = orientation == Orientation.portrait
        ? PhotoboothAspectRatio.portrait
        : PhotoboothAspectRatio.landscape;

    debugPrint('here: $orientation, $aspectRatio');
    return Scaffold(
      extendBody: true,
      body: _PhotoboothBackground(
        aspectRatio: aspectRatio,
        onSnapPressed: () => _onSnapPressed(aspectRatio: aspectRatio),
        child: _switchingCamera
            ? const Center(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(),
                ),
              )
            : Camera(
                controller: _controller,
                placeholder: (_) => const SizedBox(),
                preview: (context, preview) => PhotoboothPreview(
                  preview: preview,
                  onSnapPressed: () => _onSnapPressed(aspectRatio: aspectRatio),
                  onToggleCameraType: _onToggleCameraType,
                  aspectRatio: aspectRatio,
                ),
                error: (context, error) => PhotoboothError(error: error),
              ),
      ),
    );
  }
}

class _PhotoboothBackground extends StatelessWidget {
  const _PhotoboothBackground({
    required this.aspectRatio,
    required this.onSnapPressed,
    required this.child,
  });

  final double aspectRatio;
  final VoidCallback onSnapPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const PhotoboothBackground(),
        child,
      ],
    );
  }
}
