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
# git show 8e607c98660bb3b8ae2462b3d7b37a8cd11730aa
# git-blame-someone-else "Name <Email>" 8e607c98660bb3b8ae2462b3d7b37a8cd11730aa
# git show 8e607c98660bb3b8ae2462b3d7b37a8cd11730aa