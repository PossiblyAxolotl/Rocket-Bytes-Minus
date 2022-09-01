local velocity = {x=0,y=0}
local lerpmnt <const> = 0.5
grav = 0.2
local dead = false

local exists = false
local active = false
local gfx <const> = playdate.graphics
local imgRocket = gfx.image.new("gfx/rocket")
local imgFire = gfx.imagetable.new("gfx/fire")
assert(imgRocket)
sprRocket = gfx.sprite.new(imgRocket)
local loopFire = gfx.animation.loop.new(200,imgFire)
sprRocket:setCollideRect(9, 9, 10, 10)
local startpos = {x=0,y=0}
sprRocket:setGroups({1,2,3})

local imgBigRocket = gfx.image.new("gfx/bigrocket")
local imgBigFire = gfx.imagetable.new("gfx/bigrocketfire")
local imgSpawn = gfx.image.new("gfx/spawn")
assert(imgBigRocket)
assert(imgBigFire)
assert(imgSpawn)
local loopBigFire = gfx.animation.loop.new(200,imgBigFire)
local sprBigRocket = gfx.sprite.new(imgBigRocket)
local sprSpawn = gfx.sprite.new(imgSpawn)
sprBigRocket:setCollideRect(0,0,64,64)
sprBigRocket:setGroups({2})
sprBigRocket:setCollidesWithGroups({2})

local resetButton = nil

local sfxDie = playdate.sound.sampleplayer.new("sfx/die")

function setSpawn(_x,_y)
    startpos = {x=_x,y=_y}
    miniExplode(sprSpawn.x,sprSpawn.y)
    sprSpawn:moveTo(_x,_y)
end

local function die()
    deaths +=1
    explode(sprRocket.x,sprRocket.y)
    active = false
    velocity = {x=0,y=0}
    sprRocket:moveTo(startpos.x, startpos.y) 
    miniExplode(startpos.x,startpos.y)
end

function addPlayer(_x,_y,__x,__y)
    exists = true
    dead = false
    active = false

    sprSpawn:moveTo(_x,_y)
    sprSpawn:add()

    velocity = {x=0,y=0}
    startpos = {x= _x,y=_y}

    sprBigRocket:moveTo(__x,__y)
    sprBigRocket:setImage(imgBigRocket)
    sprBigRocket:add()

    sprRocket:moveTo(_x,_y)
    sprRocket:add()
    sprRocket:setVisible(true)

    resetButton = playdate.getSystemMenu():addMenuItem("respawn", function()
        die()
    end)
end

function killPlayer()
    exists = false
    active = false
    gfx.setDrawOffset(0,0)

    if resetButton ~= nil then playdate.getSystemMenu():removeMenuItem(resetButton) end
    
    resetButton = nil
end

function updatePlayer()
    playdate.timer.updateTimers()
    sprRocket:setImage(imgRocket)

    -- is there a better way to detect any button press? idk.
    local inp = (playdate.buttonIsPressed(playdate.kButtonUp) or playdate.buttonIsPressed(playdate.kButtonDown) or playdate.buttonIsPressed(playdate.kButtonLeft) or playdate.buttonIsPressed(playdate.kButtonRight) or playdate.buttonIsPressed(playdate.kButtonA) or playdate.buttonIsPressed(playdate.kButtonB))
    
    if active then
        if inp then
            velocity.x = velocity.x + math.sin(math.rad(playdate.getCrankPosition())) /2
            velocity.y = velocity.y - math.cos(math.rad(playdate.getCrankPosition())) /2
        end
        sprRocket:moveBy(velocity.x,velocity.y)

        local cx, cy = gfx.getDrawOffset()
        gfx.setDrawOffset(playdate.math.lerp(cx,(-sprRocket.x + 200), lerpmnt), playdate.math.lerp(cy,(-sprRocket.y + 120), lerpmnt))

        sprRocket:setRotation(0)
        sprRocket:update()
        --print(#sprRocket:overlappingSprites())

        velocity.y += grav
        
        if #sprRocket:overlappingSprites() > 0 then 
            die()
        end

    elseif exists then
        if (playdate.buttonJustPressed(playdate.kButtonUp) or playdate.buttonJustPressed(playdate.kButtonDown) or playdate.buttonJustPressed(playdate.kButtonLeft) or playdate.buttonJustPressed(playdate.kButtonRight) or playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB)) and playdate.isCrankDocked() == false then
            active = true
        end
        local cx, cy = gfx.getDrawOffset()
        gfx.setDrawOffset(playdate.math.lerp(cx,(-sprRocket.x + 200), lerpmnt), playdate.math.lerp(cy,(-sprRocket.y + 120), lerpmnt))
    end

    checkWin()

    sprRocket:setRotation(playdate.getCrankPosition())

    if active and inp then
        sprRocket:setImage(loopFire:image())
    end
end

function checkWin()
    if #sprBigRocket:overlappingSprites() > 0 and energy == totalEnergy then
        totalEnergy = 0
        showEnergy = false
        energy = 0
    
        killPlayer()
        removeMap()
        killBlades()
    
        levelMenuLoad()
    end
end

