#make a variable named SAFE
SAFE=0

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

echo "Toolcheck..."
#check if sgdisk is installed
sgdisk --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "sgdisk is not installed, aborting..."
    exit 1
else
    echo "sgdisk is installed."
fi
#check if wget is installed
wget --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "wget is not installed, aborting..."
    exit 1
else
    echo "wget is installed."
fi

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
#well be using fdisk to create the partitions
#should be 100MB FAT32 EFI,
#4GB swap,
#rest of the drive ext4
#make the partitions
echo "Creating partitions..."
#first, remove the partition table
sgdisk -Z $drive
#make the partitions
sgdisk -n 1:0:+100M -t 1:ef00 -c 1:"EFI" $drive
sgdisk -n 2:0:+4G -t 2:8200 -c 2:"SWAP" $drive
sgdisk -n 3:0:0 -t 3:8300 -c 3:"ROOT" $drive
echo "Partitions created."
#make the filesystems
echo "Making filesystems..."
mkfs.fat -F32 ${drive}1
mkswap ${drive}2
swapon ${drive}2
mkfs.ext4 ${drive}3
echo "Filesystems made."
#mount the filesystems
echo "Mounting filesystems..."
mkdir /mnt/gentoo
mount ${drive}3 /mnt/gentoo
mkdir -p /mnt/gentoo/boot/efi
mount ${drive}1 /mnt/gentoo/boot/efi
echo "Filesystems mounted."
echo "Downloading stage3..."
#download stage3
STAGE3_URL="https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230108T161708Z/stage3-amd64-openrc-20230108T161708Z.tar.xz"
wget -O /mnt/gentoo/stage3.tar.xz $STAGE3_URL