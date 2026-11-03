#! /bin/bash

set -be


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

    PASSWORD=$(echo "$PASSWORD" | openssl enc -aes-256-cbc -a -salt -pbkdf2 2>error)

    if [[ $? -eq "0" ]]; then
        echo "$WEBSITE:$PASSWORD" >> password
        echo "Added password succesfully"
    else
        echo error
    fi
    
    exit 0
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
}

remove_password() {
    local error
    read -p $'\e[1;37What password you want to remove (enter website): \e[0m\a' REMOVE

    sed '/$REMOVE/d' password > /dev/null 2>error

    if [[ $? -eq "0" ]]; then
         echo "Deleted password succesfully"
    else 
        echo error
    fi
   
     exit 0
}

edit_password() {
    local error
    read -p $'\e[1;37mEnter website: \e[0m\a' WEBSITE
    read -p $'\e[1;37mPlease enter your password to hash: \e[0m\a' PASSWORD

    awk -F: -v s="$WEBSITE" '$1==s{$0=$1":"ENVIRON["PASSWORD"]}1' password > tmp && mv tmp file

    if [[ $? -eq "0" ]]; then
         echo "Edited password succesfully"
    else 
        echo error
    fi
   
    exit 0
}

menu() {
    banner
    while true; do
        echo $'\e[1;37m1) Add a password \e[0m\t'
        echo $'\e[1;37m2) Retrieve a password \e[0m\t'
        echo $'\e[1;37m3) Remove a password \e[0m\t'
        
        read -p $'\e[1;37mPlease enter your option: \e[0m\a' OPTION

        case $OPTION in
            1) main ;;
            2) retrieve ;;
            3) remove_password ;;
            *) break ;;
        esac
    done
}



menu