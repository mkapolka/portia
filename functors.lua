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

Functors["and"] = {
    read = function(a, b)
        return a and b
    end
}

Functors["or"] = {
    read = function(a, b)
        return a or b
    end
}

Functors["not"] = {
    read = function(a)
        return not a
    end
}


Functors.random = {
    default = 0,
    read = function(min, max)
        local min = min or 0
        local max = max or 1
        return min + love.math.random() * max
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

Functors.switch = {
    default = 0,
    read = function(...)
        local args = {...}
        for i=1,#args,2 do
            local case, value = args[i], args[i+1]
            if case then
                return value
            end
        end
    end
}

Functors.case = {
    read = function(q, ...)
        local args = {...}
        for i=1,#args,2 do
            local v, r = args[i], args[i+1]
            if q == v then
                return r
            end
        end
        return args[i]
    end
}

Functors.table = {
    default = {},
    read = function(...)
        local output = {}
        local args = {...}
        for i=1,#args,2 do
            output[args[i]] = args[i+1]
        end
        return output
    end
}

Functors.print = {
    read = function(a)
        print(a)
        return a
    end
}
