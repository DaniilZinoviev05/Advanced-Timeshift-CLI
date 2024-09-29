#! /bin/bash
CONF="mail.conf"
if [[ -f $CONF ]]; then
	source "$CONF"
	echo "Почта пользователя: $user_email"
fi
current_user=$(whoami)
echo "$current_user ALL=(ALL) NOPASSWD: /usr/bin/timeshift" | sudo EDITOR='tee -a' visudo

libCheckFunc() {
	if ! command -v "$1" &> /dev/null; then
		answer=${answer:-y} 
		if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
			install_library "$1"
		else
			echo "$1 не установлен! Программа может работать некорректно или не работать вовсе!"
		fi
	fi
}

CheckConfMailFunc() {
	EXPECTED_ENTRY='user_email'

	if [[ -s $CONF ]]; then
		echo "Файл $CONF найден."
	  
	if grep -q "$EXPECTED_ENTRY" "$CONF"; then
		echo "Запись $EXPECTED_ENTRY найдена в файле."
		EMAIL=$user_email
	else
		echo "Запись $EXPECTED_ENTRY не найдена в файле."
		read -p "Введите почту: " EMAIL
		echo "user_email=\"$EMAIL\"" > mail.conf
	fi
	else
		echo "Файл $CONF не найден."
	fi	
}

libCheckFunc "timeshift" 

while true; do

	viu  --width 60 -x 15 -y 1  logo.jpg

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

	timeshift --version

	echo -e "\n1 - Создать бэкап" 
	echo -e "2 - Посмотреть бэкапы" 
	echo -e "3 - Восстановить систему" 
	echo -e "4 - Настроить автобэкапы" 
	echo -e "5 - Удалить бэкап"
	echo -e "6 - Привязать почту"
	echo -e "7 - Выход\n"
	read -p "Введите действие: " action
	
	case $action in
		1) 
			clear
			read -p "Введите комментарий для бэкапа: " comment
			sudo timeshift --create --comments $comment
		;;
		
		2) 
			clear
			sudo timeshift --list
		;;
		
		3) 
			clear
			echo -e "\e[32m$(sudo timeshift --list)\e[0m"
			read -p "Введите название бэкапа: " name
			sudo timeshift --restore --snapshot $name
		;;
		
		4) 
			clear
			echo -e "1 - Создать автобэкап" 
			read -p "Введите действие: " action
			case $action in
				1)
					clear
					read -p "Введите комментарий для бэкапа: " comment
					read -p "Введите месяц (число, например, 9 для сентября): " month
					read -p "Введите день недели (0 для воскресенья, 1 для понедельника и т.д.): " day
					read -p "Введите время (например, 12:45): " time

					IFS=':' read -r hour minute <<< "$time"

					if [[ ! $hour =~ ^[0-9]+$ ]] || [[ ! $minute =~ ^[0-9]+$ ]] || [[ "$hour" -lt 0 ]] || [[ "$hour" -gt 23 ]] || [[ "$minute" -lt 0 ]] || [[ "$minute" -gt 59 ]]; then
					    echo "Некорректное время."
					    exit 1
					fi
					
					(crontab -l 2>/dev/null; echo "$minute $hour * $month $day sudo timeshift --create --comments \"$comment\"") | crontab -  
					if [[ -f $CONF ]]; then
						source "$CONF"
						(crontab -l 2>/dev/null; echo "$minute $hour * $month $day echo "Бэкап \"$comment\" успешно создан." | mailx -s "BACKUP-REPORT" "$user_email"") | crontab -  
					fi
				;;
									
				2)
					break
				;;
				
			       *)
			       		echo "Неверный ввод, попробуйте снова."
			       	;;
			esac
		;;
		
		5) 
			clear
			echo -e "\e[32m$(sudo timeshift --list)\e[0m"
			read -p "Введите название бэкапа (из поля name, не комментарий!): " name
			sudo timeshift --delete --snapshot $name
		;;
		
		6) 
			clear
			libCheckFunc "mailutils" 
			libCheckFunc "mailx" 
			CheckConfMailFunc
		;;
		
		7) 
			exit
		;;
	esac
	
done 
