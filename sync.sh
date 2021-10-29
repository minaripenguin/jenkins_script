repo init --depth=1 --no-repo-verify -u git://github.com/P-Arcana/Arcana_manifest -b S -g default,-device,-mips,-darwin,-notdefault
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
