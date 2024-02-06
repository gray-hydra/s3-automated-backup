#!/bin/bash
# copy all files to encrypt directory
cp -r /home/{user}/Documents /home/{user}/encrypt-stage

# create empty veracrypt volume. first we get the size of the encrypt directory, and assign that to x. we use x as the size of the veracrypt volume, plus 1 GB. This will give it enough room for all the files, with a little headroom. the volume is given a timestamp of the current date
x=$(du -sh /home/{user}/encrypt-stage | cut -f -1) && x=${x::-1} && let "x=x+1" && x="${x}G" && y=$(date +%s) && sudo veracrypt --text --create /home/{user}/encrypt/$y-encrypt.vc --size $x --password {veracrypt password} --volume-type normal --encryption AES --hash sha-512 --filesystem ext4 --pim 0 --keyfiles "" --random-source /home/{user}/randomdata.txt

# mount the veracrypt drive
x=$(ls /home/{user}/encrypt) && sudo veracrypt --text --mount /home/{user}/encrypt/$x /home/{user}/mnt --password {veracrypt password} --pim 0 --keyfiles "" --protect-hidden no --slot 1 --verbose

# copy all files to the mounted veracrypt drive
sudo cp -r /home/{user}/encrypt-stage/* /home/{user}/mnt

# dismount the veracrypt drive
sudo veracrypt --text --dismount --slot 1

# copy drive to upload directory
sudo cp -r /home/{user}/encrypt/* /home/{user}/Sync

# create a copy of the volume in the backups directory
sudo cp /home/{user}/encrypt/* /home/{user}/encrypt-backups

# remove the oldest backup volume
sudo rm /home/{user}/encrypt-backups/"$(ls -rt /home/{user}/encrypt-backups | head -n 1)"

# remove the new volume. we've uploaded it to s3 and created a backup of it, so we no longer need the original. 
sudo rm /home/{user}/encrypt/*

# remove the upload volume
sudo rm /home/{user}/upload/*