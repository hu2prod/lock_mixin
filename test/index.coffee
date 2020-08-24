assert = require "assert"

mod = require "../src/index.coffee"

describe "index section", ()->
  it "mixin constructor", ()->
    class A
      lock_mixin @
      constructor:()->
        lock_mixin_constructor @
    new A
    return
  
  it "mixin class global", ()->
    new Lock_mixin
    return
  
  it "mixin class exports", ()->
    new mod.Lock_mixin
    return
  
  describe "lock_test", ()->
    it "pass", (done)->
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
    
    it "lock", (done)->
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
    
    it "no drain", (done)->
      target = new Lock_mixin
      target.$limit = 10
      
      for i in [0 ... 20]
        await target.lock defer()
        do ()->
          await setTimeout defer(), 10
          target.unlock()
      
      assert target.$count > 0
      done()
    
    it "empty drain", (done)->
      target = new Lock_mixin
      target.$limit = 10
      await target.drain defer()
      
      assert.equal target.$count, 0
      assert.equal target.$lock_cb_list.length, 0
      done()
    
    it "drain", (done)->
      target = new Lock_mixin
      target.$limit = 10
      
      for i in [0 ... 20]
        await target.lock defer()
        do ()->
          await setTimeout defer(), 10
          target.unlock()
      
      await target.drain defer()
      
      assert.equal target.$count, 0
      assert.equal target.$lock_cb_list.length, 0
      done()
    
    it "wrap", (done)->
      target = new Lock_mixin
      await target.wrap done, defer(done)
      
      done()
  