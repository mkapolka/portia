require "component"
require "love"

root = nil

SpriteMover = Composite(function(c)
    c.mouse = Mouse()
    c.sprite = Sprite {
        sprite = "sprite.png",
        x = c.mouse.x,
        y = c.mouse.y
    }
end)

Game = Composite(function(c)
    c.spriteMover = SpriteMover()
end)

function love.load()
    print("hi")
    root = Game().instantiate()
    root:start()
end

function love.update()
    root:update()
end

function love.draw()
    root:draw()
end
