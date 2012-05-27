#!/bin/sh

cake build
mkdir -p wat
cp -r build/* wat/.

git checkout gh-pages
cp -r wat/* .
rm -rf wat

git add *
git commit -am 'auto-deploy'
git push origin gh-pages

git checkout master
