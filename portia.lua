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

function love.update()
    root_instance:update()
end

function love.draw()
    draw_everything()
end

function set_root(component)
    Root = component
end
