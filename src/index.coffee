html ->
  head ->
    meta charset:'utf-8'
    title 'Dual N-Back'
    link rel:'stylesheet', href:'style.css'
    link rel:'stylesheet', href:'flotr2-examples.css'
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
            ul ->
              li 'Any time a grid square you saw <i>N</i> turns ago is highlighted again, press [A]'
              li 'Any time a letter you heard <i>N</i> turns ago is spoken again, press [L]'
              li 'It\'s possible for both of these cases to occur on the same turn'
              li 'Don\'t be discouraged! You <strong>will</strong> improve with practice!'

      div id:'stats', ->
        fieldset id:'graph-panel', class:'outer', ->
          fieldset ->
            legend 'Your Progress'
            div id:'graph'
          br ''
          button id:'clear-history', 'Clear My History'


      div id:'game', ->
        fieldset class:'outer', ->
          fieldset id:'game-mode', ->
            legend 'Game Mode'
            input id:'n1', type:'radio', name:'n', value:'1'
            label for:'n1', 'Dual <strong>1</strong>-Back'
            input id:'n2', type:'radio', name:'n', value:'2'
            label for:'n2', 'Dual <strong>2</strong>-Back'
            input id:'n3', type:'radio', name:'n', value:'3'
            label for:'n3', 'Dual <strong>3</strong>-Back'
          fieldset id:'settings', ->
            legend 'Settings'
            text 'Number of Turns: '
            input id:'count', name:'count', type:'number', value:24
            br ''
            text 'Turn Duration: '
            input id:'turndur', name:'turndur', type:'number', value:3000
            text 'ms'
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
          table id:'layout', ->
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
          n: 2
          count: 24
          turndur: 3000
        
        update_settings_display = ->
          settings = JSON.parse localStorage.getItem 'settings'
          $("#game input[name='n'][value=#{settings.n}]").attr('checked', 'checked')
          $("#game input[name='n'][value!=#{settings.n}]").attr('checked', false)

          for own name,val of settings
            continue if name is 'n'
            $("#game input[name='#{name}']'").val parseInt val

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

        flash = (text, cssClass, buttonText='Continue', cb=undefined) ->
          $('#flash').html text
          $('#flash').removeClass 'bad'
          $('#flash').removeClass 'better'
          $('#flash').removeClass 'excellent'
          $('#flash').addClass cssClass
          $('body').addClass 'flash'
          
          $('#continue').click ->
            if cb?
              cb()
            $('body').removeClass 'flash'

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

            tot = a_missed + b_missed + a_correct + b_correct
            cor = a_correct + b_correct - a_incorrect - b_incorrect
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
              Flotr.draw container, [
                {data:d1, label:'Dual 1-Back', lines:{show:true}, points:{show:true}}
                {data:d2, label:'Dual 2-Back', lines:{show:true}, points:{show:true}}
                {data:d3, label:'Dual 3-Back', lines:{show:true}, points:{show:true}}
              ], o
            d1 = []
            d2 = []
            d3 = []
            options = undefined
            graph = undefined
            x = undefined
            o = undefined
            i = 0
            while i < history.length
              r = generate_results history[i].turns, history[i].n
              switch history[i].n
                when 1
                  d1.push [Date.parse(history[i].timestamp), r.percent]
                when 2
                  d2.push [Date.parse(history[i].timestamp), r.percent]
                when 3
                  d3.push [Date.parse(history[i].timestamp), r.percent]
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
            intvl = 0

            start = (done) ->
              started = true
              current = 0
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

            return {
              n: n
              count: count
              turns: turns
              turn_dur: turn_dur
              timestamp: timestamp
              a_pressed: ->
                if not turns[current-1].a_pressed
                  if a_matches(turns, n, current-1)
                    highlight $('#a_button'), 'success', 0, 250
                  else
                    highlight $('#a_button'), 'failure', 0, 250
                  turns[current-1].a_pressed = true
              b_pressed: ->
                if not turns[current-1].b_pressed
                  if b_matches(turns, n, current-1)
                    highlight $('#b_button'), 'success', 0, 250
                  else
                    highlight $('#b_button'), 'failure', 0, 250
                  turns[current-1].b_pressed = true
              start: (done=new Function) ->
                start(done)
              stop: ->
                if intvl
                  clearInterval intvl
                  $('body').removeClass 'playing'
            }

          new_round = ->
            if not window.round?
              settings = JSON.parse localStorage.getItem('settings')
              $('body').addClass 'playing'
              window.round = dual_n_back settings.n, settings.count, settings.turndur
              $('#results').hide()
              round.start (r) ->
                h = JSON.parse localStorage.getItem 'history'
                if not h?
                  h = []
                h.push round
                localStorage.setItem 'history', JSON.stringify h

                window.round = undefined
                percent = Math.round r.percent
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

                flash "#{percent}% correct<br>#{msg}", cssclass, 'Okay', ->
                  $('#nav a[href="#stats"]').click()
                  $('body').removeClass 'playing'
                  draw_history_graph $('#graph')[0], JSON.parse localStorage.getItem 'history'


          all_loaded = ->
            $('body').removeClass 'loading'
            $('#nav').show()
            $('#content').show()

            settings = JSON.parse(localStorage.getItem('settings')) or _defaultSettings
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
                #when 32 # Spacebar
                #  return true if $('body').hasClass('playing')
                #  new_round()
              return true

            $(window).on 'click', '#a_button', ->
              return true if not window.round
              round.a_pressed()
            $(window).on 'click', '#b_button', ->
              return true if not window.round
              round.b_pressed()

            $('#game').on 'change', 'input', ->
              settings = JSON.parse localStorage.getItem('settings')
              settings[@name] = parseInt @value
              localStorage.setItem 'settings', JSON.stringify settings

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

            $('#nav [href="#help"]').click()
