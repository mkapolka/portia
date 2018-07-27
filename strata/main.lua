Sprite {
    source = things.source
}

Sprite = Component({
    name: "Sprite"
    sources: {"source"},
    draw: function(self)
        for _, thing in ipairs(self.source) do
            love.graphics.draw(thing.sprite, thing.x, thing.y)
        end
    end
})

Mouse = Component({
    update: function(self)
        self.x = love.mouse.GetX()
        self.y = love.mouse.GetY()
    end
})
