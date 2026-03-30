local mount = require("mount")
local it = test

describe("given a typical main.lua env with handlers", function()
  local originaldraw
  before_each(function()
    _G.love = {}
    love.keypressed = function() end
    originaldraw = spy.new(function() end)
    love.draw = originaldraw
  end)

  after_each(function()
    _G.love = nil
  end)

  describe("when mounting another scene", function()
    before_each(function()
      local function loadfakefile()
        return function() end
      end

      mount(loadfakefile())
    end)

    it("doesn't include previous handlers", function()
      assert.is_nil(love.keypressed)
    end)
  end)

  describe("when mounting two scenes at once", function()
    local result
    local n1, n2
    before_each(function()
      n1 = spy.new(function() end)
      n2 = spy.new(function() end)
      local function loadfakefile(n)
        return function()
          love.draw = n
        end
      end

      mount({ loadfakefile(n1), loadfakefile(n2) })
    end)

    it("loads both scenes' handlers", function()
      love.draw()
      assert.spy(n1).was.called()
      assert.spy(n2).was.called()
    end)
  end)

  describe("when adding an additional scene", function()
    local newdraw
    before_each(function()
      newdraw = spy.new(function() end)
      local function loadfakefile(n)
        return function()
          love.draw = newdraw
        end
      end

      mount({ "current", loadfakefile() })
    end)

    it("keeps both handlers", function()
      love.draw()
      assert.spy(originaldraw).was.called()
      assert.spy(newdraw).was.called()
    end)
  end)
end)

describe("when given an unsupported keyword", function()
  local errmessage
  before_each(function()
    _, errmessage = pcall(function()
      mount("foobar")
    end)
  end)

  it("throws", function()
    assert.is_string(errmessage)
  end)
end)

describe("when given a number", function()
  local errmessage
  before_each(function()
    _, errmessage = pcall(function()
      mount(100)
    end)
  end)

  it("throws", function()
    assert.is_string(errmessage)
  end)
end)

describe("given a blank love environment", function()
  before_each(function()
    _G.love = {}
  end)

  after_each(function()
    _G.love = nil
  end)

  describe("when using mount.bind with arguments", function()
    local tomount
    before_each(function()
      tomount = spy.new()
      mount(mount.bind(tomount, 1, 2, 3))
    end)

    it("binds those parameters when mounting", function()
      assert.spy(tomount).was_called_with(1, 2, 3)
    end)
  end)
end)
