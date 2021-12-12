#!/bin/bash

user="dlwlrma123"  
lunch_command="aosp"
device_codename="pine"
build_type="userdebug"

# Rom G-Apps Command

gapps_command="" 
with_gapps="<no>"

# To build with gapps or no )(yes|no)

# Make command  : yes|no|bacon
# yes for brunch 
# no make romname 
# Add bacon for make bacon
# mka for making bacon with mka 

use_brunch="bacon" 

# Folder Name 

if [ -d "/home/${user}" ]; 
then
	folder="/home/${user}/arcana"
else
	folder="/home2/${user}/arcana"
fi

rom_name="ProjectArcana"*.zip # Zip name
OUT_PATH="$folder/out/target/product/${device_codename}"
ROM=${OUT_PATH}/${rom_name}
A12="yes" # If you are building a12 set this to yes.

# If  building apk put the apk name here.

target_name="<no>"

# Cccahe Variables

cache_folder=${folder}/ccache # Overwritten if a12.
cache_size=50G # In GB
enable_cache=1 # The value of the boolean to enable cache usually 1 or true.

# Uncomment set to (yes|no(default)|installclean)

# make_clean="installclean"
# make_clean="yes"

newpeeps="/home/configs/"${user}.conf
baseconfig=/home/configs/priv.conf

cd "$folder"

echo -e "Build starting thank you for waiting"
BLINK="https://ci.goindi.org/job/$JOB_NAME/$BUILD_ID/console"

read -r -d '' priv <<EOT
<b>Build Number : $BUILD_ID Started</b> 
<b>Console log:</b> <a href="${BLINK}">here</a>
<b>Happy Building</b>
EOT

sudo telegram-send --format html "$priv" --config ${newpeeps} --disable-web-page-preview

# Ccache 

export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=${enable_cache}
export CCACHE_DIR=${cache_folder}
ccache -M ${cache_size}

if [ "A12" = "yes" ]; 
then
export CCACHE_DIR=/ccache/${user}
fi

if [ -d ${CCACHE_DIR} ]; then

	sudo chmod 777 ${CCACHE_DIR}
	echo "ccache folder already exists."

else

	sudo mkdir ${CCACHE_DIR}
	sudo chmod 777 ${CCACHE_DIR}
	echo "modifying ccache dir permission."
fi

# Building 

source build/envsetup.sh

if [ "$with_gapps" = "yes" ]; 
then
	export "$gapps_command"=true
else
	export "$gapps_command"=false
fi

if [ "$make_clean" = "yes" ]; 
then
	rm -rf out 
	echo -e "Clean Build";
fi

if [ "$make_clean" = "installclean" ]; 
then
	rm -rf ${OUT_PATH}
	echo -e "Install Clean";
fi

rm -rf ${OUT_PATH}/*.zip
lunch ${lunch_command}_${device_codename}-${build_type}

if [ "$target_name" = "<no>" ]; 
then

	if [ "$use_brunch" = "yes" ]; 
	then
		brunch ${device_codename}
	fi
	
	if [ "$use_brunch" = "no" ]; 
	then
		make  ${lunch_command} -j$(nproc --all)
	fi
	
	if [ "$use_brunch" = "bacon" ];
	then
		make bacon -j$(nproc --all)
	fi

	if [ "$use_brunch" = "mka" ];
	then
		mka bacon -j$(nproc --all)
	fi

else
	make $target_name
fi

if [ -f $ROM ]; 
then

	mkdir -p /home/downloads/${user}/${device_codename}
	cp $ROM /home/downloads/${user}/${device_codename}

	filename="$(basename $ROM)"
	LINK="https://download.goindi.org/${user}/${device_codename}/${filename}"
	size="$(du -h ${ROM}|awk '{print $1}')"
	mdsum="$(md5sum ${ROM}|awk '{print $1}')"

	read -r -d '' priv <<EOT
	<b>Build Number : $BUILD_ID Completed</b>

	<b>Rom:</b> ${lunch_command} 

	<b>Size:</b> <pre> ${size}</pre>
	<b>MD5:</b> <pre> ${mdsum}</pre>

	<b>Download:</b> <a href="${LINK}">here</a>
EOT

else

	read -r -d '' priv <<EOT
	<b>Build Number : $BUILD_ID Failed</b>

	<b>Error : </b> <a href="https://ci.goindi.org/job/$JOB_NAME/$BUILD_ID/console">here</a>
	
EOT
fi

sudo telegram-send --format html "$priv" --config ${newpeeps} --disable-web-page-preview

read -r -d '' promo <<EOT
<b>HEY DID YOU KNOW</b>

If you have any problems you contact @kunalgrowth or @irongfly
and if you get get more people to sign up you can get a discount.
EOT

if (( $BUILD_ID % 50 == 0 ))  ;
then
    sudo telegram-send --format html "$promo" --config ${newpeeps}
fi

read -r -d '' track <<EOT
Build for ${user} 
Build ID : ${BUILD_ID}
Rom : ${lunch_command}
EOT

sudo telegram-send --format html "$track" --config ${baseconfig}
