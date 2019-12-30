assert = require 'assert'

mod = require '../src/index.coffee'

describe 'index section', ()->
  it 'mixin constructor', ()->
    class A
      lock_mixin @
      constructor:()->
        lock_mixin_constructor @
    new A
    return
  
  it 'mixin class global', ()->
    new Lock_mixin
    return
  
  it 'mixin class exports', ()->
    new mod.Lock_mixin
    return
  
  describe 'lock_test', ()->
    it 'pass', (done)->
      target = new Lock_mixin
      assert.equal target.$count, 0
      await target.lock defer()
      assert.equal target.$count, 1
      target.unlock()
      assert.equal target.$count, 1
      await setTimeout defer(), 10
      assert.equal target.$count, 0
      done()
      return
    
    it 'lock', (done)->
      target = new Lock_mixin
      assert.equal target.$count, 0
      await target.lock defer()
      assert.equal target.$count, 1
      setTimeout ()->
        target.unlock()
      , 10
      await target.lock defer()
      assert.equal target.$count, 1
      await setTimeout defer(), 10
      assert.equal target.$count, 1
      
      target.unlock()
      await setTimeout defer(), 10
      assert.equal target.$count, 0
      done()
      return
  