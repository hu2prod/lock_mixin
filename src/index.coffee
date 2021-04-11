window = global
window.lock_mixin_constructor = (_t)->
  _t.$lock_cb_list = []

window.lock_mixin = (_t)->
  _t.prototype.$lock_cb_list = []
  # TODO drain_cb_list
  _t.prototype.$drain_cb = null
  _t.prototype.$count = 0
  _t.prototype.$limit = 1
  _t.prototype.lock = (on_end)->
    if @$count < @$limit
      @$count++
      on_end()
    else
      @$lock_cb_list.push on_end
    return
  
  _t.prototype.can_lock = ()-> @$count < @$limit
  
  _t.prototype.unlock = ()->
    # removed call_later from fy
    # -1 dep, and not signifficantly worse
    setTimeout ()=>
      if @$lock_cb_list.length
        cb = @$lock_cb_list.shift()
        cb()
      else
        @$count--
        if @$count == 0 and cb = @$drain_cb
          @$drain_cb = null
          cb()
    , 0
    return
  
  _t.prototype.drain = (on_end)->
    if @$count == 0
      on_end()
    else
      @$drain_cb = on_end
    return
  
  _t.prototype.wrap = (on_end, nest)->
    @lock ()=>
      nest (res...)=>
        @unlock()
        on_end res...

class window.Lock_mixin
  lock_mixin @
  constructor : ()->
    lock_mixin_constructor @

@Lock_mixin = window.Lock_mixin
