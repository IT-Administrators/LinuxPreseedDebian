# Author: IT-Administrators
# License: UNLICENSE
# OS: Debian
# /bin/bash <scriptname> <isofile> <preseedfile>

#!/bin/bash

# ----DESCRIPTION
# This script rebuilds the specified iso and includes a preseed.cfg file.
# It is only supposed to be used with debian isos.
# And not tested on other distros.
# ----END

# Check if script is run as sudo, if not exit.
if [[ $(id -u) -ne 0 ]]
    then echo Please run this script as root or using sudo!
    exit
fi

# Create array with software dependencies.
sw=(genisoimage syslinux-utils)
# Check if software is installed.
for s in ${sw[@]}
do
    echo "Checking if $s is installed."
    # Save command ouput to variable.
    res=$(dpkg-query -l | grep $s)
    # Check if result of command is empty.
    if [[ -z "$res" ]]
        then
            echo "Software $s not installed."
            echo "Installing $s."
            sudo apt install $s
    else
        echo "$s already installed."
    fi
done

# Variable from stdin.
ISOIN="$1"
PRESEEDIN="$2"

# Assign command output to variable.
# Get directory name.
isoDir=$(dirname $ISOIN)
# Get file name.
isoFileName=$(basename $ISOIN)
# Build new filename.
isoOut=preseed-${isoFileName}
# Build new filename complete path.
isoOutPath=$isoDir/$isoOut

echo "Creating directories"
mkdir $isoDir/default-iso $isoDir/new-iso

echo "Mounting $ISOIN to $isoDir/default-iso"
sudo mount -o loop $ISOIN $isoDir/default-iso

sudo cp -rT $isoDir/default-iso/ $isoDir/new-iso/

sudo umount $isoDir/default-iso
cp $PRESEEDIN $isoDir/new-iso

sudo genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $isoOutPath $isoDir/new-iso

# Optional. If iso will be used for VMs as well.
sudo isohybrid $isoOutPath

sudo rm -rf $isoDir/new-iso $isoDir/default-iso