#!/bin/bash

# Requesting the hdd and mem files to parse
function getmemhdd() {
read -p "Type your memory file's name>"  memname
echo "                                "
locate $memname
echo "                                "
read -p "Enter your memory file's path>" memfile
echo "                                "
read -p "Type your HDD file's name>" hddname
echo "                                "
locate $hddname
echo "                              "
read -p "Enter your hdd file's path>" hddfile
echo "                               "
echo "                               "
}
 

#Brute Force of mem file
function memhdd() {

sudo updatedb
me=$(whoami)
sudo rm -f /home/$me/.john/john.log
path=$(locate /volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone)
sudo $path -f $memfile imageinfo 
echo "Choose a profile [Enter]"
read profile
sudo $path -f $memfile --profile=$profile hivelist > hives.txt
sam=$(cat hives.txt| grep -i sam | awk '{ print $1 }') 
system=$(cat hives.txt| grep -i system | awk '{ print $1 }')  
sudo $path -f $memfile --profile=$profile hashdump -y $system  -s $sam > hashes.txt
echo "Do you have a password file you would like to use for cracking y(Yes) / n(NO)"
read answer
if [ $answer == y ]
then
	echo "please enter a full path of the password file"
	read password
	john --format=NT hashes.txt --wordlist=$password
    
else
        	
	john --format=NT hashes.txt    
fi
}

# exection of Binwalk over mem and hdd files
function bin() {
echo "Would you like to use binwalk for [1] memory [2] HDD"
read -p " Please type the number of choice" bnw

if [ $bnw == 1 ]
then
	binwalk $memfile

else
	binwalk $hddfile
fi

}


# Exection of foremost over mem and hdd files

function fore() {
echo "Would you like to use foremost for [1] memory [2] HDD [3] both"
read -p " Please type the number of choice" frmst

if [ $frmst == 1 ]
then
	foremost -t all $memfile -o foremost_memfile
	echo "Files are ready"
elif [ $frmst == 2 ]
then
	foremost -t all $hddfile -o foremost_hdd
	echo "Files are ready"
elif [ $frmst == 3 ]
then
	foremost -t all $memfile -o foremost_memfile
	foremost -t all $hddfile -o foremost_hdd
	echo "Files are ready"
fi

} 

# executes bulk_extractor  over mem and hdd files

function blkextr() {

echo "Would you like to use Bulk_Extractor for [1] Memory [2] HDD [3] Both"
read -p " Please type the number of choice" blk

if [ $blk == 1 ]
then
	bulk_extractor $memfile -o bulk_memfile
	echo "Files are ready"

elif [ $blk == 2 ]
then
	bulk_extractor $hddfile -o bulk_hdd
	echo "Files are ready"

elif [ $blk == 3 ]
then
        bulk_extractor $memfile -o bulk_memfile
        bulk_extractor $hddfile -o bulk_hdd
	echo "Files are ready"
fi
}

# function that run strings tool  on mem  file

function strgs() {

strings $memfile

}

# function that executes volatiliti program over mem  file with a looping menu

function vola() {


path=$(locate /volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone)
	sudo $path -f $memfile imageinfo 
	echo " Enter the profile you would like to set>"
	read profile
while true
do
echo "                                   "
echo "                                   "
echo "- - - - - - - - - - - - - - - - - -"
echo "What option you would like to run?"
echo "- - - - - - - - - - - - - - - - - -"

echo "[1] Imageinfo"
echo "[2] Pslist"
echo "[3] Connections"
echo "[4] Parser MFT for specific EXE file"
echo "[5] Hashdump"
echo "[6] Extract commands from cmd"
echo "[7] The PPID of specified PID"
echo "[8] Back to main menu"

read command
if [ $command == 1 ]
then
	
	sudo $path -f $memfile imageinfo 

elif [ $command == 2 ]
then
	
	sudo $path -f $memfile --profile=$profile pslist

elif [ $command == 3 ]
then
	 
	sudo $path -f $memfile --profile=$profile connections

elif [ $command == 4 ]
then
       
	echo "What is the name of the executable file you would like to parser?"
	read exename
	echo " Please wait a moment"
	sleep 2 
    sudo $path -f $memfile --profile=$profile mftparser > exe.txt
	cat exe.txt | grep -i $exename 

elif [ $command == 5 ]
then
	
        
        sudo $path -f $memfile --profile=$profile hivelist > hives.txt
        sam=$(cat hives.txt| grep -i sam | awk '{ print $1 }') 
        system=$(cat hives.txt| grep -i system | awk '{ print $1 }')  
        sudo $path -f $memfile --profile=$profile hashdump -y $system  -s $sam > hashes.txt
		cat hashes.txt

elif [ $command == 6 ]
then

        sudo $path -f $memfile --profile=$profile cmdscan

elif [ $command == 7 ]
then
	 
        
    sudo $path -f $memfile --profile=$profile pslist > pidlist.txt 
	sudo $path -f $memfile --profile=$profile pslist | awk '{print $2,$3}'
 	read -p "Choose a PID  number to display its PPID>" pid
	echo "Your PPID number is:"
	cat pidlist.txt | grep $pid | awk '{print $4}'
	 
elif [ $command == 8 ]
then		
	menu
fi	
done
}



# main menu for forensical options  

function menu() {

while true
do
echo "- - - - - - - - - - -" 
echo "        MENU         "
echo "- - - - - - - - - - -"


echo "[1] Binwalk"
echo "[2] Foremost"
echo "[3] Bulk_Extractor"
echo "[4] Volatility"
echo "[5] Strings ( on memory file only)"
echo "[6] Memory Hashdump and brute force"

read -p "Please select a number:"  options
if [ $options == 1 ]
then 
	bin
	
elif [ $options == 2 ] 
then
	fore
 
elif [ $options == 3 ] 
then	
	blkextr

elif [ $options == 4 ]
then  
	vola

elif [ $options == 5 ]
then
	strgs  

elif [ $options == 6 ] 
then
	memhdd 
fi
done
}

# A command that run the process of identification and insertion of mem and hdd files

getmemhdd

# Running of the main menu to start the forensics

menu
