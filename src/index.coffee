html ->
  head ->
    meta charset:'utf-8'
    title 'Dual N-Back'
    link rel:'stylesheet', href:'style.css'
    script type:'text/javascript', src:'jquery-1.7.2.min.js'
    script type:'text/javascript', src:'soundmanager2.js'

  body ->
    div id:'results', ->
      div id:'instructions', ->
        text 'How to play Dual 2-Back:'
        ul ->
          li 'Any time a grid square you saw 2 turns ago is highlighted again, press [A]'
          li 'Any time a letter you heard 2 turns ago is spoken again, press [L]'
          li 'It\'s possible for both of these cases to occur on the same turn'
          li 'Don\'t be discouraged! You <strong>will</strong> improve with practice!'
      div id:'percent_wrapper', ->
        table ->
          tbody ->
            tr ->
              td id:'percent', ''
      div id:'start_game_msg', ->
        text 'Press [SPACE] to start another round'
    div id:'game', ->
      table id:'layout', ->
        tr ->
          td id:'a_button', 'POSITION (A)'
          td id:'grid_wrap', ->
            div id:'hud', ->
              div id:'type'
              div id:'remaining'
            table id:'grid', ->
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
          td id:'b_button', 'LETTER (L)'

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
        grid = $('#grid td')
        frand = (min, max) -> min + Math.random()*(max-min)
        rand = (min, max) -> Math.round(frand(min, max))
        choose = (array) -> array[rand(0,array.length-1)]
        window.highlight = (el,klass='highlighted',delay=0,ttl=500) ->
          setTimeout ->
            $(el).addClass klass
            setTimeout ->
              $(el).removeClass klass
            , ttl
          , delay

        window.sounds = []
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

          dual_n_back = (n, count, turn_dur=3000) ->
            started = false
            moves = []
            a_match = b_match = false
            a_pressed = b_pressed = false
            a_correct = b_correct = 0
            a_missed = b_missed = 0
            a_incorrect = b_incorrect = 0
            i = 0
            while i < count
              a = rand(0, grid.length-1)
              b = rand(0, sounds.length-1)
              moves.push {a:a, b:b}

              # Add some more matches:
              if (i >= n) and (Math.random() > 0.15)
                moves[i-n].a = a
              if (i >= n) and (Math.random() > 0.15)
                moves[i-n].b = b
              ++i


            $('#type').html "Dual #{n}-Back"
            start = undefined

            ret = {
              n: n
              count: count
              turn_dur: turn_dur
              a_pressed: ->
                if not a_pressed
                  if a_match
                    highlight $('#a_button'), 'success', 0, 250
                  else
                    highlight $('#a_button'), 'failure', 0, 250
                  a_pressed = true
              b_pressed: ->
                if not b_pressed
                  if b_match
                    highlight $('#b_button'), 'success', 0, 250
                  else
                    highlight $('#b_button'), 'failure', 0, 250
                  b_pressed = true
              start: (done=new Function) ->
                start(done)
              stop: ->
                if intvl
                  clearInterval intvl
            }

            intvl = 0
            start = (done) ->
              started = true
              current = 0
              intvl = setInterval ->
                if a_match
                  if a_pressed
                    ++a_correct
                  else
                    ++a_missed
                else if a_pressed
                  ++a_incorrect
                  console.log 'A'

                if b_match
                  if b_pressed
                    ++b_correct
                  else
                    ++b_missed
                else if b_pressed
                  console.log 'B'
                  ++b_incorrect

                if current >= count
                  clearInterval intvl
                  done {
                    a_correct: a_correct
                    b_correct: b_correct
                    a_incorrect: a_incorrect
                    b_incorrect: b_incorrect
                    a_missed: a_missed
                    b_missed: b_missed
                  }
                  return

                $('#type').html "Dual #{n}-Back"
                $('#remaining').html "#{current+1} of #{count}"
                a_match = b_match = false
                a_pressed = b_pressed = false
                highlight grid[moves[current].a]
                sounds[moves[current].b].play()
                
                if current >= n
                  prev = moves[current-n]
                  a_match = moves[current].a == prev.a
                  b_match = moves[current].b == prev.b
                
                ++current
              , turn_dur

            return ret
          
          $(window).keydown (e) ->

            switch e.which
              when 65 # A
                return true if not window.round
                round.a_pressed()
              when 76 # B
                return true if not window.round
                round.b_pressed()
              when 32 # Spacebar
                if not window.round?
                  window.round = dual_n_back 2, 24, 3000
                  $('#results').hide()
                  round.start (r) ->
                    window.round = undefined
                    console.log r
                    tot = r.a_missed + r.b_missed + r.a_correct + r.b_correct
                    cor = r.a_correct + r.b_correct - r.a_incorrect - r.b_incorrect
                    console.log tot
                    console.log cor
                    percent = Math.round(100 * (cor/tot))
                    if percent <= 50
                      cssclass = 'bad'
                      msg = choose [
                        'don\'t be discouraged!'
                        'room for improvement; try again!'
                      ]
                    else if percent <= 80
                      cssclass = 'better'
                      msg = choose [
                        'not bad at all.'
                        'you\'re getting there!'
                        'keep it up!'
                      ]
                    else
                      cssclass = 'excellent'
                      msg = choose [
                        'excellent!'
                        'now you\'ve got it!'
                        'bravo!'
                        '*high fives*'
                        'is this too easy for you?'
                      ]

                    $('#percent').html "#{percent}% correct"
                    $('#percent').removeClass 'bad'
                    $('#percent').removeClass 'better'
                    $('#percent').removeClass 'excellent'
                    $('#percent').addClass cssclass
                    $('#results').show()

          $(window).on 'click', '#a_button', ->
            return true if not window.round
            round.a_pressed()
          $(window).on 'click', '#b_button', ->
            return true if not window.round
            round.b_pressed()
