#!/bin/bash

sigfile=`ls -1 libsodium-*-stable.tar.gz.minisig`
srcfile=`basename $sigfile .minisig`
echo $srcfile
srcdir='libsodium-stable'
echo $srcdir

# --------------------------
# Download and verify source
# --------------------------
[ -f $srcfile ] && rm -f $srcfile
curl https://download.libsodium.org/libsodium/releases/$srcfile > $srcfile
# gpg --no-default-keyring --keyring `pwd`/trusted.gpg --verify $sigfile $srcfile || exit 1

# --------------------------
# Extract sources
# --------------------------
[ -e $srcdir ] && rm -Rf $srcdir
tar -xzf $srcfile
cd $srcdir

targetPlatforms="$@"
[ "$targetPlatforms" ] || targetPlatforms="arm x86 ios"

for targetPlatform in $targetPlatforms
do
  # --------------------------
  # iOS build
  # --------------------------
  platform=`uname`
  if [ "$platform" == 'Darwin' ] && [ "$targetPlatform" == 'ios' ]; then
    IOS_VERSION_MIN=9.0 dist-build/ios.sh
  fi

  # --------------------------
  # Android build
  # --------------------------
  # case $targetPlatform in
  #   "arm-old")
  #     NDK_PLATFORM=android-21 dist-build/android-arm.sh
  #     ;;
  #   "arm")
  #     NDK_PLATFORM=android-21 dist-build/android-armv7-a.sh
  #     NDK_PLATFORM=android-21 dist-build/android-armv8-a.sh
  #     ;;
  #   "mips")
  #     NDK_PLATFORM=android-21 dist-build/android-mips32.sh
  #     NDK_PLATFORM=android-21 dist-build/android-mips64.sh
  #     ;;
  #   "x86")
  #     NDK_PLATFORM=android-21 dist-build/android-x86.sh
  #     NDK_PLATFORM=android-21 dist-build/android-x86_64.sh
  #   ;;
  # esac

done
cd ..


# --------------------------
# Move compiled libraries
# --------------------------
mkdir -p libsodium
rm -Rf libsodium/*

for dir in $srcdir/libsodium-android-*
do
  mv $dir libsodium/
done

if [ "$platform" == 'Darwin' ] && [ -e $srcdir/libsodium-ios ]; then
  mv $srcdir/libsodium-ios libsodium/
fi

# --------------------------
# Update precompiled.tgz
# --------------------------
tar -cvzf precompiled.tgz libsodium


# --------------------------
# Cleanup
# --------------------------
[ -e $srcdir ] && rm -Rf $srcdir
[ -e $srcfile ] && rm $srcfile
