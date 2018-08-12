require "portia.component"
local sti = require "sti"

Components = {}

function get_sprite(name)
    if sprites_db[name] == nil then
        sprites_db[name] = love.graphics.newImage(name)
    end
    return sprites_db[name]
end
sprites_db = {}

Drawable = function(idx)
    idx.oninstantiate = function(self)
        self._id = new_id()
        table.insert(DRAWABLES, self)
    end
    idx.destroy = function(self)
        for i, drawable in ipairs(DRAWABLES) do
            if drawable._id == self._id then
                table.remove(DRAWABLES, i)
            end
        end
    end
    return Component(idx)
end

CAMERA = {
    x = 0,
    y = 0
}

Components.CameraWrite = Component {
    update = function(self)
        CAMERA.x = self.x
        CAMERA.y = self.y
    end
}

Components.CameraCenter = Component {
    update = function(self)
        CAMERA.x = self.x - love.graphics.getWidth() / 2
        CAMERA.y = self.y - love.graphics.getHeight() / 2
    end
}

Components.Camera = Component {
    update = function(self)
        self.x = CAMERA.x
        self.y = CAMERA.y
    end
}

Components.Sprite = Drawable {
    visible = true,
    defaults = {
        x = 0, y = 0, width = 0, height = 0,
        ox = 0, oy = 0, r = 0
    },
    update = function(self)
        local sprite = get_sprite(self.sprite)
        self.width = sprite:getWidth()
        self.height = sprite:getHeight()
    end,
    draw = function(self)
        love.graphics.draw(get_sprite(self.sprite), self.x, self.y, self.r, 1, 1, self.ox, self.oy)
    end,
}

font = love.graphics.newFont(32)
Components.Text = Drawable {
    draw = function(self)
        love.graphics.setFont(font)
        love.graphics.print(self.text or "", self.x, self.y, self.r or 0, self.sx or 1, self.sy or 1)
    end
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

Components.Sound = Component {
    start = function(self)
        self.sound = love.audio.newSource(self.file, "static")
        if not self.usage.ports.play then
            self.sound:play()
        end
    end,
    update = function(self)
        if self.play then
            self.sound:stop()
            self.sound:play()
        end

        self.done = not self.sound:isPlaying()
    end
}

Components.Timer = Component {
    defaults = {
        _t = 0, time = 1
    },
    update = function(self)
        if self.restart then
            self._t = self.time
        end
        self._t = self._t - love.timer.getDelta()
        self.done = self._t < 0
        self.not_done = not self.done
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
    local index = {
        child_usage = Components[class](),
        oninstantiate = function(self)
            self.children = {}
        end,
        update = function(self)
            if self.trigger then
                local child = self.child_usage:instantiate(self)
                table.insert(self.children, child)
                for key, value in pairs(ports) do
                    child[key] = self[key]
                end
                child:start()
            end

            to_remove = {}
            for i = #self.children,1,-1 do
                local child = self.children[i]
                child:update()

                if child[self.destroy_on] then
                    child:destroy()
                    table.remove(self.children, i)
                end
            end
        end,
        destroy = function(self)
            for _, child in pairs(self.children) do
                if child.destroy then
                    child:destroy()
                end
            end
        end
    }
    return Usage(ports, index)
end

Components.Movable = Component {
    defaults = {
        x = 0, y = 0,
        vx = 0, vy = 0,
        ax = 0, ay = 0,
        dx = 0, dy = 0
    },
    update = function(self)
        self.vx = self.vx + self.ax
        self.vy = self.vy + self.ay
        self.x = self.x + self.vx
        self.y = self.y + self.vy
        self.vx = self.vx * (1 / self.dx)
        self.vy = self.vy * (1 / self.dy)
    end
}

Components.Periodically = Component {
    defaults = {
        frequency = 1,
        randomness = 0,
        event = 0,
    },
    start = function(self)
        self._t = self.frequency
    end,
    update = function(self)
        if self.event then
            self.event = false
        end

        self._t = self._t - love.timer.getDelta();
        if self._t < 0 then
            local r = self.randomness * self.frequency
            self._t = self.frequency + love.math.random(-r, r)
            self.event = true
        end
    end
}

Components.Random = Component {
    defaults = {
        min = 0, max = 0
    },
    update = function(self)
        for key, port in pairs(self.usage.ports) do
            self[key] = love.math.random(self.min, self.max)
        end
    end
}

Components.TileMap = Drawable {
    defaults = {
        visible = true,
        depth=1000,
    },
    draw = function(self)
        self.map:draw(-CAMERA.x, -CAMERA.y)
    end
}

Components.Map = Component {
    start = function(self)
        self.children = {}
        local map = sti(self.file)
        local tm = Components.TileMap():instantiate(self)
        tm.map = map
        tm.depth = 1000
        table.insert(self.children, tm)

        local usages = {}

        for id, object in pairs(map.objects) do
            if not Components[object.type] then
                error("No component named " .. object.type)
            end
            local usage = usages[object.type] or Components[object.type]()
            local child = usage:instantiate()
            child.x = object.x
            child.y = object.y
            for key, value in pairs(object.properties) do
                child[key] = value
            end
            table.insert(self.children, child)
            child:start()
        end
    end,
    update = function(self)
        for _, child in pairs(self.children) do
            if child.update then
                child:update()
            end
        end
    end
}
