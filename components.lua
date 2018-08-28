Components = {}

require "portia.component"
require "portia.components.drawables"
require "portia.components.beacons"
require "portia.components.logic"
require "portia.components.physics"
require "portia.components.containers"

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

Components.Clickable = Component {
    mouseIsIn = function(self)
        return (self.x < love.mouse.getX() and self.x + self.width > love.mouse.getX()
            and self.y < love.mouse.getY() and self.y + self.height > love.mouse.getY())
    end,
    update = function(self)
        self.click = 0
        if self:mouseIsIn() then
            self.hovering = true
            HOVERING_DATA.data = self.data
            HOVERING_DATA.hovering = true
        elseif self.hovering then
            self.hovering = false
            HOVERING_DATA.data = nil
            HOVERING_DATA.hovering = false
        end

        if love.mouse.isDown(1) and self:mouseIsIn() then
            self.click = 1
            self.down = true
        end

        if not love.mouse.isDown(1) then
            self.down = false
        end

        self.up = not self.down
    end
}

Components.Sound = Component {
    start = function(self)
        self.sound = love.audio.newSource(self.file, "static")
        if not self.usage.ports.play then
            self.sound:play()
        end
    end,
    update = function(self)
        if self.play and self.play > 0 then
            self.sound:stop()
            self.sound:play()
        end

        self.done = not self.sound:isPlaying()
    end
}

Components.Tween = Component {
    defaults = {
        from = 0, to = 1,
        when = false, time = 1,
        value = 0, _t = 0
    },
    update = function(self)
        if self.when then
            self.when = false
            self.value = self.from
            self._t = 1
        end

        if self._t > 0 then
            self._t = self._t - love.timer.getDelta() / self.time
            self.value = self.from + (self.to - self.from) * (1 - self._t)
        end
    end
}

Components.Quit = Component {
    update = function(self)
        if self.done then
            love.event.quit()
        end
    end
}

Components.Movable = Component {
    defaults = {
        x = 0, y = 0,
        vx = 0, vy = 0,
        ax = 0, ay = 0,
    },
    update = function(self)
        self.vx = self.vx + self.ax
        self.vy = self.vy + self.ay
        self.x = self.x + self.vx
        self.y = self.y + self.vy
    end
}

Components.ArrowMover = Component {
    defaults = {
        horizontal = 0, vertical = 0,
        speed = 1,
        up = 0, down = 0, left = 0, right = 0,
        enabled = true
    },
    update = function(self)
        if not self.enabled then
            return
        end

        if self.up and self.down then
            self.vertical = 0
        elseif self.up then
            self.vertical = -self.speed
        elseif self.down then
            self.vertical = self.speed
        else
            self.vertical = 0
        end

        if self.right and self.left then
            self.horizontal = 0
        elseif self.right then
            self.horizontal = self.speed
        elseif self.left then
            self.horizontal = -self.speed
        else
            self.horizontal = 0
        end
    end
}

Components.LoopWithin = Component {
    defaults = {
        x = 0, y = 0,
        bx = 0, by = 0,
        width = 800, height = 600,
        loop_x = true, loop_y = true
    },
    update = function(self)
        if self.loop_x then
            if self.x < self.bx then
                self.x = self.x + self.width
            end

            if self.x > self.bx + self.width then
                self.x = self.x - self.width
            end
        end

        if self.loop_y then
            if self.y < self.by then
                self.y = self.y + self.width
            end

            if self.y > self.by + self.width then
                self.y = self.y - self.width
            end
        end
    end
}
