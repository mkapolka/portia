Components.PhysicsWall = Component {
    defaults = {
        x = 0, y = 0, width = 100, height = 100,
        vx = 0, vy = 0, ax = 0, ay = 0
    },
    start = function(self)
        self.body = love.physics.newBody(WORLD, self.x, self.y, "static")
        self.shape = love.physics.newRectangleShape(self.width, self.height)
        self.fixture = love.physics.newFixture(self.body, self.shape)
    end,
    update = function(self)
        self.body:setPosition(self.x, self.y)
    end,
    destroy = function(self)
        self.body:destroy()
        self.shape:release()
    end
}

Components.OverlappableRegion = Component {
    defaults = {
        x = 0, y = 0, width = 100, height = 100,
        vx = 0, vy = 0, ax = 0, ay = 0
    },
    start = function(self)
        self.body = love.physics.newBody(WORLD, self.x, self.y, "static")
        self.shape = love.physics.newRectangleShape(self.width, self.height)
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setSensor(true)
    end,
    update = function(self)
        self.body:setPosition(self.x, self.y)
    end,
    destroy = function(self)
        self.body:destroy()
        self.shape:release()
    end
}

Components.SolidThing = Component {
    defaults = {
        x = 0, y = 0, width = 50, height = 100, vx = 0, vy = 0,
        sensor = false
    },
    start = function(self)
        self.body = love.physics.newBody(WORLD, self.x, self.y, "dynamic")
        self.shape = love.physics.newRectangleShape(self.width, self.height)
        self.fixture = love.physics.newFixture(self.body, self.shape)
        self.fixture:setSensor(self.sensor)
        self.body:setInertia(10000)
    end,
    update = function(self)
        self.body:setLinearVelocity(self.vx, self.vy)
        self.body:setAngle(0)
        self.body:setAngularVelocity(0)
        self.x, self.y = self.body:getPosition()
    end,
    destroy = function(self)
        self.body:destroy()
        self.shape:release()
    end
}
