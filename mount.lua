local handlers = {
  "draw",
  -- "errhand", -- do not capture errors
  -- "errorhandler", -- do not capture errors
  "load",
  "lowmemory",
  "quit",
  -- "run",
  -- "threaderror", -- do not capture errors
  "update",
  "directorydropped",
  "displayrotated",
  "filedropped",
  "focus",
  "mousefocus",
  "resize",
  "visible",
  "keypressed",
  "keyreleased",
  "textedited",
  "textinput",
  "mousemoved",
  "mousepressed",
  "mousereleased",
  "wheelmoved",
  "gamepadaxis",
  "gamepadpressed",
  "gamepadreleased",
  "joystickadded",
  "joystickaxis",
  "joystickhat",
  "joystickpressed",
  "joystickreleased",
  "joystickremoved",
  "touchmoved",
  "touchpressed",
  "touchreleased"
}

local function unmount()
  local current = {}
  for _, key in ipairs(handlers) do
    current[key] = love[key]
    love[key] = nil
  end
  return current
end

local mount = {}

function mount.bind(f, ...)
  local args = { ... }
  return function()
    return f(unpack(args))
  end
end

function mount.mount(toload)
  if type(toload) == "function" or #toload == 0 then
    toload = { toload }
  end

  local current = unmount()

  local handlers = {}
  for _, loadable in ipairs(toload) do
    local h
    if loadable == "current" then
      h = current
    else
      loadable()
      h = unmount()
    end

    for handler, f in pairs(h) do
      if handlers[handler] == nil then
        handlers[handler] = {}
      end

      table.insert(handlers[handler], f)
    end
  end

  for handler, callbacks in pairs(handlers) do
    if #callbacks == 1 then
      love[handler] = callbacks[1]
    else
      love[handler] = function(...)
        for _, f in ipairs(callbacks) do
          f(...)
        end
      end
    end
  end
end

local metatable = {
  __call = function(_, ...)
    return mount.mount(...)
  end
}
setmetatable(mount, metatable)

return mount
