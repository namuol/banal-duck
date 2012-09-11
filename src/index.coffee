html ->
  head ->
    meta charset:'utf-8'
    meta
      name:'viewport'
      content:'''width=100%; 
              initial-scale=1;
              maximum-scale=1;
              minimum-scale=1; 
              user-scalable=no;'''
    title 'Dual N-Back'
    link rel:'stylesheet', href:'flotr2-examples.css'
    link href:'http://fonts.googleapis.com/css?family=Carme', rel:'stylesheet', type:'text/css'
    link rel:'stylesheet', href:'style.css'
    script type:'text/javascript', src:'json2.min.js'
    script type:'text/javascript', src:'storage.min.js'
    script type:'text/javascript', src:'jquery-1.7.2.min.js'
    script type:'text/javascript', src:'soundmanager2.js'
    script type:'text/javascript', src:'flotr2.min.js'
    script type:'text/javascript', src:'http://www.parsecdn.com/js/parse-1.0.21.min.js'
    text """
      <script type="text/javascript">

        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-33247419-1']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();

      </script>
    """

  body class:'loading', ->
    div id:'vignette', ''
    div id:'loading_wrapper', ->
      table ->
        tbody ->
          tr ->
            td id:'loading', ->
              text 'Please Wait...'
              br ''
              span id:'sounds_loaded_count', '0'
              text ' / 8 sounds loaded'

    div id:'nav', ->
      ul ->
        li class:'first', ->
          a id:'profile_display', href:'#game', 'Log In'
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
              ul ->
                li 'But <i>why</i> does it work? Here\'s some <a href="http://www.gwern.net/DNB%20FAQ" target="_blank">recommended reading</a>.'

      div id:'stats', ->
        fieldset id:'graph-panel', class:'outer', ->
          fieldset ->
            legend 'Your Progress'
            div id:'graph'
          br ''
          button id:'clear-history', 'Clear My Progress'


      div id:'game', ->
        fieldset id:'profile', class:'outer', ->
          fieldset ->
            legend 'Sign Up'
            form id:'new_profile_form', ->
              input placeholder:'Email', id:'new_profile_email', email:'new_profile_email', type:'text', required:'required'
              br ''
              input placeholder:'Username', id:'new_profile_name', name:'new_profile_name', type:'text', required:'required'
              br ''
              input placeholder:'Password', id:'new_profile_pass', name:'new_profile_pass', type:'password', required:'required'
              br ''
              button id:'new_profile_create', 'Create'

          fieldset ->
            legend 'Log In'
            form id:'log_in_form', ->
              input placeholder:'Username', id:'profile_name', name:'profile_name', type:'text', required:'required'
              br ''
              input placeholder:'Password', id:'profile_pass', name:'profile_pass', type:'password', required:'required'
              br ''
              button id:'log_in_button', 'Log In'
              a id:'trouble_logging_in', href:'#', 'Trouble logging in?'

            form id:'reset_pass_form', ->
              input placeholder:'Email', id:'reset_pass_email', name:'reset_pass_email', type:'text', required:'required'
              br ''
              button id:'reset_pass_button', 'Reset My Password'
              button id:'cancel_reset_pass', 'Cancel'

        fieldset id:'game_settings', class:'outer', ->
          fieldset id:'game-mode', ->
            legend 'Progress Mode'

            input id:'mode_training', type:'radio', name:'mode', value:'training'
            label for:'mode_training', 'Training'
            input id:'mode_manual', type:'radio', name:'mode', value:'manual'
            label for:'mode_manual', 'Manual'
            
            div id:'n-wrap', ->
              text 'Dual '
              input id:'n', name:'n', type:'number'
              input id:'n_manual', name:'n_manual', type:'number'
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
          button id:'reset-settings', 'Reset My Settings'
          button id:'log_out', 'Log Out'

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

    div id:'back', ->
      a href:'http://namuol.github.com', 'namuol.github.com'

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

        Parse.initialize 'vrBnhG18TQkX99xX1MDw3paUIVJWYwmT5rVvkfJe',
                         'GYI87sIoXXru3ToOa33Gculz7RSWAxupGWiQWwtT'

        _newProfile =
          settings:
            mode: 'training'
            n: 2
            n_manual: 2
            count: 20
            turndur: 3000
            retreat_threshold: 50
            advance_threshold: 80
          strikes: 0
          history: []

        window.lget = (itemName) ->
          user = Parse.User.current()
          return undefined if not user
          item = user.get itemName
          return undefined if not item?
          return item

        window.lset = (itemName, val) ->
          user = Parse.User.current()
          return if not user
          changes = {}
          changes[itemName] = val
          user.save changes,
            error: (user, error) ->
              flash error.message, 'err'

          return val

        update_settings_display = ->
          $('#profile_display').html '@' + Parse.User.current().get 'username'
          settings = lget 'settings'
          $("#game input[name='mode']").attr 'checked', false
          $("#game input[name='mode'][value='#{settings.mode}']").attr 'checked', 'checked'
          for own name,val of settings
            continue if name is 'mode'
            $("#game input[name='#{name}']'").val val

          if settings.mode == 'manual'
            $('#n').hide()
            $('#n_manual').show()
            $('#retreat_threshold').attr 'disabled', 'disabled'
            $('#advance_threshold').attr 'disabled', 'disabled'
          else
            $('#n').show()
            $('#n_manual').hide()
            $('#n').attr 'disabled', 'disabled'
            $('#retreat_threshold').attr 'disabled', false
            $('#advance_threshold').attr 'disabled', false

          $('#extra_count').html settings.n*settings.n
        
        reset_settings = ->
          lset 'settings', _newProfile.settings

        clear_history = ->
          lset 'history', []

        $('#nav').on 'click', 'li', ->
          $('.selected').removeClass 'selected'
          $('#content > div').hide()
          $(@).addClass 'selected'
          href = $(@).children('a').attr('href')
          $(href).show()
          return false

        $('#log_out').click (e) ->
          Parse.User.logOut()
          $('#game_settings').hide()
          $('#profile').show()

        $('#log_in_form').submit (e) ->
          e.preventDefault()

          name = $('#profile_name').val()
          pass = $('#profile_pass').val()
          Parse.User.logIn name, pass,
            success: (user) ->
              $('#profile').hide()
              update_settings_display()
              $('#game_settings').show()
            error: (user, error) ->
              flash error.message, 'err'

          $('#profile_name').val ''
          $('#profile_pass').val ''
          return false

        $('#trouble_logging_in').click (e) ->
          e.preventDefault()
          $('#reset_pass_form').show()
          $('#log_in_form').hide()
          return false

        $('#cancel_reset_pass').click (e) ->
          e.preventDefault()
          $('#reset_pass_form').hide()
          $('#log_in_form').show()
          return false

        $('#reset_pass_form').submit (e) ->
          e.preventDefault()

          email = $('#reset_pass_email').val()
          Parse.User.requestPasswordReset email,
            success: ->
              $('#reset_pass_email').val('')
              $('#reset_pass_email').attr('placeholder', 'Email Sent!')
                .attr('disabled', 'disabled')
                .blur()

              setTimeout ->
                $('#reset_pass_email').attr('disabled', false).attr('placeholder', 'Email')
              , 1500

              $('#reset_pass_form').delay(1500).hide()
              $('#trouble_logging_in').delay(1500).show()
            error: (error) ->
              flash error.message, 'err'

          return false

        $('#new_profile_form').submit (e) ->
          e.preventDefault()

          name = $('#new_profile_name').val()
          pass = $('#new_profile_pass').val()
          email = $('#new_profile_email').val()

          user = new Parse.User
          user.set 'username', name
          user.set 'password', pass
          user.set 'email', email
          for own key,val of _newProfile
            user.set key, val

          user.signUp null,
            success: (user) ->
              $('#profile').hide()
              update_settings_display()
              $('#game_settings').show()
              Parse.User.logIn name, pass,
                success: (user) ->
                  flash 'Success! You\'re all signed up and logged in!', 'excellent'
                  $('#profile').hide()
                  update_settings_display()
                  $('#game_settings').show()
                error: (user, error) ->
                  flash error.message, 'err'
            error: (user, error) ->
              flash error.message, 'err'

          $('#new_profile_name').val ''
          $('#new_profile_pass').val ''
          $('#new_profile_email').val ''
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
          $('input').blur()
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
            url: 'c.mp3'
            volume: 50
          ,
            id: 'h'
            url: 'h.mp3'
            volume: 50
          ,
            id: 'k'
            url: 'k.mp3'
            volume: 50
          ,
            id: 'l'
            url: 'l.mp3'
            volume: 50
          ,
            id: 'q'
            url: 'q.mp3'
            volume: 50
          ,
            id: 'r'
            url: 'r.mp3'
            volume: 50
          ,
            id: 's'
            url: 's.mp3'
            volume: 50
          ,
            id: 't'
            url: 't.mp3'
            volume: 50
        ]

        soundManager.setup
          debugMode: false
          url: 'swf'
          flashVersion: 9
          useHighPerformance: true
          useHTML5Audio: true
          preferFlash: false
          defaultOptions:
            autoLoad: true
            onload: ->
              console.log 'sound loaded: ' + sounds_loaded + ' of ' + sounds_to_load.length
              if ++sounds_loaded == sounds_to_load.length
                all_loaded()
              $('#sounds_loaded_count').html sounds_loaded

        soundManager.onready ->
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
          
          zpad = (n, d) ->
            if n < d
              return '0' + n
            else
              return '' + n

          dstr = (date) ->
            return zpad(date.getUTCFullYear(), 1000) +
                   zpad(date.getUTCMonth(), 10) +
                   zpad(date.getUTCDate(), 10)

          strd = (str) ->
            y = str.slice 0, 4
            m = str.slice 4, 6
            d = str.slice 6, 8
            date = new Date
            date.setUTCFullYear y
            date.setUTCMonth m
            date.setUTCDate d
            date.setUTCHours 0
            date.setUTCMinutes 0
            date.setUTCSeconds 0
            date.setUTCMilliseconds 0
            return date

          window.draw_history_graph = (container, history) ->
            drawGraph = (opts) ->
              o = Flotr._.extend(Flotr._.clone(options), opts or {})
              ds = []
              i = 0
              days = {}
              while i < history.length
                if history[i].training
                  date = dstr new Date Date.parse(history[i].timestamp)
                  if not days[date]?
                    days[date] = []
                  days[date].push parseInt history[i].n
                ++i
              avgArr = []
              maxArr = []
              for own dstring, vals of days
                sum = 0
                i = 0
                max = 0
                while i < vals.length
                  if max < vals[i]
                    max = vals[i]
                  sum += vals[i]
                  ++i
                avg = sum / vals.length
                date = strd(dstring)
                avgArr.push [date, avg]
                maxArr.push [date, max]

              ds.push {data:avgArr, label:"Average N of Session", lines:{show:true}, points:{show:true}}
              ds.push {data:maxArr, label:"Max N of Session", lines:{show:true}, points:{show:true}}

              Flotr.draw container, ds, o
            options = undefined
            graph = undefined
            x = undefined
            o = undefined
            i = 0
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
            settings = lget 'settings'
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
              if (i >= n) and (Math.random() < 0.17)
                turns[i-n].a = a
              if (i >= n) and (Math.random() < 0.17)
                turns[i-n].b = b
              ++i


            $('#type').html "Dual #{n}-Back"
            start = undefined
            intvl = 0

            start = (done) ->
              started = true
              current = 0
              setTimeout ->
                intvl = setInterval ->
                  setTimeout ->
                    if current > 0
                      if not turns[current-1].ap and a_matches(turns, n, current-1)
                        highlight $('#a_button'), 'miss', 0, 70
                      
                      if not turns[current-1].bp and b_matches(turns, n, current-1)
                        highlight $('#b_button'), 'miss', 0, 70
                  , turn_dur - 100

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
              training: settings.mode is 'training'
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
              s = lget 'settings'
              $('body').addClass 'playing'
              if s.mode is 'training'
                n = parseInt(s.n)
              else
                n = parseInt(s.n_manual)
              count = parseInt(s.count) + n*n
              turndur = parseInt(s.turndur)
              window.round = dual_n_back n, count, turndur
              $('#results').hide()
              round.start (r) ->
                settings = lget('settings')
                h = lget 'history'
                if not h?
                  h = []
                h.push round
                lset 'history', h

                window.round = undefined
                percent = Math.round r.percent

                lset 'lastgame', new Date

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
                    strikes = 0
                    msg += "<b><br>N increased to #{s.n}</b>!"
                  else if percent < s.retreat_threshold
                    strikes = parseInt(lget('strikes')) or 0
                    if n >= 2
                      msg += "<br>Strike #{++strikes} of 3"
                      if strikes >= 3
                        strikes = 0
                        --s.n
                        msg += "<b><br><i>N</i> decreased to #{s.n}</b>"
                  lset 'strikes', strikes

                lset 'settings', s
                update_settings_display()

                flash "#{percent}% correct<br>#{msg}", cssclass, 'Okay', ->
                  $('#nav a[href="#stats"]').click()
                  $('body').removeClass 'playing'
                  draw_history_graph $('#graph')[0], lget 'history'

          all_loaded = ->
            $('body').removeClass 'loading'
            $('#nav').show()
            $('#content').show()
            
            if not Parse.User.current()
              $('#profile').show()
              $('#game_settings').hide()
            else
              $('#profile').hide()
              $('#game_settings').show()

              h = lget('history') or []
              draw_history_graph $('#graph')[0], h

              settings = lget('settings')# or _newProfile.settings
              if settings.mode == 'training'
                lastgame = new Date lget 'lastgame'
                if ((new Date) - lastgame) > 24 * 60 * 60 * 1000
                  settings.n = 2
                  lset 'strikes', 0
              lset 'settings', settings
              update_settings_display()


            $(window).keydown (e) ->
              switch e.which
                when 65 # A
                  return true if not window.round?
                  round.a_pressed()
                when 76 # B
                  return true if not window.round?
                  round.b_pressed()
                when 32 # Spacebar
                  if $('body').hasClass 'flash'
                    flash.continue()
                  else if not $('body').hasClass 'playing'
                    new_round()
                when 27 # ESC
                  return true if not window.round?
                  round.stop()
                  window.round = undefined
              return true

            $(window).on 'click', '#a_button', ->
              return true if not window.round?
              round.a_pressed()
            $(window).on 'click', '#b_button', ->
              return true if not window.round?
              round.b_pressed()

            $('#cancel').click ->
              if window.round?
                round.stop()
                window.round = undefined

            $('#game_settings').on 'change', 'input', ->
              settings = lget 'settings'
              settings[@name] = @value
              lset 'settings', settings
              update_settings_display()

            $('#clear-history').click ->
              return if not confirm "Are you sure?"
              clear_history()
              draw_history_graph $('#graph')[0], lget 'history'

            $('#reset-settings').click ->
              return if not confirm "Are you sure?"
              reset_settings()
              update_settings_display()
            
            $('#new-game').click ->
              new_round()

            $('#nav [href="#game"]').click()
