require 'ml'.import()
tostring = tstring

iota = 0
function new_id()
    iota = iota + 1
    return iota
end

usage_mt = {
    __newindex = function(self, key, value)
        self.inputs[key] = value
    end
}

Usage = function(inputs, instance_mt)
    local output = {
        inputs = inputs or {},
        outputs = {},
        instantiate = function(self)
            local output = {
                inputs = {},
                outputs = {}
            }
            setmetatable(output, instance_mt)
            return output
        end
    }
    setmetatable(output, usage_mt)
    return output
end

composite_instance_mt = {
    __index = {
        visit = function(instance, method_name)
            for name, component in pairs(instance.definition.components) do
                instance:populate_inputs(name)
                if instance[name][method_name] ~= nil then
                    instance[name][method_name](instance[name])
                end
            end
        end,
        populate_inputs = function(instance, component_name)
            component_def = instance.definition.components[component_name]
            for name, path in pairs(component_def.inputs) do
                instance[component_name][name] = instance:resolve_value(path)
            end
        end,
        resolve_value = function(instance, path)
            if type(path) == "table" then
                c, output = path[1], path[2]
                return instance[c][output]
            else
                return path
            end
        end,
        start = function(self)
            self:visit("start")
        end,
        update = function(self)
            self:visit("update")
        end,
        draw = function(self)
            self:visit("draw")
        end
    }
}

Composite = function(f)
    local components = {}
    f(components)
    local output = {
        components = components
    }
    setmetatable(output, {
        __call = function(self, args)
            local usage = {
                inputs = {},
                outputs = {},
                instantiate = function(self)
                    local instance = {inputs = {}, outputs = {}, definition = output}
                    for key, usage in pairs(instance.definition.components) do
                        local comp_instance = usage:instantiate()
                        instance[key] = comp_instance
                    end
                    setmetatable(instance, composite_instance_mt)
                    return instance
                end
            }
            setmetatable(usage, usage_mt)
            return usage
        end
    })
    return output
end

Component = function(index)
    local instance_mt = {
        __index = index
    }
    local mt = {
        __call = function(self, args)
            return Usage(args, instance_mt)
        end
    }
    local output = {}
    setmetatable(output, mt)
    return output
end

function get_sprite(name)
    if sprites_db[name] == nil then
        sprites_db[name] = love.graphics.newImage(name)
    end
    return sprites_db[name]
end
sprites_db = {}

Sprite = Component {
    update = function(self)
        local sprite = get_sprite(self.sprite)
        self.width = sprite:getWidth()
        self.height = sprite:getHeight()
    end,
    draw = function(self)
        love.graphics.draw(get_sprite(self.sprite), self.x, self.y)
    end
}

Mouse = Component {
    update = function(self)
        self.x = love.mouse.getX()
        self.y = love.mouse.getY()
    end
}
