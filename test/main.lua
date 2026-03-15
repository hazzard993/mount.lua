local mount = require("mount")

local additional = false
function love.keypressed(key)
  if key == "1" then
    mount(loadfile("test/scene/main.lua"))
  end

  if key == "2" then
    mount(
      loadfile("test/scene_a/main.lua"),
      loadfile("test/scene_b/main.lua")
    )
  end

  if key == "3" and not additional then
    mount(
      "current",
      loadfile("test/additional/main.lua")
    )

    additional = true
  end
end

function love.draw()
  love.graphics.print("hello world", 400, 300)
  love.graphics.print("press 1 to load a new scene", 400, 316)
  love.graphics.print("press 2 to load 2 scenes at once", 400, 332)
  love.graphics.print("press 3 to load 1 additional scene", 400, 348)
end
