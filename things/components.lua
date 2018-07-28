require "component"

Shaker = Component {
    start = function(self)
        self.min = self.min or 0
        self.max = self.max or 1
        self.values = self.values or {"value"}
    end,
    update = function(self)
        local i = 1
        continue = true
        while continue do
            local key = "output"..i
            if self[key] then
                self[key] = self[key] + love.math.random(self.min, self.max)
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

Draggable = Component {
    start = function(self)
        self.x = 0
        self.y = 0
        self.dragged = false
        self.width = 100
        self.height = 100
    end,
    mouseIsIn = function(self)
        return (self.x < love.mouse.getX() and self.x + self.width > love.mouse.getX()
            and self.y < love.mouse.getY() and self.y + self.height > love.mouse.getY())
    end,
    update = function(self)
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
