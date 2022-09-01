local gfx <const> = playdate.graphics

local imgSaw = gfx.imagetable.new("gfx/sawblades")
local imgFuel = gfx.imagetable.new("gfx/fuel")
local imgTarget = gfx.image.new("gfx/target")
local imgCheck = gfx.imagetable.new("gfx/checkpoint")
assert(imgSaw)
assert(imgFuel)
assert(imgTarget)
assert(imgCheck)

local loopSaws = gfx.animation.loop.new(200, imgSaw)
local loopFuel = gfx.animation.loop.new(400, imgFuel)
local loopCheck = gfx.animation.loop.new(300, imgCheck)

local blades = {}
local spinblades = {}
local fuels = {}
local checks = {}

function loadBlades(_blades)
    for i = 1, #_blades,1 do
        local b = _blades[i]
        b.start = playdate.geometry.point.new(b.start.x+8,b.start.y+8)
        b.ends = playdate.geometry.point.new(b.ends.x+8,b.ends.y+8)
        b.saw = gfx.sprite.new(loopSaws:image())
        b.saw:moveTo(b.start)
        b.saw:setZIndex(1)
        b.saw:setCollideRect(0,0,16,16)
        b.saw:add()

        b.t1 = gfx.sprite.new(imgTarget)
        b.t1:moveTo(b.start)
        b.t2 = gfx.sprite.new(imgTarget)
        b.t2:moveTo(b.ends)
        b.t1:add()
        b.t2:add()
        blades[i] = b
    end
end

function loadSpins(_spins)
    for i = 1, #_spins, 1 do
        local s = _spins[i]
        s.x+= 8
        s.y+= 8

        s.middle = gfx.sprite.new(loopSaws:image())
        s.middle:setCollideRect(0,0,16,16)

        s.middle:moveTo(s.x,s.y)
        s.middle:setZIndex(1)
        s.middle:add()

        --local sb = {speed=s.speed,arms={},mid=s.middle,time=0}
        local sb = {speed=s.speed,layers={},time=0,mid=s.middle}

        for len = 1, s.armlen, 1 do
            local arc = playdate.geometry.arc.new(s.x,s.y, 20 * len, -720, 720)

            sb.layers[#sb.layers+1] = {curve=arc,saws={}}
            
            for arm = 1, s.arms, 1 do
                local saw = gfx.sprite.new(loopSaws:image())
                local sawPos = arc:pointOnArc(360 / s.arms * arm)

                saw:moveTo(sawPos.x,sawPos.y)
                saw:setCollideRect(0,0,16,16)
                saw:setZIndex(1)
                saw:add()

                sb.layers[#sb.layers].saws[#sb.layers[#sb.layers].saws+1] = saw
            end
        end

        spinblades[#spinblades+1] = sb

        
        --[[for i = 1, s.arms, 1 do
            sb.arms[i] = {}
            for p = 1, s.armlen, 1 do
                local degrees =  (360 / s.arms) * i
                local position = {x=math.sin(math.rad(degrees)) * 20 * p,y=math.cos(math.rad(degrees)) * 20 * p}

                sb.arms[i][p] = gfx.sprite.new(loopSaws:image())
                sb.arms[i][p]:moveTo(s.x + position.x, s.y + position.y)
                sb.arms[i][p]:setCollideRect(0,0,16,16)
                sb.arms[i][p]:setZIndex(1)
                sb.arms[i][p]:add()
            end
        end
        spinblades[#spinblades+1] = sb]]
    end
end

function loadFuel(_fuel)

    for i = 1, #_fuel, 1 do
        local fuel = _fuel[i]
        fuels[i] = gfx.sprite.new()
        fuels[i]:moveTo(fuel.x+15,fuel.y+15)
        fuels[i]:setGroups({2})
        fuels[i]:setCollidesWithGroups({3})
        fuels[i].active = true
        fuels[i]:setZIndex(2)
        fuels[i]:setCollideRect(-6,-6 ,30,30)
        fuels[i]:add()

        totalEnergy += 1
    end
end

function loadChecks(_checks)

    for i = 1, #_checks, 1 do
        local check = _checks[i]
        checks[i] = gfx.sprite.new()
        checks[i].set = false
        checks[i]:moveTo(check.x+16,check.y+16)
        checks[i]:setGroups({2})
        checks[i]:setCollidesWithGroups({3})
        checks[i]:setZIndex(3)
        checks[i]:setCollideRect(-3,-3 ,38,38)
        checks[i]:add()
    end
end

function updateSaws()
    local ox, oy = gfx.getDrawOffset()
    for fuel = 1, #fuels, 1 do
        fuels[fuel]:setImage(loopFuel:image())
        if #fuels[fuel]:overlappingSprites() > 0 and fuels[fuel].active then
            fuels[fuel].active = false
            miniExplode(fuels[fuel].x,fuels[fuel].y)
            fuels[fuel]:remove()
            energy += 1
            table.remove(fuels,fuel)
            break
        end
    end

    for check = 1, #checks, 1 do
        checks[check]:setImage(loopCheck:image())
        if #checks[check]:overlappingSprites() > 0 and checks[check].set == false then
            for check = 1, #checks, 1 do
                checks[check].set = false
            end
            setSpawn(checks[check].x,checks[check].y)
            miniExplode(checks[check].x,checks[check].y)
            checks[check].set = true
            break
        end
    end

    for b=1, #blades, 1 do
        b = blades[b]
        b.saw:setImage(loopSaws:image())
        local pos = playdate.geometry.point.new(b.saw:getPosition())

        if pos == b.start then
            local a = gfx.animator.new(b.speed*1000, b.start, b.ends)
            a.reverses = true

            b.saw:setAnimator(a)
        end
    end

    for spinner = 1, #spinblades, 1 do
        local s = spinblades[spinner]

        s.time += s.speed

        for len = 1, #s.layers, 1 do
            local arc = s.layers[len].curve

            for arm = 1, #s.layers[len].saws, 1 do
                if s.time > arc:length() / 4 or s.time < -arc:length() / 4  then s.time = 0 end
                if s.speed > 0 then
                    local sawPos = arc:pointOnArc(arc:length() / 4 / #s.layers[len].saws * arm + (s.time * len))

                    s.layers[len].saws[arm]:moveTo(sawPos.x,sawPos.y)
                else
                    local sawPos = arc:pointOnArc(arc:length() / 4 / #s.layers[len].saws * arm + (-s.time * len))

                    s.layers[len].saws[arm]:moveTo(s.mid.x -(s.mid.y - sawPos.y) ,s.mid.y -(s.mid.x - sawPos.x))
                end
            end
        end
    end
end

function killBlades()
    for fuel = 1, #fuels, 1 do
        fuels[fuel]:remove()
    end
    fuels = {}

    for check = 1, #checks, 1 do
        checks[check]:remove()
    end
    checks = {}

    for i = 1, #blades, 1 do
        blades[i].t1:remove()
        blades[i].t2:remove()
        blades[i].saw:remove()
    end
    blades = {}

    for i = 1, #spinblades, 1 do
        spinblades[i].mid:remove()
        for layer = 1, #spinblades[i].layers do
            for blade = 1, #spinblades[i].layers[layer].saws do
                spinblades[i].layers[layer].saws[blade]:remove()
            end
        end
    end

    spinblades = {}
end