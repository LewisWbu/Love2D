function love.load()
    love.window.setMode(1000,768)

    anim8 = require 'libary/anim8/anim8'
    sti = require 'libary/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libary/hump/camera'

    cam = cameraFile()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playersheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemysheet.png')


    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15',1), 0.05)
    animations.jump = anim8.newAnimation(grid('1-7',2), 0.05)
    animations.run = anim8.newAnimation(grid('1-15',3), 0.05)


    wf = require 'libary/windfield/windfield'
    world = wf.newWorld(0, 1000, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')

    --dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    --dangerZone:setType('static')

    platforms = {}

    loadMap()

    spawnEnemy(960, 320)

end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)

    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight() / 2)
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        world:draw()
        drawPlayer()
    cam:detach()
end

function love.keypressed(key)
    if key == 'space' then 
        if player.grounded then
            player:applyLinearImpulse(0, -5000)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then 
        local colliders = world:queryCircleArea(x, y, 200, {'Danger', 'Platform'})
        for i,c in ipairs(colliders) do 
            c:destroy()
        end
    end
end

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
    local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
    platform:setType('static')
    table.insert(platforms, platform)
    end
end

function loadMap()
    gameMap = sti('maps/level1.lua')
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)

    end
end 