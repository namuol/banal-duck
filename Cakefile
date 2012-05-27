fs = require 'fs'
ck = require 'coffeecup'
stylus = require 'stylus'
BUILD_DIR = 'build'
handle_errors = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr

task 'build', 'Create compiled HTML/CSS output', ->
  console.log 'build her a cake or something...'

  console.log 'building main file'

  result = ck.render fs.readFileSync('src/index.coffee', 'utf-8')
  fs.writeFileSync BUILD_DIR + '/index.html', result

  console.log 'building css'
  css_fn = BUILD_DIR+'/style.css'
  stylus.render fs.readFileSync('src/style.styl','utf-8'), {filename: css_fn}, (err, css) ->
    throw err if err
    fs.writeFileSync css_fn, css

task 'deploy', 'Deploy the project', ->
  console.log 'TODO'
