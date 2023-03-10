#make a variable named SAFE
SAFE=1

#first of all, test internet connection, without using wget
ping -c 1 google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "No internet connection :("
    exit 1
else
    echo "Internet connection OK"
fi
echo ""
echo "This script is intended to be ran from a livecd image."
echo "It will install gentoo on your hard drive."
echo ""
echo "It currently supports amd64 compatible machines."
echo "(im trying my best ok.)"
echo ""
echo "!!THIS ONLY WORKS ON UEFI MACHINES!!"
echo ""

lsblk
echo ""
echo "Please enter the full path of the drive you want to install gentoo on."
echo "Example: /dev/sda"
echo ""
read -p "Drive: " drive
echo ""
echo "THIS WILL ERASE THE TABLES FOR $drive, ARE YOU SURE YOU WANT TO CONTINUE?"
echo "Type 'yes' to continue."
read -p "Continue: " continue
if [ "$continue" != "yes" ]; then
    echo "Aborting..."
    exit 1
fi
#remove partition table on drive
#if safe == 0 then do this step
if [ $SAFE -eq 0 ]; then
    echo "Removing partition table..."
    sgdisk -Z $drive
    echo "Partition table removed."
else
    echo "Skipping partition table removal from SAFE..."
fi
