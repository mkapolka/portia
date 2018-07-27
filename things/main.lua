require "component"
require "components"
require "love"

root = nil

SpriteMover = Composite(function(c)
    c.mouse = Mouse()
    c.shakerx = Shaker {min=-10, max=10}
    c.shakery = Shaker {min=-10, max=10}
    c.add_x = Add {
        a = {"mouse", "x"},
        b = {"shakerx", "value"}
    }
    c.add_y = Add {
        a = {"mouse", "y"},
        b = {"shakery", "value"}
    }
    c.sprite = Sprite {
        sprite = "dice.png",
        x = {"add_x", "value"},
        y = {"add_y", "value"}
    }
end)

DragSprite = Composite(function(c)
    c.draggable = Draggable {}
    c.sprite = Sprite {
        sprite = "dice.png",
        x = {"draggable", "x"},
        y = {"draggable", "y"}
    }
    c.draggable.width = {"sprite", "width"}
    c.draggable.height = {"sprite", "height"}
end)


Game = Composite(function(c)
    c.spriteMover = SpriteMover()
    c.dragSprite = DragSprite()
end)

function love.load()
    root = Game().instantiate()
    root:start()
end

function love.update()
    root:update()
end

function love.draw()
    root:draw()
end
