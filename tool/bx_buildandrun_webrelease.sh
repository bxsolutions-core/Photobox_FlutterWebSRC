#!/bin/bash

echo "Building Flutter web (release) project..."
flutter build web --release

echo "Moving build to new directory..."
cp -r build/web/. /c/htdocs/eventpro.cheil.rocks/apps/DorcoSleekPhotobooth/

if [ $? -eq 0 ]; then
  echo "Move successful!"
else
  echo "Move failed. Check directory paths and permissions."
fi

