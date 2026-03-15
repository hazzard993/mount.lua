function love.keypressed(key)
  if key == "space" then
    error("something")
  end
end

function love.draw()
  love.graphics.print("hello scene b", 400, 316)
end
