#!/bin/bash

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

FILE=TaskForce-UIKit/Resources/Credentials.plist

create_credentials_plist() {
    if [ ! -f "$FILE" ]; then
        read -p "Enter you MARVEL API private key:" private_key
        read -p "Enter you MARVEL API public key:" public_key
        /usr/libexec/PlistBuddy -c "Add :privateKey string $private_key" $FILE
        /usr/libexec/PlistBuddy -c "Add :publicKey string $public_key" $FILE
    fi
}

install_tools() {
    brew update
    brew install swiftgen
    brew install swiftlint
}

echo "–––– Installing tools ––––"
install_tools
echo "–––– Creating Credentials Plist ––––"
create_credentials_plist
echo "–––– Installation finished ––––"