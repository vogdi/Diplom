#! /bin/bash
Date="$(date +%Y-%m-)"
mountPath="/mnt/usb"
mountPathMO="$mountPath/MO"
testPath1="*"
logDate="$(date +%Y_%m_%d)"
num='^[0-9]+$'
function checkData {
    while ! [[ $dayData =~ $num ]]
    do
    echo "Введите правильную дату: "
    read -r -p "Введите дату(день например 05 или 15): " dayData
    done

    while [[ $dayData -gt 31 ]]
    do
    echo "Введите правильную дату: "
    read -r -p "Введите дату(день например 05 или 15): " dayData
    done
}
function checkHoreStart {
    while ! [[ $dayHoreStart =~ $num ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите стартовое время часы (В формате 24 например 9 или 15)  :" dayHoreStart
    done

    while [[ $dayHoreStart -gt 23 ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите стартовое время часы (В формате 24 например 9 или 15)  :" dayHoreStart
    done
}
function checkMinutStart {
    while ! [[ $dayMinutStart =~ $num ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите стартовое время минуты (В формате 24 например 9 или 15)  :" dayMinutStart
    done

    while [[ $dayMinutStart -gt 60 ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите стартовое время минуты (В формате 24 например 9 или 15)  :" dayMinutStart
    done
}
function checkHoreStop {
        while ! [[ $dayHoreStart =~ $num ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите конечное время часы (В формате 24 например 9 или 15)  :" dayHoreStop
    done    
while [[ $dayHoreStop -gt 23 ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите конечное время часы (В формате 24 например 9 или 15)  :" dayHoreStop
    done
while [[ $dayHoreStart -gt $dayHoreStop ]]
do
        echo "Введите правильное время, стартовое время не может быть больше конечного"
        read -r -p "Введите стартовое время часы (В формате 24 например 9 или 15)  :" dayHoreStart
done
}
function checkMinutStop {
        while ! [[ $dayMinutStop =~ $num ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите конечное время минуты (В формате 24 например 9 или 15)  :" dayMinutStop
    done    
while [[ $dayMinutStop -gt 60 ]]
    do
        echo "Введите правильное время: "
        read -r -p "Введите конечное время минуты (В формате 24 например 9 или 15)  :" dayMinutStop
    done
}
function copyVideo {
    testPath="/var/lib/obj_control/"
    testPath2="*_mo-arm*.avi"
    dayMinutStartC=$dayMinutStart
    timeStatusStart=$((dayHoreStart * 60 + dayMinutStart))
    timeStatusStop=$((dayHoreStop * 60 + dayMinutStop))
while [[ $dayHoreStart -le $dayHoreStop ]]
do
     while [[ $dayMinutStartC -le 59 ]]
     do
        if [ $timeStatusStart -le $timeStatusStop ]
        then
        echo "$testPath""$Date""$dayData""$testPath1""$dayHoreStart""$testPath1""$dayMinutStartC""$testPath2"
        sshpass -p 'transas' scp -r -c -v -o StrictHostKeyChecking=no root@mo-capture:"$testPath""$Date""$dayData""$testPath1""$dayHoreStart""$testPath1""$dayMinutStartC""$testPath2" "$localPath" #2>/dev/null
        else
        break
        fi
        dayMinutStartC=$(( dayMinutStartC+1 ))
        timeStatusStart=$((timeStatusStart+1))
     done
dayHoreStart=$((dayHoreStart+1))
dayMinutStartC=0
done
}
function checkFolder {
    read -r -p "Введите дату(день например 05 или 15): " dayData
    checkData
    localPath="$mountPath/MO/$Date$dayData"
    logPath="$localPath/log"
    massPath=( "$mountPath" "$mountPathMO" "$localPath" "$logPath" )

for t in ${massPath[*]}; 
do
if [ -d "$t" ]; then
    echo directory exists
else
mkdir "$t"
echo create directory
fi
echo $t
done
}
function mountDevice {
if mountpoint -q $mountPath
 then
    umount $mountPath
fi
lsblk_init(){
dev=( $(ls /dev/sd* -1 | cut -c6-) )
device=$((${#dev[@]}-1))
}; lsblk_init
echo ${dev[$device]}
echo $device
if (( "$device" > 3 ))
then
mount /dev/${dev[$device]} $mountPath
echo "Накопитель смонтирован успешно"
else
echo "USB накопитель не обнаружен"
fi
}
checkFolder
read -r -p "Введите стартовое время часы (В формате 24 например 9 или 15)  :" dayHoreStart
checkHoreStart
read -r -p "Введите стартовое время минуты (В формате 24 например 9 или 15)" dayMinutStart
checkMinutStart
read -r -p "Введите конечное время часы (В формате 24 например 9 или 15)  :" dayHoreStop
checkHoreStop
read -r -p "Введите конечное время минуты (В формате 24 например 9 или 15)  :" dayMinutStop
checkMinutStop
mountDevice
copyVideo
# sshpass -p 'transas' scp -r -v -o StrictHostKeyChecking=no root@mo-capture:/var/lib/obj_control/$Date$dayData*$dayHoreStart*_mo-arm*.avi $localPath
sshpass -p 'transas' scp -r -c -v -o StrictHostKeyChecking=no root@mo-node02:/var/lib/deployment/orion/icd_logs/RecorderIcd_*__$logDate* $logPath
umount $mountPath
echo "Все готово, можно изъять USB устройство"