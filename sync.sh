#!/bin/bash
repo init --depth=1 --no-repo-verify -u git://github.com/ArcaneOS/Arcane_manifest -b R -g default,-device,-mips,-darwin,-notdefault
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
