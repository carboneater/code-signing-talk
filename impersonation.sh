sudo docker run -it --rm -v $(pwd):$(pwd) -w $(pwd) alpine sh

apk add git gpg gpg-agent

### Impersonation
git checkout -b eicar
wget -O eicar.txt https://secure.eicar.org/eicar.com.txt
git add eicar.txt
git commit \
    -c user.email '<email>' \
    -c user.name '<name>' \
    commit \
    -m 'Malicious commit'

### Git-Blame-Someone-Else
