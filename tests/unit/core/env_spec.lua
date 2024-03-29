local env = require('vgit.core.env')

local eq = assert.are.same

describe('env:', function()
  describe('set', function()
    it('should throw an error if type is not a string', function()
      assert.has_error(function()
        env.set('string', function() end)
      end)
      assert.has_error(function() env.set(3, {}) end)
      assert.has_error(function() env.set(3, { 'hello' }) end)
    end)

    it('should set a value', function()
      env.set('foo', 'bar')
      env.set('bar', 3)
      env.set('baz', true)
      assert(env.get('foo'))
      assert(env.get('bar'))
      assert(env.get('baz'))
    end)
  end)

  describe('get', function()
    it('should throw an error if type is not a string', function()
      assert.has_error(function() env.get(3) end)
    end)

    it('should retrieve a value that has been set', function() eq(env.set('foo', 'bar').get('foo'), 'bar') end)
  end)

  describe('unset', function()
    it('should throw an error if type is not a string', function()
      assert.has_error(function() env.unset(3) end)
    end)

    it('should throw an error if value is not set', function()
      assert.has_error(function() env.unset('hello') end)
    end)

    it('should unset a key that has been set', function()
      eq(env.set('foo', 'bar').get('foo'), 'bar')
      env.unset('foo')
      eq(env.get('foo'), nil)
    end)
  end)
end)
