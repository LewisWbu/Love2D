message = 0
test = 0 

while message <100 do 
    test = test - 5 
end

function love.draw()
    love.graphics.setFont(love.graphics.newFont(80))
    love.graphics.print(test)
end