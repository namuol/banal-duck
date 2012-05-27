#!/bin/sh

cake build

git checkout gh-pages

cp -r build/* .
git add *
git commit -am 'auto-deploy'
git push origin gh-pages

git checkout master
