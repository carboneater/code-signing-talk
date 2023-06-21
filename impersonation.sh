#! /bin/sh
#sudo docker run -e EMAIL="<Email>" -e NAME="<Name>" --entrypoint $(pwd)/impersonation.sh -it --rm -v $(pwd):$(pwd) -w $(pwd) alpine

apk add git

git config --global user.name $NAME
git config --global user.email $EMAIL
git config --global --add safe.directory $(pwd)
git checkout -b eicar
wget -O eicar.txt https://secure.eicar.org/eicar.com.txt
git add eicar.txt
git commit -m 'Malicious commit'
git log