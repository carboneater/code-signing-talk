#! /bin/sh
#sudo docker run -e EMAIL="<Email>" -e NAME="<Name>" --entrypoint $(pwd)/genkey.sh -it --rm -v $(pwd):$(pwd) -w $(pwd) alpine

apk add gpg gpg-agent

gpg --full-generate-key
gpg --list-keys --keyid-format=LONG
sh