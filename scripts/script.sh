#! /bin/bash

CONF="/home/$(whoami)/Scripts/setgs.conf"
if [[ -f $CONF ]]; then
	source "$CONF"
	echo "User email / Почта пользователя: $user_email"
fi

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
		echo -e "| 1 - Backups / Бэкапы |\n| 2 - Settings / Настройки |\n| 3  - Run / Запустить timeshift |\n| 4 - Exit / Выход |"
	} | toilet -f term -F border --gay
	
	read -p "Enter value / Введите действие: " action
	
	case $action in
		1) 
			clear
			{
				echo -e "| 1 - Create backup / Создать бэкап |\n| 2 - View backups / Посмотреть бэкапы |\n| 3 - Restore system / Восстановить систему |\n| 4 - Set up auto backups / Настроить автобэкапы |\n| 5 - Delete backup / Удалить бэкап |\n| 6 - Back / Назад |"
			} | toilet -f term -F border --gay
			read -p "Enter value / Введите действие: " action
			
			while true; do
				case $action in
				1) 
					clear
					read -p "Enter comment / Введите комментарий для бэкапа: " comment
					sudo timeshift --create --comments $comment
					sudo grub-mkconfig -o /boot/grub/grub.cfg
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
					read -p "Enter backup name / Введите название бэкапа: " name
					sudo timeshift --restore --snapshot $name
					break
				;;
				
				4) 
					clear
					echo -e "1 - Create autobackup / Создать автобэкап" 
					echo -e "2 - Clear autobackups / Очистить бэкапы по расписанию" 
					read -p "Enter value / Введите действие: " action
					case $action in
						1)
							clear
							read -p "Comment / Введите комментарий для бэкапа: " comment
							read -p "Month / Введите месяц (число, например, 9 для сентября): " month
							read -p "Day of the week / Введите день недели (0 для воскресенья, 1 для понедельника и т.д.): " day
							read -p "Enter time / Введите время (например, 12:45): " time

							IFS=':' read -r hour minute <<< "$time"

							if [[ ! $hour =~ ^[0-9]+$ ]] || [[ ! $minute =~ ^[0-9]+$ ]] || [[ "$hour" -lt 0 ]] || [[ "$hour" -gt 23 ]] || [[ "$minute" -lt 0 ]] || [[ "$minute" -gt 59 ]]; then
							    echo "Incorrect time / Некорректное время."
							    exit 1
							fi
							
							(crontab -l 2>/dev/null; echo "$minute $hour * $month $day sudo timeshift --create --comments \"$comment\"") | crontab -  
							(crontab -l 2>/dev/null; echo "$minute $hour * $month $day sudo grub-mkconfig -o /boot/grub/grub.cfg") | sudo crontab -  
							if [[ -f $CONF ]]; then
								source "$CONF"
								(crontab -l 2>/dev/null; echo "$minute $hour * $month $day echo "Backup \"$comment\" created successfully / Бэкап \"$comment\" успешно создан." | mailx -s "BACKUP-REPORT" "$EMAIL"") | crontab -  
							fi
							break
						;;
											
						2)
							crontab -r 
							break
						;;
						
					       *)
					       		echo "Incorrect value / Неверный ввод, попробуйте снова."
					       		break
					       	;;
					esac
				;;
				
				5) 
					clear
					echo -e "\e[32m$(sudo timeshift --list)\e[0m"
					read -p "Enter backup name / Введите название бэкапа (из поля name, не комментарий!): " name
					sudo timeshift --delete --snapshot $name
				;;
				
				6) 
					break
				;;
			esac
		done
		;;
		2)
			echo -e "\n1 - Change email / Изменить почту"
			echo -e "2 - Delete script / Удалить скрипт\n"
			read -p "Введите действие: " action
			case $action in
				1)
					EXPECTED_ENTRY="user_email"

					if [[ -f $CONF ]]; then
						echo "$CONF file found / Файл $CONF найден"

						if grep -q "^$EXPECTED_ENTRY=" "$CONF"; then
							echo "The $EXPECTED_ENTRY entry was found in the file / Запись $EXPECTED_ENTRY найдена в файле"

							read -p "Enter email / Введите email:" EMAIL
							echo "Updating the $EXPECTED_ENTRY entry with the new value / Обновление записи $EXPECTED_ENTRY новым значением"

							sudo sed -i "s/^$EXPECTED_ENTRY=.*/$EXPECTED_ENTRY=\"$EMAIL\"/" "$CONF"

							echo "Entry updated / Запись обновлена"
						else
							echo "Entry $EXPECTED_ENTRY not found in the file / Запись $EXPECTED_ENTRY не найдена в файле"
						fi
					else
						echo "$CONF file not found / Файл $CONF не найден"
					fi
				;;
				2)
					###
				;;
				*)
					echo "Incorrect value / Неверный ввод, попробуйте снова."
					break
				;;
			esac
		;;
		3)
			sudo timeshift-gtk
		;;
		4)
			exit
		::
		esac
	
done 
