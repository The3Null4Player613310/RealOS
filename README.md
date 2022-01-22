# RealOS
  A 16 bit realmode operating system.
  
# Installation
  1. Compile with `sudo make build` to get disk.iso.
  2. Run `sudo fdisk -l` to find device name of removable media.
  3. Finaly run `dd if=./disk.iso of=/dev/sdX` where sdX is the drive you want to format.
  4. Run on any mbr compatible x86 computer.
