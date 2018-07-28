require "component"

Shaker = Component {
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

Add = Component {
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
Hovering = Component {
    update = function(self)
        self.data = HOVERING_DATA.data
        self.hovering = HOVERING_DATA.hovering
    end
}

Draggable = Component {
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
Text = Component {
    draw = function(self)
        love.graphics.setFont(font)
        love.graphics.print(self.text or "", self.x, self.y, self.r or 0, self.sx or 1, self.sy or 1)
    end
}

Sound = Component {
    start = function(self)
        self.sound = love.audio.newSource(self.file, "static")
        self.sound:play()
    end,
    update = function(self)
        self.done = not self.sound:isPlaying()
    end
}

Timer = Component {
    update = function(self)
        self.time = self.time - love.timer.getDelta()
        self.done = self.time < 0
    end
}

Quit = Component {
    update = function(self)
        if self.done then
            love.event.quit()
        end
    end
}
