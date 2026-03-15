# mount.lua

For breaking up callbacks into scenes/entities. for LÖVE 2D.

## What does this do?

Here's a callback for draw.

```lua
-- start with a hello world
function love.draw()
  love.graphics.print("hello world")
end

-- then... added a pause menu
function love.draw()
  if paused then
    love.graphics.print("paused")
  else
    love.graphics.print("hello world")
  end
end
```

As more visuals are added, **draw** (or a system that it uses) gets more complicated.

_mount.lua_ allows you to organize that logic into other files.

```lua
-- main.lua
function love.draw()
  love.graphics.print("hello world", 400, 300)
end

-- pause.lua
function love.draw()
  love.graphics.print("paused", 400, 300)
end
```

Which you can switch between.

```lua
local pause = loadfile("pause.lua")

function love.keypressed(key)
  if key == "1" then
    mount(pause)
  end
end
-- (this would also be in main.lua)
```

So here, one or the other is being run, not both.

They also look a lot like regular _main.lua_ files with nothing going on.

## How is it used?

Copy over and import _mount.lua_.

### One scene to another

```lua
local mount = require("mount")
local scene = loadfile("scene.lua")
mount(scene)
```

|        | main.lua   | scene.lua  |
| ------ | ---------- | ---------- |
| before | ✓          | not loaded |
| after  | not loaded | ✓          |

e.g. Switching from pause menu to gameplay, switching between menus, switching from one world environment to another.

### Mount two scenes at once

```lua
local scene1 = loadfile("scene1.lua")
local scene2 = loadfile("scene2.lua")
mount(scene1, scene2)
```

|        | main.lua   | scene1.lua | scene1.lua |
| ------ | ---------- | ---------- | ---------- |
| before | ✓          | not loaded | not loaded |
| after  | not loaded | ✓          | ✓          |

e.g. Loading in a terrain manager and player control system.

### Mount an additional scene, keep the current one

```lua
local scene = loadfile("scene.lua")
mount("current", scene)
```

|        | main.lua | scene.lua  |
| ------ | -------- | ---------- |
| before | ✓        | not loaded |
| after  | ✓        | ✓          |

e.g. Layering in a weather effect system to the current world.

## Trying it out

Clone the repo, run LÖVE 2D on the test directory.

```sh
git clone git@github.com:hazzard993/mount.lua.git
love test
```
