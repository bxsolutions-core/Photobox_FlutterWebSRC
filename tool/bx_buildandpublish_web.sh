#!/bin/bash

flutter clean
# Find all directories containing a pubspec.yaml file
find . -name "pubspec.yaml" | while read -r pubspec_path; do
    # Get the parent directory of the pubspec.yaml
    package_dir=$(dirname "$pubspec_path")

    echo "Running flutter pub get in: $package_dir"
    (cd "$package_dir" && flutter pub get)
    echo "Finished flutter pub get in: $package_dir"
done

echo "Building Flutter web (debug) project..."
flutter build web --debug --tree-shake-icons --pwa-strategy=offline-first --optimization-level=2

echo "Moving build to new directory..."
cp -r build/web/. /c/htdocs/eventpro.cheil.rocks/apps/DorcoSleekPhotobooth/

if [ $? -eq 0 ]; then
  echo "Move successful!"
else
  echo "Move failed. Check directory paths and permissions."
fi

