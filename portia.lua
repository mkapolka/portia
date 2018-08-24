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
    for _, component in pairs(Components) do
        if type(component) == "table" and component.static_update then
            component:static_update()
        end
    end
    MOUSE_CLICKED = false
    for key, _ in pairs(KEYS_PRESSED) do
        KEYS_PRESSED[key] = nil
    end
end

function love.draw()
    love.graphics.translate(-CAMERA.x, -CAMERA.y)
    draw_everything()
end

function love.mousepressed(x, y, button)
    MOUSE_CLICKED = true
end

Components.Mouse = Component {
    update = function(self)
        self.x = love.mouse.getX()
        self.y = love.mouse.getY()
        self.down = love.mouse.isDown(1)
        self.up = not love.mouse.isDown(1)
        self.click = MOUSE_CLICKED
    end,
    default_order = -100
}

function set_root(component)
    Root = component
end

KEYS = {}
KEYS_PRESSED = {}

function love.keypressed(key)
    KEYS[key] = true
    KEYS_PRESSED[key] = true
end

function love.keyreleased(key)
    KEYS[key] = false
end

Components.Keyboard = Component {
    update = function(self)
        for name, port in pairs(self.usage.ports) do
            local name = string.gsub(name, "_pressed$", "")
            self[name] = KEYS[name] or false
            self[name.."_pressed"] = KEYS_PRESSED[name] or false
        end
    end
}
