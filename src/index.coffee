html ->
  head ->
    meta charset:'utf-8'
    title 'Dual N-Back'
    link rel:'stylesheet', href:'style.css'
    script src:'jquery-1.7.2.min.js'

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
