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
            local port = c_ports[idx]
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
            local port = c_ports[idx]
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
            local output = {parent=parent}
            for key, value in pairs(c_consts) do
                output[key] = value
            end
            setmetatable(output, instance_mt)

            if output.draw then
                table.insert(DRAWABLES, output)
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

composite_instance_mt = {
    __index = {
    }
}

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
            for _, name in pairs(self.definition.sorted) do
                local component = self[name]
                if component[method_name] ~= nil then
                    component[method_name](component)
                end
            end
        end,
        oninstantiate = function(self)
            for key, usage in pairs(self.definition.components) do
                local comp_instance = usage:instantiate(self)
                self[key] = comp_instance
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
