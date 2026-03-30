local mount = require("mount")

it = test

describe("given an empty love environment", function()
  before_each(function()
    _G.love = {}
  end)

  after_each(function()
    _G.love = nil
  end)

  describe("when a scene is mounted with draw function a", function()
    local draw
    before_each(function()
      function draw() end

      local function scene()
        love.draw = draw
      end

      mount({ scene })
    end)

    it("uses draw function a", function()
      assert.is_equal(love.draw, draw)
    end)
  end)

  describe("when a scene has been mounted with draw function a and b", function()
    local draw1, draw2
    before_each(function()
      function draw1() end

      function draw2() end

      local function a()
        love.draw = draw1
      end

      local function b()
        love.draw = draw2
      end

      mount({ a, b })
    end)

    it("can have those function values retrieved", function()
      local name, value = debug.getupvalue(love.draw, 2)
      assert.is_equal(name, "callbacks")
      assert.same({ draw1, draw2 }, value)
    end)

    describe("and then adding draw function c and d", function()
      local draw3, draw4
      before_each(function()
        function draw3() end

        function draw4() end

        local function c()
          love.draw = draw3
        end

        local function d()
          love.draw = draw4
        end

        mount({ "current", c, d })
      end)

      it("will call draw functions a, b, c, and d", function()
        local _, value = debug.getupvalue(love.draw, 2)
        assert.same({ draw1, draw2, draw3, draw4 }, value)
      end)
    end)

    describe("and then adding draw function c and d to the end", function()
      local draw3, draw4
      before_each(function()
        function draw3() end

        function draw4() end

        local function c()
          love.draw = draw3
        end

        local function d()
          love.draw = draw4
        end

        mount({ c, d, "current" })
      end)

      it("will call draw functions c, d, a, and b", function()
        local _, value = debug.getupvalue(love.draw, 2)
        assert.same({ draw3, draw4, draw1, draw2 }, value)
      end)
    end)
  end)
end)
