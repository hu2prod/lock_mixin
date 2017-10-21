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
      lock = new Lock_mixin
      assert.equal lock.$limit, 1
      await lock.lock defer()
      assert.equal lock.$limit, 0
      lock.unlock()
      assert.equal lock.$limit, 0
      await setTimeout defer(), 10
      assert.equal lock.$limit, 1
      done()
      return
    
    it 'lock', (done)->
      lock = new Lock_mixin
      assert.equal lock.$limit, 1
      await lock.lock defer()
      assert.equal lock.$limit, 0
      setTimeout ()->
        lock.unlock()
      , 10
      await lock.lock defer()
      assert.equal lock.$limit, 0
      await setTimeout defer(), 10
      assert.equal lock.$limit, 0
      
      lock.unlock()
      await setTimeout defer(), 10
      assert.equal lock.$limit, 1
      done()
      return
  