Operands = {}

Operands.add = {
    read = function(a, b)
        return a + b
    end
}

Operands.sub = {
    read = function(a, b)
        return a - b
    end
}

Operands.mult = {
    read = function(a, b)
        return a * b
    end
}

Operands.div = {
    read = function(a, b)
        if b == 0 then
            return 0
        end

        return a / b
    end
}

Operands.random = {
    read = function(min, max)
        local min = min or 0
        local max = max or 1
        return love.math.random(min, max)
    end
}

Operands.distance = {
    read = function(x1, y1, x2, y2)
        local dx = x1 - x2
        local dy = y1 - y2
        return math.sqrt(dx * dx + dy * dy)
    end
}
