local gfx <const> = playdate.graphics
local controlY = 0
local controlX = 0

local index = 0

local menuitems = {}
local menu = nil
page = 0

local imgCursor = gfx.image.new("gfx/cursor")
assert(imgCursor)

function createMenu(items, invert)

    playdate.display.setInverted(false)

    controlX = -80

    index = 0.5
    menuitems = {}
    local _y =220 
    menu = items[0]
    for i=1, #items, 1 do
        menuitems[i] = {name=items[i],y=_y}
        _y -= 20
    end

    mode = "menu"
end

function updateMenu()
    gfx.clear(gfx.kColorBlack)
    processStars(-10,-10)

    -- input 
    local change, aChange = playdate.getCrankChange()

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        index -= 1
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        index += 1
    end

    index += change * 0.01

    if math.floor(index) < 0 then index = #menuitems -0.01 end
    if math.floor(index) > #menuitems - 1 then index = 0 end

    controlX = playdate.math.lerp(controlX, 20, 0.3)
    controlY = playdate.math.lerp(controlY, (20 * math.floor(index)) - 1, 0.5)

    for i = 1, #menuitems, 1 do
        local item = menuitems[i]
        if item.name:match("(.+)%..+$") then
            gfx.drawText(item.name:match("(.+)%..+$"),controlX,item.y)
        else
            gfx.drawText(item.name,controlX,item.y)
        end
    end
    imgCursor:draw(controlX - 17,controlY + (243 - (20 * #menuitems)))

    if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonRight) then
        menuButtonPress(menuitems[#menuitems - math.floor(index)].name,#menuitems - math.floor(index))
    elseif playdate.buttonJustPressed(playdate.kButtonB) or playdate.buttonJustPressed(playdate.kButtonLeft) then
        menuButtonPress("BACK")
    end
end

function levelMenuLoad()
    local lvls = playdate.file.listFiles("levels")
    local m = {}
    m[0] = "levels"
    if #lvls - ((11*page)) <= 0 then page = 0 end
    if #lvls <= 12 then
        for i = 1, #lvls, 1 do
            m[i+1] = lvls[i]:upper()
        end
    elseif lvls[1 + (11*page)] then
        m[1] = "NEXT PAGE"
        for i = 1, 11, 1 do
            if lvls[i+(11*page)] then
                m[i+1] = lvls[i+(11*page)]:upper()
            end
        end
    end

    createMenu(m)
end

function menuButtonPress(name, index)

    miniExplode(controlX - 17 ,controlY + (243 - (20 * #menuitems)))

    if name == "NEXT PAGE" then
        page += 1
        levelMenuLoad()
        
    elseif menu == "levels" then
        addMap("levels/"..name, true)
        mode = "play"
    end
end