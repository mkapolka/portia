iota = 0
function new_id()
    iota = iota + 1
    return tostring(iota)
end

Port = function(default, name)
    name = name or new_id()
    local output = {NAME=name, DEFAULT=default, ISPORT=true}
    return output
end

function is_port(t)
    return type(t) == "table" and t.ISPORT
end

usage_mt = {
    __newindex = function(self, key, value)
        self.ports[key] = value
    end
}

Usage = function(ports, index)
    local c_ports = {}
    local c_consts = {}

    local order = ports.order or 0
    ports.order = nil

    for key, input in pairs(ports or {}) do
        if is_port(input) then
            c_ports[key] = input
        else
            c_consts[key] = input
        end
    end

    local instance_mt = {
        __index = function(self, idx)
            local usage = rawget(self, "usage")
            local port = usage.ports[idx]
            if port then
                return self.parent[port.NAME] or port.DEFAULT
            else
                local outval = rawget(self, idx)
                if outval then
                    return outval
                else
                    return rawget(index, idx)
                end
            end
        end,
        __newindex = function(self, idx, value)
            local usage = rawget(self, "usage")
            local port = usage.ports[idx]
            if port then
                self.parent[port.NAME] = value
            else
                return rawset(self, idx, value)
            end
        end
    }

    local output = {
        ports = c_ports or {},
        consts = c_consts,
        order = order,
        instantiate = function(self, parent)
            local output = {parent=parent, usage=self}
            setmetatable(output, instance_mt)

            for key, value in pairs(c_consts) do
                output[key] = value
            end

            for key, value in pairs(index.defaults or {}) do
                if not output[key] then
                    output[key] = value
                end
            end

            if output.oninstantiate then
                output:oninstantiate()
            end

            return output
        end
    }
    setmetatable(output, usage_mt)
    return output
end

Composite = function(f)
    local components = {}
    f(components)
    local sorted = {}
    for key, component in pairs(components) do
        table.insert(sorted, key)
    end
    function get_order(e)
        return components[e].order or 0
    end
    table.sort(sorted, function(a, b) return get_order(a) < get_order(b) end)

    local definition = {
        components = components,
        sorted = sorted
    }

    local index = {
        definition = definition,
        visit = function(self, method_name)
            for _, child in pairs(self.children) do
                if child[method_name] then
                    child[method_name](child)
                end
            end
        end,
        oninstantiate = function(self)
            self.children = {}
            for key, usage in pairs(self.definition.components) do
                local comp_instance = usage:instantiate(self)
                self.children[key] = comp_instance
            end
        end,
        start = function(self)
            self:visit("start")
        end,
        destroy = function(self)
            self:visit("destroy")
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

    return Component(index)
end

Component = function(index)
    local mt = {
        __call = function(self, args)
            local args = args or {}
            args.order = args.order or index.default_order
            return Usage(args, index)
        end
    }
    local output = {}
    setmetatable(output, mt)
    return output
end
