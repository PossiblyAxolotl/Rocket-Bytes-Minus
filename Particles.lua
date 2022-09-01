local gfx <const> = playdate.graphics

math.randomseed(playdate.getSecondsSinceEpoch())

local exps = {}

local stars = {}

function createStars()
    stars = {}
    for _i = 1, 30, 1 do
        stars[#stars+1] = {x=math.random(0,400),y=math.random(0,240),dx=math.random(-1.0,1.0)*0.5,dy=math.random(-1.0,1.0)*0.5,size=math.random(2,4)}
    end
    
    for star = 1, #stars do
        star = stars[star]

        -- lazier than respinning or smth but it works and doesn't ruin the visual
        if star.dx == 0 then star.dx = 0.2 end
            if star.dy == 0 then star.dy = 0.2 end
    end
end

createStars()

function explode(_x,_y)
    for i = 1, 10, 1 do
        local part = {
            x = _x,
            y = _y,
            dir = math.random(0,359),
            size = math.random(10,15),
            speed = math.random(1,3)
        }
        exps[#exps+1] = part
    end
end

function miniExplode(_x,_y)
    for i = 1, 6, 1 do
        local part = {
            x = _x,
            y = _y,
            dir = math.random(0,359),
            size = math.random(7,10),
            speed = math.random(1,3)
        }
        exps[#exps+1] = part
    end
end

function processStars(_x,_y)
    gfx.setColor(gfx.kColorWhite)
    for star = 1, #stars do
        star = stars[star]
        star.x += star.dx
        star.y += star.dy

        gfx.fillRect(star.x,star.y,star.size,star.size)
        
        if star.x < _x then
            star.x += 420
        elseif star.x > _x + 420 then
            star.x -= 420
        end

        if star.y < _y then
            star.y += 260
        elseif star.y > _y + 260 then
            star.y -= 260
        end
    end
end

function processExplosions()
    gfx.setColor(gfx.kColorWhite)
    for part = 1, #exps do
        local particle = exps[part]

        particle.x += math.sin(particle.dir) * particle.speed
        particle.y -= math.cos(particle.dir) * particle.speed
        gfx.fillCircleAtPoint(particle.x,particle.y,particle.size)
        exps[part].size -= .3

        if exps[part].size < 0 then exps[part].size = 0 end
    end

    for part = 1, #exps do
        if exps[part].size <= 0.1 then
            table.remove(exps, part)
            break
        end
    end
end