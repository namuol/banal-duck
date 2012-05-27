#!/bin/sh

cake build

cp -r build/* .
git checkout gh-pages

git add *
git commit -am 'auto-deploy'
git push origin gh-pages

git checkout master
