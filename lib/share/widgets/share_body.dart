import 'dart:typed_data';

import 'package:analytics/analytics.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/external_links/external_links.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ShareBody extends StatelessWidget {
  const ShareBody({super.key});

  @override
  Widget build(BuildContext context) {
    final image = context.select((PhotoboothBloc bloc) => bloc.state.image);
    final file = context.select((ShareBloc bloc) => bloc.state.file);
    final compositeStatus = context.select(
      (ShareBloc bloc) => bloc.state.compositeStatus,
    );
    final compositedImage = context.select(
      (ShareBloc bloc) => bloc.state.bytes,
    );
    final isUploadSuccess = context.select(
      (ShareBloc bloc) => bloc.state.uploadStatus.isSuccess,
    );
    final shareUrl = context.select(
      (ShareBloc bloc) => bloc.state.explicitShareUrl,
    );

    debugPrint('SharePage.Body() ::-> ${file?.name}');
    final qrData = 'dorcoprint://${file?.name}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AnimatedPhotoIndicator(),

          if (compositeStatus.isSuccess)
            AnimatedFadeIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  if (isUploadSuccess)
                    Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(
                        maxWidth: 160,
                        maxHeight: 160,
                      ),
                      child: PrettyQrView.data(
                        data: qrData,
                        decoration: const PrettyQrDecoration(
                          background: Colors.white,
                          // image: PrettyQrDecorationImage(
                          //   image: AssetImage('assets/icons/dorco_icon.png'),
                          // ),
                          quietZone: PrettyQrQuietZone.pixels(8),
                        ),
                      ),
                    ),

                  if (compositedImage != null && file != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 64),
                        Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          child: SharePreviewPhoto(image: compositedImage),
                        ),
                        const SizedBox(height: 30),
                        ResponsiveLayoutBuilder(
                          small: (_, __) => MobileButtonsLayout(
                            image: compositedImage,
                            file: file,
                          ),
                          large: (_, __) => DesktopButtonsLayout(
                            image: compositedImage,
                            file: file,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

          if (compositeStatus.isFailure)
            const AnimatedFadeIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  ShareErrorHeading(),
                  SizedBox(height: 20),
                  ShareErrorSubheading(),
                  SizedBox(height: 30),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

@visibleForTesting
class DesktopButtonsLayout extends StatelessWidget {
  const DesktopButtonsLayout({
    required this.image,
    required this.file,
    super.key,
  });

  final Uint8List image;
  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: DownloadButton(file: file)),
        const SizedBox(width: 36),
        Flexible(child: ShareButton(image: image)),
        // const SizedBox(width: 36),
        // const GoToGoogleIOButton(),
      ],
    );
  }
}

@visibleForTesting
class MobileButtonsLayout extends StatelessWidget {
  const MobileButtonsLayout({
    required this.image,
    required this.file,
    super.key,
  });

  final Uint8List image;
  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DownloadButton(file: file),
        // const SizedBox(height: 20),
        // ShareButton(image: image),
        // const SizedBox(height: 20),
        // const GoToGoogleIOButton(),
      ],
    );
  }
}

@visibleForTesting
class GoToGoogleIOButton extends StatelessWidget {
  const GoToGoogleIOButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: PhotoboothColors.white,
      ),
      onPressed: launchGoogleIOLink,
      child: Text(
        l10n.goToGoogleIOButtonText,
        style: theme.textTheme.labelLarge?.copyWith(
          color: PhotoboothColors.black,
        ),
      ),
    );
  }
}

@visibleForTesting
class DownloadButton extends StatelessWidget {
  const DownloadButton({required this.file, super.key});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OutlinedButton(
      onPressed: () {
        trackEvent(
          category: 'button',
          action: 'click-download-photo',
          label: 'download-photo',
        );
        file.saveTo('');
      },
      child: Text(l10n.sharePageDownloadButtonText),
    );
  }
}
