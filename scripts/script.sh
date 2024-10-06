#! /bin/bash

###
echo "---------------------------------------------------------------------------"
echo "Install the required packages / Установим необходимы пакеты..."
source /home/$(whoami)/Scripts/scripts/packages.sh
echo "---------------------------------------------------------------------------"
###
echo "---------------------------------------------------------------------------"
echo "Let's make the settings / Произведем настройку..."
source /home/$(whoami)/Scripts/scripts/settings.sh
echo "---------------------------------------------------------------------------"
###

while true; do

	viu  --width 60 -x 12 -y 1  /home/$(whoami)/Scripts/logo.jpg

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

	(whoami)
	echo -e "$(timeshift --version)\n"
	
	{
		echo -e "| 1 -  Бэкапы | 2 - Настройки | 3  - Запустить timeshift | 4 - Выход |"
	} | toilet -f term -F border --gay

	read -p "Введите действие: " action
	
	case $action in
		1) 
			clear
			
			{
				echo -e "| 1 - Создать бэкап | 2 - Посмотреть бэкапы | 3 - Восстановить систему | 4 - Настроить автобэкапы | 5 - Удалить бэкап | 6 - Назад |"
			} | toilet -f term -F border --gay
			
			read -p "Введите действие: " action
			
			while true; do
				case $action in
				1) 
					clear
					read -p "Введите комментарий для бэкапа: " comment
					sudo timeshift --create --comments $comment
					break
				;;
				
				2) 
					clear
					sudo timeshift --list
					break
				;;
				
				3) 
					clear
					echo -e "\e[32m$(sudo timeshift --list)\e[0m"
					read -p "Введите название бэкапа: " name
					sudo timeshift --restore --snapshot $name
					break
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
								(crontab -l 2>/dev/null; echo "$minute $hour * $month $day echo "Бэкап \"$comment\" успешно создан." | mailx -s "BACKUP-REPORT" "$EMAIL"") | crontab -  
							fi
							break
						;;
											
						2)
							break
						;;
						
					       *)
					       		echo "Неверный ввод, попробуйте снова."
					       		break
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
					break
				;;
			esac
		done
	;;
	2)
		
	;;
	3)
		sudo timeshift-gtk
	;;
	4)
		exit
	::
	esac
	
done 
