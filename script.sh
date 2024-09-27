#!/bin/bash

libCheckFunc() {
	if ! command -v "$1" &> /dev/null; then
		answer=${answer:-y} 
		if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
			install_library "$1"
		else
			echo "Программа может работать некорректно или не работать вовсе!"
		fi
	else
		echo "$1 установлен."
	fi
}

while true; do

cat << "EOF"
  _      _                                _        _                _                
 | |    (_)                              | |      | |              | |               
 | |     _ _ __  _   ___  __   __ _ _   _| |_ ___ | |__   __ _  ___| | ___   _ _ __  
 | |    | | '_ \| | | \ \/ /  / _` | | | | __/ _ \| '_ \ / _` |/ __| |/ / | | | '_ \ 
 | |____| | | | | |_| |>  <  | (_| | |_| | || (_) | |_) | (_| | (__|   <| |_| | |_) |
 |______|_|_| |_|\__,_/_/\_\  \__,_|\__,_|\__\___/|_.__/ \__,_|\___|_|\_\\__,_| .__/ 
                                                                              | |    
                                                                              |_|   
EOF

	echo "1 - Создать бэкап" 
	echo "2 - Посмотреть бэкапы" 
	echo "3 - Привязать почту"
	echo "4 - Выход"
	read -p "Введите действие: " action
	
	case $action in
		1) 
			clear
			libCheckFunc "timeshift" 
			read -p "Введите название бэкапа: " comment
			sudo timeshift --create --comments $comment
		;;
		
		2) 
			clear
			sudo timeshift --list
		;;
		
		3) 
			clear
			libCheckFunc "mailx" 
			read -p "Введите почту: " EMAIL
			echo "Test message" | mailx -s "Test message" $EMAIL
		;;
		
		4) exit;;
	esac
	
done 
