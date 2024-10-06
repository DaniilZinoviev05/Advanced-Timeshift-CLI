#! /bin/bash

CONF="setgs.conf"
if [[ -f $CONF ]]; then
	source "$CONF"
	echo "Почта пользователя: $user_email"
fi

CheckConfMailFunc() {
	EXPECTED_ENTRY="user_email"

	if [[ -f $CONF ]]; then
		echo "Файл $CONF найден."
	  
		if grep -q "$EXPECTED_ENTRY" "$CONF"; then
			echo "Запись $EXPECTED_ENTRY найдена в файле."
			EMAIL=$user_email
		else
			echo "Запись $EXPECTED_ENTRY не найдена в файле."
			read -p "Введите почту: " EMAIL
			echo "user_email=\"$EMAIL\"" >  $CONF 
		fi
	else
		echo "Файл $CONF не найден."
	fi	
}

CheckConfDistroFunc() {
	EXPECTED_ENTRY="user_distro"

	if [[ -f  $CONF ]]; then
		echo "Файл $CONF найден."
	  
		if grep -q "$EXPECTED_ENTRY" "$CONF"; then
			echo "Запись $EXPECTED_ENTRY найдена в файле."
			DISTRO=$user_distro
		else
			echo "Запись $EXPECTED_ENTRY не найдена в файле."
			DISTRO=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"' | sed 's/ Linux//')
			echo "user_distro=\"$DISTRO\"" >> $CONF 
			echo "$EXPECTED_ENTRY теперь определен."
		fi
	else
		echo "Файл $CONF не найден."
	fi	
}

CheckConfMailFunc
CheckConfDistroFunc
