$.fn.hippieTabs= () ->
  new HippieTabs(this)

class HippieTabs
  constructor:(@element)->
    @element.on 'mousedown', 'li', @startMouse
    @element.on 'click', 'span.htab-close', @onClickClose
    @element.on 'mousedown', 'span.htab-close', (event)->
      event.stopPropagation()
    $(document).on 'mouseleave', @stopDrag
    $(document).on 'mousemove', @moveMouse
    @element.on 'touchend', @endTouch
    @element.on 'touchcancel', @endTouch
    @element.on 'touchleave', @endTouch
    @element.on 'touchmove', @moveTouch
    @element.on 'touchstart', @startTouch

    @dragging = false
    @drag15px = false
    @initTabLeft = 0
    @initMouseX = 0
    @tabWidth = @element.find('li').width()
    console.log @element

  onClickClose: (event) =>
    rem = $(event.target).parent().parent()
    @removeTab(rem)

  startMouse: (event) =>
    @initMouseX = event.clientX
    id = $(event.target).parent().attr('htid')
    @activateTabById(id) if event.button is 0
    if event.button is 1
      @closeTabById(id)
      event.preventDefault()
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

  createTab: (title, id, data='') =>
    tab = "<li htid=\"#{id}\" htdata=\"#{data}\"><span>#{title}<span class=\"htab-close\"></span></span></li>"
    @element.append tab
    tab = @element.find('li:last')
    @tabWidth = tab.width()
    @element.trigger 'htabcreate',[id,data,title]
    @bindTouch tab
    @activateTabById id

  bindTouch: (tabElem) =>
    tabElem.find("span.htab-close").bind "touchstart", (event) =>
        @closeTabById(id)
        event.stopPropagation()

    # bind tab switch action on tab header or close tab
    tabElem.bind "touchstart", (event) =>
        editor.activate_tab(id)

  activateTabById: (id, trigger=true) =>
    act = @element.find "[htid="+id+"]"
    @activateTab(act, trigger)

  activateTab: (act, trigger = true) =>
    @element.find('.htab-active').removeClass('htab-active')
    act.addClass('htab-active')
    @element.trigger 'htabactivate',[act.attr('htid'),act.attr('htdata')]


  removeTabById: (id, trigger=true) =>
    rem = @element.find "[htid="+id+"]"
    @removeTab(rem, trigger)

  removeTab: (rem, trigger = true) =>
    activateNewTab = rem.hasClass('htab-active')
    @element.trigger 'htabclose',[rem.attr('htid'),rem.attr('htdata')] if trigger
    rem.animate {'width': '0'}, () =>
      rem.remove()
      @activateTab @element.find('li:first') if activateNewTab

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