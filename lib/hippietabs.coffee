$.fn.hippieTabs= () ->
  new HippieTabs(this)

class HippieTabs
  constructor:(@element)->
    @element.on 'mousedown', 'li', @startMouse
    @element.on 'click', 'span.htab-close', @closeTab
    @element.on 'mousedown', 'span.htab-close', (event)->
      event.stopPropagation()
    $(document).on 'mouseleave', @stopDrag
    $(document).on 'mousemove', @moveMouse
    @dragging = false
    @drag15px = false
    @initTabLeft = 0
    @initMouseX = 0
    @tabWidth = @element.find('li').width()
    console.log @element

  startMouse: (event) =>
    @initMouseX = event.clientX
    $('.htab-active').removeClass('htab-active')
    act = $(event.target).parent()
    act.addClass('htab-active')
    @element.trigger 'htabactivate',[act.attr('htid'),act.attr('htdata')]
    @dragging = true

  startTouch: (event) =>
    event.preventDefault()
    event.stopPropagation()
    @initMouseX = event.originalEvent.changedTouches[0].pageX
    console.log event.originalEvent.changedTouches[0].pageX
    @dragging = true

  stopDrag: (event) =>
    if @drag15px
      @element.find('.htab-active:first').animate 'left': '0'
    @dragging = false
    @drag15px = false

  endTouch: (event) =>
    if @dragging
      @element.find('.htab-active:first').animate 'left': '0'
    @dragging = false

  moveMouse: (event) =>
    return if not @dragging
    whichM = if typeof event.buttons isnt 'undefined' then event.buttons else event.which
    return @stopDrag() if whichM isnt 1
    event.preventDefault()
    @move event.clientX

  closeTab: (event) =>
    rem = $(event.target).parent().parent()
    @element.trigger 'htabclose',[rem.attr('htid'),rem.attr('htdata')]
    rem.animate {'width': '0'}, ()->
      rem.remove()

  createTab: (title, id='', data='') =>
    tab = "<li htid=\"#{id}\" htdata=\"#{data}\"><span>#{title}<span class=\"htab-close\"></span></span></li>"
    @element.append tab
    tab = @element.find('li:last')
    @tabWidth = tab.width()
    @element.trigger 'htabcreate',[id,data,title]
    tab

  moveTouch: (event) =>
    @dragging = true
    event.preventDefault()
    event.stopPropagation()
    @move event.originalEvent.changedTouches[0].pageX

  move: (Xpos) =>
    offset = Xpos - @initMouseX
    return if @drag15px isnt true and Math.abs(offset) < 16
    @drag15px = true
    tabheaders = @element.find('li')
    active_tab = @element.find('.htab-active')
    ind = -1
    for tabh in tabheaders
      ind = _i if $(tabh).is(active_tab)
    atEnd = ind is tabheaders.length-1
    if offset < 0 and ind is 0
      offset = 0
    rel_position = Math.round((offset)/@tabWidth)
    rel_position = 0 if atEnd and rel_position > 0
    if rel_position isnt 0
      if rel_position > 0
        @element.find('.htab-active').insertAfter tabheaders[ind+rel_position]
      if rel_position < 0
        @element.find('.htab-active').insertBefore tabheaders[ind+rel_position]
      @initMouseX += @tabWidth * rel_position if ind+rel_position >= 0 or ind+rel_position <= tabheaders.length

    offset = Xpos - @initMouseX if offset isnt 0
    @element.find('.htab-active:first').stop()
    @element.find('.htab-active:first').css 'left': offset+'px'