html ->
  head ->
    meta charset:'utf-8'
    title 'Dual N-Back'
    link rel:'stylesheet', href:'style.css'
    script type:'text/javascript', src:'jquery-1.7.2.min.js'
    script type:'text/javascript', src:'soundmanager2.js'

  body ->
    div id:'grid', ->
      table ->
        tr ->
          td ''
          td ''
          td ''
        tr ->
          td ''
          td ''
          td ''
        tr ->
          td ''
          td ''
          td ''

    coffeescript ->
      ###           ###
      #               #
      #  ,d88b.d88b,  #
      #  888hello888  #
      #  `Y8888888Y'  #
      #    `Y888Y'    #
      #      `Y'      #
      #               #
      ###           ###
      $ ->
        frand = (min, max) -> min + Math.random()*(max-min)
        rand = (min, max) -> Math.round(frand(min, max))
        choose = (array) -> array[rand(0,array.length-1)]

        sounds = []
        soundManager.url = 'swf'
        soundManager.flashVersion = 9
        soundManager.useHighPerformance = true
        soundManager.useFastPolling = true
        soundManager.useHTML5Audio = true
        #soundManager.preferFlash = true
        soundManager.onready ->
          soundManager.defaultOptions.autoLoad = true
          soundManager.defaultOptions.onload = ->
            console.log 'sound loaded!'

          sounds_to_load = [
              id: 'c'
              url: 'c.wav'
              volume: 50
            ,
              id: 'h'
              url: 'h.wav'
              volume: 50
            ,
              id: 'k'
              url: 'k.wav'
              volume: 50
            ,
              id: 'l'
              url: 'l.wav'
              volume: 50
            ,
              id: 'q'
              url: 'q.wav'
              volume: 50
            ,
              id: 'r'
              url: 'r.wav'
              volume: 50
            ,
              id: 's'
              url: 's.wav'
              volume: 50
            ,
              id: 't'
              url: 't.wav'
              volume: 50
          ]
          for sound in sounds_to_load
            sounds.push soundManager.createSound sound

          setInterval ->
            choose(sounds).play()
          , 3000
