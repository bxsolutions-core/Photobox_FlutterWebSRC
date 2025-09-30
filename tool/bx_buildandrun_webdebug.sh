#!/bin/bash

echo "Building Flutter web (debug) project..."
flutter build web --debug --tree-shake-icons --pwa-strategy=offline-first --optimization-level=2

echo "Moving build to new directory..."
cp -r build/web/. /c/htdocs/eventpro.cheil.rocks/apps/DorcoSleekPhotobooth/

if [ $? -eq 0 ]; then
  echo "Move successful!"
else
  echo "Move failed. Check directory paths and permissions."
fi

