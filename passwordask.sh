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
    local PASSWORD
    local WEBSITE 
    read -p $'\e[1;37mEnter website: \e[0m\a' WEBSITE
    read -ps $'\e[1;37mPlease enter your password to hash: \e[0m\a' PASSWORD

    PASSWORD=$(echo "$PASSWORD" | openssl enc -aes-256-cbc -a -salt -pbkdf2)

    echo "$WEBSITE:$PASSWORD" >> password
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

menu() {
    banner
    while true; do
        echo $'\e[1;37m1) Add a password \e[0m\t'
        echo $'\e[1;37m2) Retrieve a password \e[0m\t'
        
        read -p $'\e[1;37mPlease enter your option: \e[0m\a' OPTION

        case $OPTION in
            1) main ;;
            2) retrieve ;;
            *) break ;;
        esac
    done
}



menu