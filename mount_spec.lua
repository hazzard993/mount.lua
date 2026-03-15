local mount = require("mount")
local it = test

describe("given a typical main.lua env with handlers", function()
  local originalpressed
  local originaldraw
  before_each(function()
    _G.love = {}
    originalpressed = spy.new(function() end)
    love.keypressed = originalpressed
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

    it("includes previous handlers", function()
      love.keypressed()
      assert.spy(originalpressed).was.called()
    end)
  end)

  describe("when mounting another scene with .only", function()
    local newpressed
    before_each(function()
      newpressed = spy.new(function() end)
      local function loadfakefile()
        return function()
          love.keypressed = newpressed
        end
      end

      mount.only(loadfakefile())
    end)

    it("doesn't include previous handlers", function()
      love.keypressed()
      assert.spy(originalpressed).was.not_called()
      assert.spy(newpressed).was.called()
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

      mount(loadfakefile(n1), loadfakefile(n2))
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

      mount(loadfakefile())
    end)

    it("keeps both handlers", function()
      love.draw()
      assert.spy(originaldraw).was.called()
      assert.spy(newdraw).was.called()
    end)
  end)
end)

describe("when loading a file that doesn't exist", function()
  local err
  before_each(function()
    local function loadfilefail()
      return nil, "cannot open foo/bar.lua: No such file or directory"
    end

    _, err = pcall(function()
      mount(loadfilefail())
    end)
  end)

  it("identifies the load failure", function()
    local expected = "cannot open foo/bar.lua: No such file or directory"
    local matches = string.find(err, expected) ~= nil
    assert.is_true(matches, 'expected string containing "' .. expected .. '", got: ' .. err)
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
