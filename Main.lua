-- PossiblyAxolotl
-- Created August 31th, 2022
-- Rocket Bytes Minus

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/math"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "Particles"
import "Player"
import "Map"
import "Menu"
import "Saws"

mode = "menu"

deaths = 0
energy = 0
totalEnergy = 0

local gfx <const> = playdate.graphics

local font <const> = gfx.font.new("gfx/big")
gfx.setFont(font)

gfx.setBackgroundColor(gfx.kColorBlack)

local imgSkull = gfx.image.new("gfx/skullEmoji")
local imgLightning = gfx.image.new("gfx/lightning")
assert(imgSkull)
assert(imgLightning)

gfx.setColor(gfx.kColorWhite)

local menu = playdate.getSystemMenu()
menuButton, error = menu:addMenuItem("game menu", function()

    killPlayer()
    removeMap()
    killBlades()

    totalEnergy = 0
    showEnergy = false
    energy = 0

    levelMenuLoad()
end)

levelMenuLoad() -- from menu.lua

playdate.ui.crankIndicator:start()

function playdate.update()
    if mode == "menu" then
        updateMenu()
        processExplosions()
    elseif mode == "game" or mode == "play" then
        updatePlayer()
        gfx.sprite.update()
        processStars(sprRocket.x-210,sprRocket.y-130)
        processExplosions()
        
        local ox, oy = gfx.getDrawOffset()
        imgSkull:draw(-ox + 1, -oy + 2)
        gfx.drawText(deaths,-ox + 20,-oy + 2)
        if totalEnergy > 0 then
            imgLightning:draw(-ox + 1, -oy + 20)
            gfx.drawText(energy.."/"..totalEnergy,-ox + 20,-oy + 20)
        end
        
        if playdate.isCrankDocked() then
            playdate.ui.crankIndicator:update()
        end
    end

    updateSaws()
end