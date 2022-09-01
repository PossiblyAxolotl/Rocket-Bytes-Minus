local gfx <const> = playdate.graphics
local tileTable <const> = gfx.imagetable.new("gfx/tiles")
local tilemap <const> = gfx.tilemap.new()
tilemap:setImageTable(tileTable)
local tiles = {}

local sprTiles = gfx.sprite.new(tilemap)

function addMap(_file, rs)
    killBlades()
    killPlayer()
    removeMap()

    deaths = 0
    local level = json.decodeFile(_file)
    local width = 0
    local height = 0

    for i = 1, #level.tiles, 1 do
        if level.tiles[i].x > width then width = level.tiles[i].x end
        if level.tiles[i].y > height then height = level.tiles[i].y end
    end

    tilemap:setSize(width,height)
    
    for i = 1, #level.tiles, 1 do
        tilemap:setTileAtPosition(level.tiles[i].x,level.tiles[i].y,level.tiles[i].t)
    end

    tiles = gfx.sprite.addWallSprites(tilemap, {0,1,7,8,9,10,11,12,13,14,15,16})

    if level.inverted then playdate.display.setInverted(true) else playdate.display.setInverted(false) end
    if level.saws then loadBlades(level.saws) end
    if level.rotators then loadSpins(level.rotators) end
    if level.checks then loadChecks(level.checks) end
    if level.fuel then loadFuel(level.fuel) end
    grav = level.grav or 0.2
    level.next = level.next or nil

    addPlayer(level.rocket.x+14,level.rocket.y+15, level.bigrocket.x+32, level.bigrocket.y+32)

    sprTiles = gfx.sprite.new(tilemap)
    sprTiles:setZIndex(-1)
    sprTiles:moveTo(sprTiles.width/2,sprTiles.height/2)
    sprTiles:add()
end

function removeMap()
    if #tiles > 0 then
        for i = 1, #tiles, 1 do
            tiles[i]:remove()
        end
    end
    sprTiles:remove()
end