#!/bin/zsh
# PROTOTYPE runner. Usage: ./run.sh [A|B|C] [HH:MM]   (or ./run.sh widthtest)
set -e
cd "${0:A:h}"
SIM=${SIM:-8D9AB872-7500-43F7-8C81-7C567FEDA9CA}   # Apple Watch Series 12 (46mm), watchOS 27.2
xcrun simctl boot $SIM 2>/dev/null || true
open -a Simulator
xcodebuild -project SpaceHipsterFacePrototype.xcodeproj -scheme SpaceHipsterFacePrototype \
  -destination "platform=watchOS Simulator,id=$SIM" -derivedDataPath build -quiet build
xcrun simctl install $SIM build/Build/Products/Debug-watchsimulator/SpaceHipsterFacePrototype.app
if [[ $1 == widthtest ]]; then ARGS=(-widthTest YES); else ARGS=(-variant ${1:-A}); [[ -n $2 ]] && ARGS+=(-fakeTime $2); fi
xcrun simctl launch --console-pty --terminate-running-process $SIM prototype.spacehipster.face $ARGS
