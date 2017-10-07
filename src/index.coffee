window = global
window.lock_mixin_constructor = (_t)->
  _t.$lock_cb_list = []
window.lock_mixin = (_t)->
  _t.prototype.$lock_cb_list = []
  _t.prototype.$limit = 1
  _t.prototype.lock = (on_end)->
    if @$limit > 0
      @$limit--
      on_end()
    else
      @$lock_cb_list.push on_end
    return
  _t.prototype.unlock = ()->
    call_later ()=>
      if @$lock_cb_list.length
        cb = @$lock_cb_list.shift()
        cb()
      else
        @$limit++
    return
class window.Lock_mixin
  lock_mixin @
  constructor : ()->
    lock_mixin_constructor @