###
# Touch Tabs JQuery was created by Cole Lawrence(github:ZombieHippie)
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
# Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
###

$.fn.touchTabs= () ->
  this.addClass('TouchTabs')
  new TouchTabs(this)

class TouchTabs
  constructor:(@element)->
    @element.on 'mousedown', 'li', @startMouse
    @element.on 'click', 'span.tab-close', @onClickClose
    @element.on 'mousedown', 'span.tab-close', (event)->
      event.stopPropagation()
    $(document).on 'mouseleave', @onMouseLeave
    $(document).on 'mousemove', @onMouseMove
    @element.on 'touchend', @onTouchEnd
    @element.on 'touchcancel', @onTouchEnd
    @element.on 'touchleave', @onTouchEnd
    @element.on 'touchmove', @onTouchMove

    @dragging = false
    @drag15px = false
    @initMouseX = 0
    @tabWidth = @element.find('li').width()

  on: (eventType, fn) =>
    @element.on eventType, fn

  ## TOUCH & MOUSE EVENT BINDING
  onClickClose: (event) =>
    rem = $(event.target).parents('li.closeable')
    @removeTab(rem)

  startMouse: (event) =>
    @initMouseX = event.clientX
    id = $(event.target).parents('li').attr('tabid')
    @activateTabById(id) if event.button is 0
    if event.button is 1
      clos = @findById @element, id, "middle click"
      @closeTabById(id) if clos.hasClass "closeable"
      event.preventDefault()
    @dragging = true

  onMouseLeave: () =>
    if @drag15px
      @element.find('.tab-active:first').animate 'left': '0'
    @dragging = false
    @drag15px = false

  onTouchEnd: (event) =>
    if @dragging
      @element.find('.tab-active:first').animate 'left': '0'
    @dragging = false

  onMouseMove: (event) =>
    return if not @dragging
    whichM = if typeof event.buttons isnt 'undefined' then event.buttons else event.which
    return @onMouseLeave() if whichM isnt 1
    event.preventDefault()
    @move event.clientX

  onTouchMove: (event) =>
    @dragging = true
    event.preventDefault()
    event.stopPropagation()
    @move event.originalEvent.changedTouches[0].pageX

  ## MANIPULATION
  createTab: (id, title, closeable=true) =>
    tab = "<li tabid=\"#{id}\"><span>
            <span class=\"title\">#{title}</span>
            #{if closeable then "<span class=\"tab-close\"></span>" else ""}
          </span></li>"
    @element.append tab
    tab = @element.find('li:last')
    @tabWidth = tab.width()
    tab.addClass "closeable" if closeable
    @element.trigger 'tabcreate',[id,title]
    @bindTouch tab
    @activateTabById id

  bindTouch: (tabElem) =>
    tabid = tabElem.attr 'tabid'

    # bind tab switch action on tab header or close tab
    tabElem.bind "touchstart", (event) =>
      @activateTabById tabid
      @initMouseX = event.originalEvent.changedTouches[0].pageX
      event.preventDefault()
      event.stopPropagation()
      @dragging = true

    # bind tab-close
    tabElem.find("span.tab-close").bind "touchstart", (event) =>
      @closeTabById tabid
      event.stopPropagation()

  activateTabById: (id,trigger=true) =>
    act = @findById @element, id, "tab activation"
    return if act is null
    @element.find('.tab-active').removeClass('tab-active')
    act.addClass 'tab-active'
    @element.trigger 'tabactivate',[act.attr('tabid')]

  renameTabById: (id, newname) =>
    act = @findById @element, id, "tab renaming"
    return if act is null
    act = act.find "span>span.title"
    act.html(newname)

  closeTabById: (id, trigger=true) =>
    rem = @findById @element, id, "removal"
    return if rem is null
    activateNewTab = rem.hasClass('tab-active')
    @element.trigger 'tabclose',[rem.attr('tabid')] if trigger
    rem.animate {'width': '0'}, () =>
      rem.remove()
      @activateTabById @element.find('li:first').attr 'tabid' if activateNewTab

  findById: (element, id, operation) ->
    tab = element.find "[tabid="+id+"]"
    if tab.length is 0
      throw "Error: Could not select tab with tabid:\"#{id}\". Failed attempted #{operation}"
      return null
    else 
      tab

  move: (Xpos) =>
    offset = Xpos - @initMouseX
    return if @drag15px isnt true and Math.abs(offset) < 16
    @drag15px = true
    tabheaders = @element.find('li')
    active_tab = @element.find('.tab-active')
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
        @element.find('.tab-active').insertAfter tabheaders[ind+rel_position]
      if rel_position < 0
        @element.find('.tab-active').insertBefore tabheaders[ind+rel_position]
      @initMouseX += @tabWidth * rel_position if ind+rel_position >= 0 or ind+rel_position <= tabheaders.length

    offset = Xpos - @initMouseX if offset isnt 0
    @element.find('.tab-active:first').stop()
    @element.find('.tab-active:first').css 'left': offset+'px'