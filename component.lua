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

FunctorPort = function(functor, args)
    name = name or new_id()
    return {
        ISPORT = true,
        functor = functor,
        args = args,
        NAME=name
    }
end

function is_port(t)
    return type(t) == "table" and t.ISPORT
end

usage_mt = {
    __newindex = function(self, key, value)
        self.ports[key] = value
    end
}

function resolve_port(instance, port)
    -- Consts
    if not is_port(port) then
        return port
    end

    if port.functor then
        local args = {}
        for i, arg_port in pairs(port.args) do
            args[i] = resolve_port(instance, arg_port)
            if args[i] == nil then
                return port.functor.default
            end
        end
        return port.functor.read(unpack(args))
    else
        return instance.parent[port.NAME]
    end
end

Usage = function(ports, index)
    local c_ports = {}
    local c_consts = {}

    local order = ports.order or index.default_order or 0
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
                return resolve_port(self, port)
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
        instantiate = function(self, parent, instance_index)
            local output = {parent=parent, usage=self}
            setmetatable(output, instance_mt)

            for key, value in pairs(c_consts) do
                output[key] = value
            end

            if instance_index then
                for key, value in pairs(instance_index) do
                    output[key] = value
                end
            end

            for key, value in pairs(index.defaults or {}) do
                if not output[key] then
                    output[key] = value
                end
            end

            if parent then
                parent:add_child(output)
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

Component = function(index)
    return index
end
