Functors = {}

Functors.add = {
    default = 0,
    read = function(a, b)
        return a + b
    end
}

Functors.sub = {
    default = 0,
    read = function(a, b)
        return a - b
    end
}

Functors.mult = {
    default = 0,
    read = function(a, b)
        return a * b
    end
}

Functors.div = {
    default = 0,
    read = function(a, b)
        if b == 0 then
            return 0
        end

        return a / b
    end
}

Functors.random = {
    default = 0,
    read = function(min, max)
        local min = min or 0
        local max = max or 1
        return love.math.random(min, max)
    end
}

Functors.distance = {
    default = 0,
    read = function(x1, y1, x2, y2)
        local dx = x1 - x2
        local dy = y1 - y2
        return math.sqrt(dx * dx + dy * dy)
    end
}
