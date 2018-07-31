require "portia.component"
require "portia.components"
require "portia.parser"
require "love"

local Root = nil
local root_instance = nil

function love.load()
    root_instance = Root():instantiate()
    root_instance:start()
end

MOUSE_CLICKED = false
function love.update()
    root_instance:update()
    MOUSE_CLICKED = false
end

function love.draw()
    draw_everything()
end

function love.mousepressed(x, y, button)
    MOUSE_CLICKED = true
end

function set_root(component)
    Root = component
end
