require "portia.utils"

BULLETS = {}
BULLET_COLLIDERS = {}

Components.Shooter = Drawable {
    defaults = {
        x = 0, y = 0, shoot = false, vx = 0, vy = 0, sprite = nil
    },
    update = function(self)
        
    end
}

Components.Bullet = Component {
    defaults = {
        x = 0, y = 0, hit = false
    },
    start = function(self)
        table.insert(BULLETS, self)
    end,
    destroy = function(self)
        table_remove(BULLETS, self)
    end,
    static_update = function(self)
        for _, bullet in pairs(BULLETS) do
            bullet.hit = false
        end

        for _, collider in pairs(BULLET_COLLIDERS) do
            collider.hit = false
        end

        for _, bullet in pairs(BULLETS) do
            for _, collider in pairs(BULLET_COLLIDERS) do
                local dx = bullet.x - collider.x
                local dy = bullet.y - collider.y
                if dx * dx + dy * dy < collider.size * collider.size then
                    bullet.hit = true
                    collider.hit = true
                end
            end
        end
    end
}

Components.BulletCollider = Component {
    default_order = -1,
    defaults = {
        x = 0, y = 0, size = 10, hit = false
    },
    start = function(self)
        if self.started then
            error("start called twice on collider.")
        end
        self.started = true
        table.insert(BULLET_COLLIDERS, self)
    end,
    destroy = function(self)
        table_remove(BULLET_COLLIDERS, self)
    end
}
