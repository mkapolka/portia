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
        ox = 0, oy = 0, r = 0, sx = 1, sy = 1
    },
    start = function(self)
        self:update()
    end,
    update = function(self)
        local sprite = get_sprite(self.sprite)
        self.width = sprite:getWidth()
        self.height = sprite:getHeight()
    end,
    draw = function(self)
        love.graphics.draw(get_sprite(self.sprite), self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
    end,
}

font = love.graphics.newFont(32)
Components.Text = Drawable {
    defaults = {
        text = "", x = 0, y = 0, visible = true, depth = 0, color = {1, 1, 1, 1},
    },
    draw = function(self)
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0, 1)
        --love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4])
        love.graphics.print(self.text or "", self.x, self.y, self.r or 0, self.sx or 1, self.sy or 1)
        love.graphics.setColor(1, 1, 1, 1)
    end
}

DRAWABLES = {}

function draw_everything()
    table.sort(DRAWABLES, function(a, b) return -(a.depth or 0) < -(b.depth or 0) end)
    for _, drawable in pairs(DRAWABLES) do
        if drawable.visible and drawable.visible ~= 0 then
            drawable:draw()
        end
    end
end

Components.Animations = Drawable {
    defaults = {
        animations = {},
        file = "",
        current = "",
        x = 0, y = 0, ox = 0, oy = 0, r = 0, sx = 1, sy = 1,
        width = 32, height = 32,
        visible = true
    },
    start = function(self)
        local sprite = get_sprite(self.file)
        self._current_frame = 1
        self._current_t = 0
        self._previous_animation = self.current
    end,
    update = function(self)
        if self._previous_animation ~= self.current then
            self._previous_animation = self.current
            self._current_t = 0
            self._current_frame = 1
        end

        if self.animations[self.current] then
            -- Update frame number
            local animation = self.animations[self.current]
            self._current_t = self._current_t + love.timer.getDelta()
            if self._current_t > 1.0 / (animation.speed or 60) then
                self._current_t = 0 
                self._current_frame = (self._current_frame + 1) % #animation.frames
                if self._current_frame == 0 then
                    self._current_frame = 1
                end
            end
        end
    end,
    draw = function(self)
        if self.animations[self.current] then
            local animation = self.animations[self.current]
            local sprite = get_sprite(self.file)
            local fn = animation.frames[self._current_frame] - 1
            local frames_wide = sprite:getWidth() / self.width
            local fy = math.floor(fn / frames_wide)
            local quad = love.graphics.newQuad(
                fn * self.width % sprite:getWidth(),
                fy * self.height,
                self.width,
                self.height,
                sprite:getDimensions()
            )
            love.graphics.draw(sprite, quad, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
        else
            local sprite = get_sprite(self.file)
            love.graphics.draw(sprite, self.x, self.y, self.r)
        end
    end
}

Components.DebugBox = Drawable {
    defaults = {
        x = 0, y = 0, width = 100, height = 100, color = {255, 255, 255, 255}, depth = -100, visible = true
    },
    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.setColor(1, 1, 1, 1)
    end
}
