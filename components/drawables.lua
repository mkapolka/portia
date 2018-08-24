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
    draw = function(self)
        love.graphics.setFont(font)
        love.graphics.print(self.text or "", self.x, self.y, self.r or 0, self.sx or 1, self.sy or 1)
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
