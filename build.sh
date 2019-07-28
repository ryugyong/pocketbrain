#!/bin/bash

# stole a bunch of this from
# https://github.com/phhusson/treble_experimentations/blob/700d6604f4ec0f8fda74a51764c1ea240c93cd11/build.sh

build_date="$(date +%y%m%d)"

originFolder="$(dirname "$0")"

set -e

#export LC_ALL=C

aosp="android-9.0.0_r43"
local_manifest="android-9.0"

cmd=$1

if [[ $cmd == "init" ]]; then
    echo "<><><><><><> INIT <><><><><><>"
    make clobber
    cmd="sync"
fi
    
if [[ $cmd == "sync" ]]; then
    echo "<><><><><><> SYNC <><><><><><>"
    (cd art/; git revert --abort || true)
    (rm -rf .repo/local_manifests/*)
    
    #mods
    cp -r $originFolder/local_manifests/* .repo/local_manifests/

    # sync'r up
    repo sync -c -j "$(nproc)" -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
    
    # my old ass server doesn't have SSE4.whatever instructions
    (cd art/; git revert --no-commit f60525793a1fd784ce7de82f18e7ad9de242c431)

    #(cd device/phh/treble; git clean -fdx; bash generate.sh)
    (cd vendor/foss; git clean -fdx; bash update.sh)

fi


export PATH=$(pwd)/../bin:$PATH
. build/envsetup.sh

lunch aosp_sailfish-eng
#make BUILD_NUMBER=$build_date installclean
#make BUILD_NUMBER=$build_date systemimage
m

# also a phhusson/treble_experimentations thing?:
#make BUILD_NUMBER=$build_date vndk-test-sepolicy

repo manifest -r > $OUT/manifest.xml
