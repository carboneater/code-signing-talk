#! /bin/sh
#sudo docker run --entrypoint $(pwd)/blame.sh -it --rm -v $(pwd):$(pwd) -w $(pwd) alpine

apk add bash git make

CWD=$(pwd)

cd ~
git clone https://github.com/jayphelps/git-blame-someone-else.git
cd git-blame-someone-else
make install
cd $CWD

git config --global --add safe.directory $CWD

bash