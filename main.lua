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
        min=-10, max = 10,
        output1 = x,
        output2 = y
    }
    c.sprite = Sprite {
        sprite = "sprites/cursor.png",
        x = x,
        y = y,
        ox = 100,
        oy = 100,
        depth=-1,
    }
end)

DialogBox = Composite(function(c)
    local text = Port()
    local hovering = Port()
    c.bg = Sprite {
        x = 0,
        y = 300,
        sprite = "sprites/dbbg.png",
        depth=-50,
        visible = hovering
    }
    c.text = Text {
        x = 50,
        y = 400,
        text = text,
        depth=-100,
        visible = hovering
    }
    c.hovering = Hovering {
        hovering = hovering,
        data = text
    }
end)

Guy3 = Composite(function(c)
    local text = Port()
    local x = Port(300)
    local y = Port(200)
    local width = Port()
    local height = Port()

    c.sprite = Sprite {
        sprite = "sprites/guy.png",
        x = x,
        y = y,
        width = width,
        height = height
    }

    c.draggable = Draggable {
        x = x,
        y = y,
        width = width,
        height = height,
        data = "guess i'll never be getting that $50 you borrowed from me huh"
    }
end)

Guy2 = Composite(function(c)
    local text = Port()
    local x = Port(500)
    local y = Port(100)
    local width = Port()
    local height = Port()

    c.sprite = Sprite {
        sprite = "sprites/guy.png",
        x = x,
        y = y,
        width = width,
        height = height
    }

    c.draggable = Draggable {
        x = x,
        y = y,
        width =width,
        height = height,
        data = "no no no no no no please please please please"
    }
end)

Guy = Composite(function(c)
    local text = Port()
    local x = Port(100)
    local y = Port(100)
    local width = Port()
    local height = Port()

    c.sprite = Sprite {
        sprite = "sprites/guy.png",
        x = x,
        y = y,
        width = width,
        height = height
    }

    c.draggable = Draggable {
        x = x,
        y = y,
        width =width,
        height = height,
        data = "i never liked you. see you in hell!!!"
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
    local x = Port(-50)
    local y = Port(-50)
    c.sprite = Sprite {
        sprite = "sprites/plane_bg.png",
        depth = 100,
        x = x,
        y = y,
    }
    c.shaker = Shaker {
        output1 = x,
        output2 = y,
        min = -25,
        max = 25
    }
end)

Game = Composite(function(c)
    c.dialog = DialogBox()
    c.cursor = SpriteMover()
    c.guy = Guy()
    c.guy2 = Guy2()
    c.guy3 = Guy3()
    c.bg = Background()
    local done = Port()
    c.sound = Sound {
        file = "sounds/crash.ogg",
        done = done
    }
    c.quit = Quit {done=done}
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
