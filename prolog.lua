Window = { mapping = {}, instance = {}, root = "" }

function Window:__index(key)
    local mapped = self.mapping[key]
    if mapped then
        return self.instance[mapped]
    else
        return self.instance[self.root .. key]
    end
end

function Window:__newindex(key, value)
    local mapped = self.mapping[key]
    if mapped then
        self.instance[mapped] = value
    else
        self.instance[self.root .. key] = value
    end
end

function Window:configure(instance, mapping, root)
    rawset(self, "mapping", mapping)
    rawset(self, "instance", instance)
    rawset(self, "root", root)
end

setmetatable(Window, Window)


function Component(table)
    return table
end

Composite_mt = {}
Composite_mt.__index = Composite_mt
Composite_mt.is_composite = true
function Composite(table)
    setmetatable(table, Composite_mt)
    return table
end

Sprite = Component {
    update = function(self)
        print(self.x, self.y)
    end
}

Mouse = Component {
    update = function(self)
        self.x = (self.x or 0) + 1
        self.y = (self.y or 0) + 2
        self.z = "ssssh"
    end
}

Monster = Composite {
    sprite = {
        type = Sprite,
        mapping = {
            x = "health",
            y = "dimension"
        }
    }
}

Game = Composite {
    {
        type = Mouse,
        mapping = {
            x = "rootx",
            y = "rooty"
        }
    },
    {
        type = Monster,
        mapping = {
            health = "rootx",
            dimension = "rooty"
        },
    },
}

function visit(instance, method, mapping, path)
    Window:configure(instance, mapping, path)
    method(Window)
end

function visit_composite(instance, mapping, path, composite)
    for name, usage in pairs(composite) do
        local new_mapping = {}
        for key_name, value in pairs(usage.mapping) do
            new_mapping[key_name] = mapping[value] or path .. value
        end
        if usage.type.is_composite then
            visit_composite(instance, new_mapping, path .. name, usage.type)
        else
            visit(instance, usage.type.update, new_mapping, path .. name)
        end
    end
end

g = {}
g2 = {}
visit_composite(g, {}, "", Game)
visit_composite(g2, {}, "", Game)
visit_composite(g, {}, "", Game)
visit_composite(g2, {}, "", Game)

for key, value in pairs(g) do
    print(key, value)
end
