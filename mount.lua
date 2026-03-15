local function sanitycheck(...)
  local toload = { ... }
  for n = 1, #toload do
    local loadable = toload[n]
    local t = type(loadable)
    if t == "nil" and type(toload[n + 1]) == "string" then
      local err = toload[n + 1]
      local msg = string.format('expected non-nil at position %s, got: %s and "%s"', n, t, err)
      error(msg)
    end

    if t == "string" and loadable ~= "current" then
      error('expected function or string "current", got: ' .. tostring(loadable))
    end

    if t ~= "string" and t ~= "function" then
      error('expected function or string "current", got: ' .. tostring(loadable))
    end
  end
end

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

local function mount(...)
  sanitycheck(...)
  local current = unmount()

  local toload = { ... }
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

return mount
