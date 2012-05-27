html ->
  head ->
    meta charset:'utf-8'
    title 'Dual N-Back'
    link rel:'stylesheet', href:'style.css'
    script type:'text/javascript', src:'json2.min.js'
    script type:'text/javascript', src:'storage.min.js'
    script type:'text/javascript', src:'jquery-1.7.2.min.js'
    script type:'text/javascript', src:'soundmanager2.js'

  body ->
    div id:'loading_wrapper', ->
      table ->
        tbody ->
          tr ->
            td id:'loading', 'Please Wait...'
    div id:'results', style:'display:none', ->
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
    div id:'game', style:'display:none', ->
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
        all_loaded = undefined
        sounds_loaded = 0
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
        soundManager.url = 'swf'
        soundManager.flashVersion = 9
        soundManager.useHighPerformance = false
        soundManager.useFastPolling = true
        soundManager.useHTML5Audio = true
        soundManager.preferFlash = false

        soundManager.defaultOptions.onload = ->
          if ++sounds_loaded == sounds_to_load.length
            all_loaded()


        soundManager.onready ->
          soundManager.defaultOptions.autoLoad = true


          for sound in sounds_to_load
            sounds.push soundManager.createSound sound

          dual_n_back = (n, count, turn_dur=3000) ->
            started = false
            turns = []
            a_match = b_match = false
            current = 0
            i = 0
            while i < count
              a = rand(0, grid.length-1)
              b = rand(0, sounds.length-1)
              turns.push
                a:a
                b:b
                a_pressed:false
                b_pressed:false

              # Add some more matches:
              if (i >= n) and (Math.random() > 0.15)
                turns[i-n].a = a
              if (i >= n) and (Math.random() > 0.15)
                turns[i-n].b = b
              ++i


            $('#type').html "Dual #{n}-Back"
            start = undefined

            a_matches = (num) ->
              return false if num < n
              return turns[num].a == turns[num-n].a
            b_matches = (num) ->
              return false if num < n
              return turns[num].b == turns[num-n].b


            generate_results = ->
              a_correct = b_correct = 0
              a_incorrect = b_incorrect = 0
              a_missed = b_missed = 0
              a_match = b_match = false

              i = 0
              while i < turns.length
                a_match = b_match = false
                curr = turns[i]
                a_match = a_matches(i)
                b_match = b_matches(i)

                if a_match
                  if curr.a_pressed
                    ++a_correct
                  else
                    ++a_missed
                else if curr.a_pressed
                  ++a_incorrect

                if b_match
                  if curr.b_pressed
                    ++b_correct
                  else
                    ++b_missed
                else if curr.b_pressed
                  ++b_incorrect

                ++i

              return {
                a_correct: a_correct
                b_correct: b_correct
                a_incorrect: a_incorrect
                b_incorrect: b_incorrect
                a_missed: a_missed
                b_missed: b_missed
              }

            intvl = 0

            start = (done) ->
              started = true
              current = 0
              intvl = setInterval ->
                if current >= count
                  clearInterval intvl
                  done generate_results()
                  return

                $('#type').html "Dual #{n}-Back"
                $('#remaining').html "#{current+1} of #{count}"
                highlight grid[turns[current].a]
                sounds[turns[current].b].play()
                
                ++current
              , turn_dur

            return {
              n: n
              count: count
              turns: turns
              turn_dur: turn_dur
              a_pressed: ->
                if not turns[current-1].a_pressed
                  if a_matches(current-1)
                    highlight $('#a_button'), 'success', 0, 250
                  else
                    highlight $('#a_button'), 'failure', 0, 250
                  turns[current-1].a_pressed = true
              b_pressed: ->
                if not turns[current-1].b_pressed
                  if b_matches(current-1)
                    highlight $('#b_button'), 'success', 0, 250
                  else
                    highlight $('#b_button'), 'failure', 0, 250
                  turns[current-1].b_pressed = true
              start: (done=new Function) ->
                start(done)
              stop: ->
                if intvl
                  clearInterval intvl
            }

          new_round = ->
            if not window.round?
              window.round = dual_n_back 2, 24, 3000
              $('#results').hide()
              round.start (r) ->
                h = JSON.parse localStorage.getItem 'history'
                if not h?
                  h = []
                h.push round
                localStorage.setItem 'history', JSON.stringify h

                window.round = undefined
                tot = r.a_missed + r.b_missed + r.a_correct + r.b_correct
                cor = r.a_correct + r.b_correct - r.a_incorrect - r.b_incorrect
                percent = Math.round(100 * (cor/tot))
                if percent <= 50
                  cssclass = 'bad'
                  msg = choose [
                    'don\'t be discouraged!'
                    'give it another try!'
                  ]
                else if percent <= 80
                  cssclass = 'better'
                  msg = choose [
                    'not bad.'
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

                $('#percent').html "#{percent}% correct<br>#{msg}"
                $('#percent').removeClass 'bad'
                $('#percent').removeClass 'better'
                $('#percent').removeClass 'excellent'
                $('#percent').addClass cssclass
                $('#results').show()

          all_loaded = ->
            $('#loading_wrapper').hide()
            $('#results').show()
            $('#game').show()
            $(window).keydown (e) ->
              switch e.which
                when 65 # A
                  return true if not window.round
                  round.a_pressed()
                when 76 # B
                  return true if not window.round
                  round.b_pressed()
                when 32 # Spacebar
                  new_round()
            $(window).on 'click', '#percent_wrapper', ->
              new_round()
            $(window).on 'click', '#a_button', ->
              return true if not window.round
              round.a_pressed()
            $(window).on 'click', '#b_button', ->
              return true if not window.round
              round.b_pressed()
