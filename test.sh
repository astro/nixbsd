#!/usr/bin/env bash
set -ex

export NIX_PATH=${NIX_PATH-~/proj/nix}
export DESTDIR=${DESTDIR-~/proj/nix/main}
export DESTFILE=${DESTFILE-~/proj/nix/disk.img}
export PROFILE="$(nix-build '<nixbsd>' -A config.toplevel --no-out-link)"
export MAKEFS="$(nix-build '<nixpkgs>' -A freebsd.packages14.makefs --option substitute false)/bin/makefs"
export MKIMG="$(nix-build '<nixpkgs>' -A freebsd.packages14.mkimg --option substitute false)/bini/mkimg"
export TMPPART="$(mktemp)"

nix copy --no-check-sigs --to $DEST $PROFILE
sudo rm -rf $DEST/boot
cp -r $PROFILE/boot $DEST/boot
mkdir -p $DEST/dev
$MAKEFS -o version=2 -o label=main $TMPPART $DEST
$MKIMG -o $DESTFILE -s gpt -p freebsd-ufs/main:=$TMPPART
rm -f $TMPPART