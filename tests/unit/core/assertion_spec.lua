local assertion = require('vgit.core.assertion')

describe('assertion:', function()
  describe('assert', function()
    it('should not throw error if conditions are met', function() assertion.assert(true) end)

    it('should throw error if conditions are not met', function()
      assert.has_error(function() assertion.assert(false) end)
    end)
  end)

  describe('assert_type', function()
    it('should throw an error if value is not of a certain type', function()
      assert.has_error(function()
        assertion.assert_type(3, 'string')
        assertion.assert_type(3, 'function')
        assertion.assert_type('foo', 'number')
      end)
    end)

    it('should not throw an error if value is of a certain type', function()
      assertion.assert_type(3, 'number')
      assertion.assert_type(function() end, 'function')
    end)
  end)

  describe('assert_number', function()
    it('should throw an error if value is not a number', function()
      assert.has_error(function() assertion.assert_number('foo') end)
    end)

    it('should not throw an error if value is not a number', function() assertion.assert_number(3) end)
  end)

  describe('assert_string', function()
    it('should throw an error if value is not a string', function()
      assert.has_error(function() assertion.assert_string(3) end)
    end)

    it('should not throw an error if value is not a string', function() assertion.assert_string('foo') end)
  end)

  describe('assert_function', function()
    it('should throw an error if value is not a function', function()
      assert.has_error(function() assertion.assert_function(3) end)
    end)

    it('should not throw an error if value is not a function', function()
      assertion.assert_function(function() end)
    end)
  end)

  describe('assert_boolean', function()
    it('should throw an error if value is not a booean', function()
      assert.has_error(function() assertion.assert_boolean(3) end)
    end)

    it('should not throw an error if value is not a bolean', function() assertion.assert_boolean(true) end)
  end)

  describe('assert_nil', function()
    it('should throw an error if value is not a nil', function()
      assert.has_error(function() assertion.assert_nil(3) end)
    end)

    it('should not throw an error if value is not a nil', function() assertion.assert_nil(nil) end)
  end)

  describe('assert_table', function()
    it('should throw an error if value is not a table', function()
      assert.has_error(function() assertion.assert_table(3) end)
    end)

    it('should not throw an error if value is not a table', function() assertion.assert_table({}) end)
  end)

  describe('assert_list', function()
    it('should throw an error if value is not a table', function()
      assert.has_error(function() assertion.assert_list({ hello = 'world' }) end)
    end)

    it('should not throw an error if value is not a table', function() assertion.assert_list({ 1, 2, 3, 4 }) end)
  end)
end)
