require "component"
require "components"
require "love"

root = nil

SpriteMover = Composite(function(c)
    local x = Port()
    local y = Port()
    c.mouse = Mouse {
        x = x,
        y = y
    }
    c.shaker = Shaker {
        min=-10, max=10,
        output1 = x,
        output2 = y
    }
    c.sprite = Sprite {
        sprite = "dice.png",
        x = x,
        y = y
    }
    c.text = Text {
        x =x ,
        y = y,
        text = "hi there",
        sx = 1,
        sy = 1
    }
end)

DragSprite = Composite(function(c)
    local x = Port(0)
    local y = Port(0)
    local width = Port(0)
    local height = Port(0)

    c.draggable = Draggable {
        x = x,
        y = y,
        width = width,
        height = height
    }
    c.sprite = Sprite {
        sprite = "dice.png",
        x = x,
        y = y,
        width = width,
        height = height
    }
end)

Background = Composite(function(c)
    c.sprite = Sprite {
        sprite = "bg.png",
        depth = -100
    }
end)


Game = Composite(function(c)
    c.spriteMover = SpriteMover()
    c.dragSprite = DragSprite()
    c.bg = Background()
end)

function love.load()
    root = Game().instantiate()
    root:start()
end

function love.update()
    root:update()
end

function love.draw()
    draw_everything()
end
