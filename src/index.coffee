html ->
  head ->
    meta charset:'utf-8'
    title 'Dual N-Back'
    link rel:'stylesheet', href:'flotr2-examples.css'
    link href:'http://fonts.googleapis.com/css?family=Carme', rel:'stylesheet', type:'text/css'
    link rel:'stylesheet', href:'style.css'
    script type:'text/javascript', src:'json2.min.js'
    script type:'text/javascript', src:'storage.min.js'
    script type:'text/javascript', src:'jquery-1.7.2.min.js'
    script type:'text/javascript', src:'soundmanager2.js'
    script type:'text/javascript', src:'flotr2.min.js'

  body class:'loading', ->
    div id:'vignette', ''
    div id:'loading_wrapper', ->
      table ->
        tbody ->
          tr ->
            td id:'loading', 'Please Wait...'

    div id:'nav', ->
      ul ->
        li class:'first', ->
          a href:'#game', 'Game'
        li ->
          a href:'#stats', 'Stats'
        li ->
          a href:'#help', 'Help'

    div id:'content', ->
      div id:'help', ->
        fieldset id:'instructions', class:'outer', ->
          fieldset ->
            legend 'How to Play Dual <i>N</i>-Back'
            section ->
              ul ->
                li 'Any time a grid square you saw <i>N</i> turns ago is highlighted again, press [A]'
                li 'Any time a letter you heard <i>N</i> turns ago is spoken again, press [L]'
                li 'It\'s possible for both of these cases to occur on the same turn'
                li 'Don\'t be discouraged! You <strong>will</strong> improve with practice!'
                li '<b>Training mode</b> (recommended) auto-adjusts the <i>N</i> value as you improve.'

      div id:'stats', ->
        fieldset id:'graph-panel', class:'outer', ->
          fieldset ->
            legend 'Your Progress'
            div id:'graph'
          br ''
          button id:'clear-history', 'Clear My Progress'


      div id:'game', ->
        fieldset class:'outer', ->
          fieldset id:'game-mode', ->
            legend 'Progress Mode'

            input id:'mode_training', type:'radio', name:'mode', value:'training'
            label for:'mode_training', 'Training'
            input id:'mode_manual', type:'radio', name:'mode', value:'manual'
            label for:'mode_manual', 'Manual'
            
            div id:'n-wrap', ->
              text 'Dual '
              input id:'n', name:'n', type:'number'
              text '-Back'

          fieldset id:'settings', ->
            legend 'Settings'
            text 'Number of Turns: '
            input id:'count', name:'count', type:'number'
            text ' + '
            span id:'extra_count'
            br ''
            text 'Turn Duration: '
            input id:'turndur', name:'turndur', type:'number'
            text 'ms'
            br ''
            text 'Increase <i>N</i> Threshold: '
            input id:'advance_threshold', name:'advance_threshold', type:'number'
            text '%'
            br ''
            text 'Decrease <i>N</i> Threshold: '
            input id:'retreat_threshold', name:'retreat_threshold', type:'number'
            text '%'

            button id:'new-game', 'NEW ROUND!'
          br ''
          button id:'reset-settings', 'Reset All Settings'

    div id:'flash_bg'
    table id:'flash_wrapper', ->
      tbody ->
        tr ->
          td ->
            div id:'flash', '100% Correct.<br>Dayum.'
            button id:'continue', 'Continue'

    div id:'main', ->
      table id:'focus_wrap', ->
        tbody ->
          tr ->
            td id:'focus', 'focus.'
      button id:'cancel', 'Cancel'
      table id:'layout', ->
        tbody ->
          tr ->
            td id:'a_button', 'POSITION (A)'
            td id:'grid_wrap', ->

              fieldset class:'outer', ->
                fieldset ->
                  div id:'hud', ->
                    legend id:'type'
                    legend id:'remaining'
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

    div id:'logo', 'banalduck'

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
        _defaultSettings =
          mode: 'training'
          n: 2
          count: 20
          turndur: 3000
          retreat_threshold: 50
          advance_threshold: 80
        
        update_settings_display = ->
          settings = JSON.parse localStorage.getItem 'settings'
          $("#game input[name='mode']").attr 'checked', false
          $("#game input[name='mode'][value='#{settings.mode}']").attr 'checked', 'checked'
          for own name,val of settings
            continue if name is 'mode'
            $("#game input[name='#{name}']'").val val

          if settings.mode == 'manual'
            $('#n').attr 'disabled', false
            $('#retreat_threshold').attr 'disabled', 'disabled'
            $('#advance_threshold').attr 'disabled', 'disabled'
          else
            $('#n').attr 'disabled', 'disabled'
            $('#retreat_threshold').attr 'disabled', false
            $('#advance_threshold').attr 'disabled', false

          $('#extra_count').html settings.n*settings.n


        reset_settings = ->
          localStorage.setItem 'settings', JSON.stringify _defaultSettings

        clear_history = ->
          localStorage.setItem 'history', JSON.stringify []

        $('#nav').on 'click', 'li', ->
          $('.selected').removeClass 'selected'
          $('#content > div').hide()
          $(@).addClass 'selected'
          href = $(@).children('a').attr('href')
          $(href).show()
          return false
        $('#nav').on 'click', 'a', ->
          $(@).parent().click()
          return false

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

        window.flash = (text, cssClass, buttonText='Continue', cb=undefined) ->
          $('#flash').html text
          $('#flash').removeClass 'bad'
          $('#flash').removeClass 'better'
          $('#flash').removeClass 'excellent'
          $('#flash').addClass cssClass
          $('body').addClass 'flash'

          flash.continue = ->
            if cb?
              cb()
            $('body').removeClass 'flash'

         
          $('#continue').click ->
            flash.continue()


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

          a_matches = (turns, n, num) ->
            return false if num < n
            return turns[num].a == turns[num-n].a
          b_matches = (turns, n, num) ->
            return false if num < n
            return turns[num].b == turns[num-n].b

          generate_results = (turns, n) ->
            a_correct = b_correct = 0
            a_incorrect = b_incorrect = 0
            a_missed = b_missed = 0
            a_match = b_match = false

            i = 0
            while i < turns.length
              a_match = b_match = false
              curr = turns[i]
              a_match = a_matches(turns, n, i)
              b_match = b_matches(turns, n, i)

              if a_match
                if curr.ap
                  ++a_correct
                else
                  ++a_missed
              else if curr.ap
                ++a_incorrect

              if b_match
                if curr.bp
                  ++b_correct
                else
                  ++b_missed
              else if curr.bp
                ++b_incorrect

              ++i

            cor = a_correct + b_correct
            err = a_missed + b_missed + a_incorrect + b_incorrect
            tot = cor + err
            percent = 100 * (cor/tot)

            return {
              a_correct: a_correct
              b_correct: b_correct
              a_incorrect: a_incorrect
              b_incorrect: b_incorrect
              a_missed: a_missed
              b_missed: b_missed
              percent: percent
            }

          window.draw_history_graph = (container, history) ->
            drawGraph = (opts) ->
              o = Flotr._.extend(Flotr._.clone(options), opts or {})
              ds = []
              i = 0
              while i < d.length
                ds.push {data:d[i], label:"Dual #{i+1}-Back", lines:{show:true}, points:{show:true}}
                ++i
              Flotr.draw container, ds, o
            options = undefined
            graph = undefined
            x = undefined
            o = undefined
            i = 0
            d = []
            while i < history.length
              n = history[i].n
              r = generate_results history[i].turns, n
              if not d[n-1]?
                d[n-1] = []
              d[n-1].push [Date.parse(history[i].timestamp), r.percent]
              i++
            options =
              xaxis:
                mode: "time"
                labelsAngle: 45

              selection:
                mode: "x"

              HtmlText: false
              title: "Time"
              legend:
                position: 'nw'

            graph = drawGraph()
            Flotr.EventAdapter.observe container, "flotr:select", (area) ->
              graph = drawGraph(
                xaxis:
                  min: area.x1
                  max: area.x2
                  mode: "time"
                  labelsAngle: 45

                yaxis:
                  min: area.y1
                  max: area.y2
              )

            Flotr.EventAdapter.observe container, "flotr:click", ->
              graph = drawGraph()

          dual_n_back = (n, count, turn_dur=3000) ->
            started = false
            timestamp = new Date
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
                ap:false
                bp:false

              # Add some more matches:
              if (i >= n) and (Math.random() < 0.07)
                turns[i-n].a = a
                console.log "a#{i}"
              if (i >= n) and (Math.random() < 0.07)
                turns[i-n].b = b
                console.log "b#{i}"
              ++i


            $('#type').html "Dual #{n}-Back"
            start = undefined
            intvl = 0

            start = (done) ->
              started = true
              current = 0
              setTimeout ->
                intvl = setInterval ->
                  if current >= count
                    clearInterval intvl
                    done generate_results(turns, n)
                    return

                  $('#type').html "Dual #{n}-Back"
                  $('#remaining').html "#{current+1} of #{count}"
                  highlight grid[turns[current].a]
                  sounds[turns[current].b].play()
                  
                  ++current
                , turn_dur
              , 2250 - turn_dur

            return {
              n: n
              count: count
              turns: turns
              turn_dur: turn_dur
              timestamp: timestamp
              a_pressed: ->
                if not turns[current-1].ap
                  if a_matches(turns, n, current-1)
                    highlight $('#a_button'), 'success', 0, 250
                  else
                    highlight $('#a_button'), 'failure', 0, 250
                  turns[current-1].ap = true
              b_pressed: ->
                if not turns[current-1].bp
                  if b_matches(turns, n, current-1)
                    highlight $('#b_button'), 'success', 0, 250
                  else
                    highlight $('#b_button'), 'failure', 0, 250
                  turns[current-1].bp = true
              start: (done=new Function) ->
                start(done)
              stop: ->
                if intvl
                  clearInterval intvl
                  $('body').removeClass 'playing'
            }

          new_round = ->
            if not window.round?
              s = JSON.parse localStorage.getItem('settings')
              $('body').addClass 'playing'
              n = parseInt(s.n)
              count = parseInt(s.count) + n*n
              turndur = parseInt(s.turndur)
              window.round = dual_n_back n, count, turndur
              $('#results').hide()
              round.start (r) ->
                h = JSON.parse localStorage.getItem 'history'
                if not h?
                  h = []
                h.push round
                localStorage.setItem 'history', JSON.stringify h

                window.round = undefined
                percent = Math.round r.percent

                localStorage.setItem 'lastgame', JSON.stringify new Date

                if percent < 50
                  cssclass = 'bad'
                  msg = choose [
                    'Don\'t be discouraged!'
                    'Give it another try!'
                    'Keep practicing!'
                    'Don\'t worry, you\'ll get there.'
                  ]
                else if percent < 60
                  cssclass = 'better'
                  msg = choose [
                    'Not bad.'
                    'Keep practicing!'
                  ]
                else if percent < 70
                  cssclass = 'better'
                  msg = choose [
                    'You\'re getting there!'
                    'Not bad!'
                  ]
                else if percent < 80
                  cssclass = 'better'
                  msg = choose [
                    'Nice score!'
                    'Nice job! Keep it up!'
                    'Well done!'
                  ]
                else if percent < 100
                  cssclass = 'excellent'
                  msg = choose [
                    'Excellent!'
                    'Now you\'ve got it!'
                    'Bravo!'
                    '*high fives*'
                  ]
                else
                  cssclass = 'excellent'
                  msg = choose [
                    'Perfect! *high fives*'
                    'Outstanding!'
                    'Masterful!'
                    '<i>Dayum.</i> Is this too easy for you?'
                  ]


                if s.mode == 'training'
                  if percent >= s.advance_threshold
                    ++s.n
                    msg += "<b><br>N increased to #{s.n}</b>!"
                  else if percent < s.retreat_threshold
                    strikes = localStorage.getItem('strikes') or 0
                    if n >= 2
                      msg += "<br>Strike #{++strikes} of 3"
                      if strikes >= 3
                        strikes = 0
                        --s.n
                        msg += "<b><br><i>N</i> decreased to #{s.n}</b>"
                    localStorage.setItem 'strikes', strikes

                localStorage.setItem 'settings', JSON.stringify s
                update_settings_display()

                flash "#{percent}% correct<br>#{msg}", cssclass, 'Okay', ->
                  $('#nav a[href="#stats"]').click()
                  $('body').removeClass 'playing'
                  draw_history_graph $('#graph')[0], JSON.parse localStorage.getItem 'history'

          all_loaded = ->
            $('body').removeClass 'loading'
            $('#nav').show()
            $('#content').show()
            settings = JSON.parse(localStorage.getItem('settings')) or _defaultSettings
            if settings.mode == 'training'
              lastgame = new Date JSON.parse localStorage.getItem 'lastgame'
              if ((new Date) - lastgame) > 24 * 60 * 60 * 1000
                settings.n = 2
                localStorage.setItem 'strikes', 0
            localStorage.setItem 'settings', JSON.stringify settings
            update_settings_display()

            h = JSON.parse(localStorage.getItem('history')) or []

            draw_history_graph $('#graph')[0], h

            $(window).keydown (e) ->
              switch e.which
                when 65 # A
                  return true if not window.round
                  round.a_pressed()
                when 76 # B
                  return true if not window.round
                  round.b_pressed()
                when 32 # Spacebar
                  if $('body').hasClass 'flash'
                    flash.continue()
                  else if not $('body').hasClass 'playing'
                    new_round()
                when 27 # ESC
                  return true if not $('body').hasClass('playing')
                  round.stop()
                  window.round = undefined
              return true

            $(window).on 'click', '#a_button', ->
              return true if not window.round
              round.a_pressed()
            $(window).on 'click', '#b_button', ->
              return true if not window.round
              round.b_pressed()

            $('#cancel').click ->
              if window.round?
                round.stop()
                window.round = undefined

            $('#game').on 'change', 'input', ->
              console.log @
              settings = JSON.parse localStorage.getItem('settings')
              settings[@name] = @value
              localStorage.setItem 'settings', JSON.stringify settings
              update_settings_display()

            $('#clear-history').click ->
              return if not confirm "Are you sure?"
              clear_history()
              draw_history_graph $('#graph')[0], JSON.parse localStorage.getItem 'history'

            $('#reset-settings').click ->
              return if not confirm "Are you sure?"
              reset_settings()
              update_settings_display()
            
            $('#new-game').click ->
              new_round()

            $('#nav [href="#game"]').click()
