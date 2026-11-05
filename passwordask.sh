#! /bin/bash

set -be

if [[ -t 1 ]]; then
    RED=$'\e[31m'; GREEN=$'\e[32m', YELLOW=$'\e[33m', BLUE=$'\e[34m', ENDING=$'\e[0m'
else
    RED=''; GREEN='', YELLOW='', BLUE='', ENDING=''
fi


banner() {
cat << "EOF"
    #######         ##               ##
    #       ##      # #             # #
    #        ##     #  #           #  #
    #         ##    #   #         #   #
    #         ##    #    #       #    #
    #        ##     #     #     #     #
    #       ##      #      #   #      #
    #######         #       ###       #
    #               #                 #
    #               #                 #
    #               #                 #
    #               #                 #
    #               #                 #
    #               #                 #
EOF

}



main() {
    local error
    read -p $'\e[1;37mEnter website: \e[0m\a' WEBSITE
    read -p $'\e[1;37mPlease enter your password to hash: \e[0m\a' PASSWORD

    PASSWORD=$(echo "$PASSWORD" | openssl enc -aes-256-cbc -a -salt -pbkdf2 >&2)

    if [[ $? -eq "0" ]]; then
        echo "$WEBSITE:$PASSWORD" >> password
        echo $'\e[1;32mAdded password succesfully \e[0m\a'
    else
        echo error
    fi

    sleep 5
    return 0
}


retrieve() {
    while IFS= read -r line; do
      echo "$line" | cut -d: -f1
    done < password

    read -p $'\e[1;37mLook for the password in: \e[0m\a' OPTION

    while IFS= read -r line; do
        LOOK=$(echo "$line" | cut -d: -f1)
        PASSWORDTODEHASH=$(echo "$line" | cut -d: -f2)
        if [[ "$OPTION" == "$LOOK" ]]; then
            echo "$PASSWORDTODEHASH" | openssl enc -d -aes-256-cbc -a -pbkdf2 
        fi
    done < password

    sleep 5
    return 0
}

remove_password() {
    read -p $'\e[1;37mWhat password you want to remove (enter website): \e[0m\a' REMOVE


    if cut -d: -f1 password | grep -Fxq "$REMOVE"; then
        awk -F: -v s="$REMOVE" '$1 != s' password > password.tmp && mv password.tmp password
        echo $'\e[1;32mDeleted password succesfully\e[0m\a'
    else
        if [[ -z "$REMOVE" ]]; then
            echo "${RED} Not password found for undefined ${ENDING}"
        else
             echo "${RED} Not password found for ${REMOVE} ${ENDING}"
        fi
    fi

    sleep 5

    return 0
}

edit_password() {
    read -p $'\e[1;37mEnter website: \e[0m\a' WEBSITE
    read -p $'\e[1;37mPlease enter your password to hash: \e[0m\a' PASSWORD

    awk -F: -v s="$WEBSITE" '$1==s{$0=$1":"ENVIRON["PASSWORD"]}1' password > tmp && mv tmp file

    if [[ $? -eq "0" ]]; then
         echo $'\e[1;32mEdited password succesfully\e[0m\a'
    else 
         echo 'Failed with code' $?
    fi
   
    sleep 5
    return 0
}

exit() {
    echo "See you later Alligator"

    sleep 5
    return 1;
}

menu() {
    banner
    while true; do
        clear
        echo $'\e[1;37m1) Add a password \e[0m\t'
        echo $'\e[1;37m2) Retrieve a password \e[0m\t'
        echo $'\e[1;37m3) Remove a password \e[0m\t'
        echo $'\e[1;37m4) Exit \e[0m\t'
        
        read -p $'\e[1;37mPlease enter your option: \e[0m\a' OPTION

        case $OPTION in
            1) main ;;
            2) retrieve ;;
            3) remove_password ;;
            4) exit || return ;;
            *) break ;;
        esac
    done
}



menu