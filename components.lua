require "portia.component"

Components = {}

function get_sprite(name)
    if sprites_db[name] == nil then
        sprites_db[name] = love.graphics.newImage(name)
    end
    return sprites_db[name]
end
sprites_db = {}

Components.Sprite = Component {
    visible = true,
    update = function(self)
        local sprite = get_sprite(self.sprite)
        self.width = sprite:getWidth()
        self.height = sprite:getHeight()
    end,
    draw = function(self)
        love.graphics.draw(get_sprite(self.sprite), self.x, self.y, self.r, 1, 1, self.ox, self.oy)
    end,
}

DRAWABLES = {}

function draw_everything()
    table.sort(DRAWABLES, function(a, b) return -(a.depth or 0) < -(b.depth or 0) end)
    for _, drawable in pairs(DRAWABLES) do
        if drawable.visible then
            drawable:draw()
        end
    end
end

Components.Mouse = Component {
    update = function(self)
        self.x = love.mouse.getX()
        self.y = love.mouse.getY()
    end,
    default_order = -100
}

Components.Shaker = Component {
    start = function(self)
        self.min = self.min or 0
        self.max = self.max or 1
        self.values = self.values or {"value"}
        self.dispositions = {}
    end,
    update = function(self)
        local i = 1
        continue = true
        while continue do
            local key = "output"..i
            if self[key] then
                local dispo = self.dispositions[key] or 0
                local r = love.math.random(self.min - dispo, self.max - dispo)
                self.dispositions[key] = dispo + r
                self[key] = self[key] + r
            else
                continue = false
            end
            i = i + 1
        end
    end
}

Components.Add = Component {
    start = function(self)
        self.a = 0
        self.b = 0
    end,
    update = function(self)
        a = self.a or 0
        b = self.b or 0
        self.value = a + b
    end
}

HOVERING_DATA = {}
Components.Hovering = Component {
    update = function(self)
        self.data = HOVERING_DATA.data
        self.hovering = HOVERING_DATA.hovering
    end
}

Components.Draggable = Component {
    start = function(self)
        self.dragged = false
        self.hovering = false
        self.width = 100
        self.height = 100
    end,
    mouseIsIn = function(self)
        return (self.x < love.mouse.getX() and self.x + self.width > love.mouse.getX()
            and self.y < love.mouse.getY() and self.y + self.height > love.mouse.getY())
    end,
    update = function(self)
        if self:mouseIsIn() then
            self.hovering = true
            HOVERING_DATA.data = self.data
            HOVERING_DATA.hovering = true
        elseif self.hovering then
            self.hovering = false
            HOVERING_DATA.data = nil
            HOVERING_DATA.hovering = false
        end

        if love.mouse.isDown(1) and self:mouseIsIn() and not self.dragged then
            self.dragged = true
            self.offsetx = self.x - love.mouse.getX()
            self.offsety = self.y - love.mouse.getY()
        end
        if self.dragged then
            self.x = love.mouse.getX() + self.offsetx
            self.y = love.mouse.getY() + self.offsety
        end
        if not love.mouse.isDown(1) and self.dragged then
            self.dragged = false
        end
    end
}

font = love.graphics.newFont(32)
Components.Text = Component {
    draw = function(self)
        love.graphics.setFont(font)
        love.graphics.print(self.text or "", self.x, self.y, self.r or 0, self.sx or 1, self.sy or 1)
    end
}

Components.Sound = Component {
    start = function(self)
        self.sound = love.audio.newSource(self.file, "static")
        self.sound:play()
    end,
    update = function(self)
        self.done = not self.sound:isPlaying()
    end
}

Components.Timer = Component {
    update = function(self)
        self.time = self.time - love.timer.getDelta()
        self.done = self.time < 0
    end
}

Components.Quit = Component {
    update = function(self)
        if self.done then
            love.event.quit()
        end
    end
}

Components.DistanceFrom = Component {
    update = function(self)
        local dx = self.x1 - self.x2
        local dy = self.y1 - self.y2
        self.distance = math.sqrt(dx * dx + dy * dy)
    end
}

Components.Spawner = function(ports)
    local class = ports.class
    ports.class = nil
    local output = {
        child_usage = Components[class](ports)
    }
end
