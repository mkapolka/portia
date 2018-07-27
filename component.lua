COMPONENTS = {}

function Component(component)
    local mt = {
        __call = function(self, inputs)
            local output = {}
            output.inputs = 
        end
    }
end

function love.graphics.draw()
    for _, c in bleh do

    end
end

Sprite = Component {
    inputs = {
        "sprite", "x", "y"
    },
    draw = function(self)
        love.graphics.draw(self.sprite, self.x, self.y)
    end
}

Sprites {
    source=guys
}

Colliders {
    source=guys
}
