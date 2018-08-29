local STI = require "portia.lib.sti.init"

local function destroy_children(children)
    for key, value in pairs(children) do
        if value.destroy then
            value:destroy()
        end
        children[key] = nil
    end
end

Container = function(index)
    index.visit = function(self, method_name)
        for _, child in pairs(self.children) do
            if child[method_name] then
                child[method_name](child)
            end
        end
    end
    index.update = index.update or function(self)
        self:visit("update")
    end
    index.start = index.start or function(self)
        self:visit("start")
    end
    index.destroy = index.destroy or function(self)
        destroy_children(self.children)
    end
    return Component(index)
end

Components.Composite = function(definition)
    local index = {
        definition = definition,
        oninstantiate = function(self)
            self.children = {}
            for key, usage in pairs(self.definition.components) do
                local comp_instance = usage:instantiate(self)
                self.children[key] = comp_instance
            end
        end,
    }
    return Container(index)
end

Components.Spawner = function(ports)
    local class = ports.class
    ports.class = nil
    local index = {
        child_usage = Components[class](),
        oninstantiate = function(self)
            self.children = {}
        end,
        update = function(self)
            if self.trigger then
                local child = self.child_usage:instantiate(self)
                table.insert(self.children, child)
                for key, value in pairs(ports) do
                    child[key] = self[key]
                end
                child:start()
            end

            to_remove = {}
            for i = #self.children,1,-1 do
                local child = self.children[i]
                child:update()

                if child[self.destroy_on] then
                    child:destroy()
                    table.remove(self.children, i)
                end
            end
        end,
        destroy = function(self)
            for _, child in pairs(self.children) do
                if child.destroy then
                    child:destroy()
                end
            end
        end
    }
    return Usage(ports, index)
end

Components.TileMap = Drawable {
    defaults = {
        visible = true,
        depth=1000,
    },
    draw = function(self)
        self.map:draw(-CAMERA.x, -CAMERA.y)
    end
}

local LOADMAP = nil

Components.Map = Component {
    load_map = function(self, map)
        destroy_children(self.children)

        local map = STI(map)
        local tm = Usage({}, Components.TileMap):instantiate(self)
        tm.map = map
        tm.depth = 1000
        table.insert(self.children, tm)

        local usages = {}

        for id, object in pairs(map.objects) do
            if not Components[object.type] then
                error("No component named " .. object.type)
            end
            local usage = usages[object.type] or Usage({}, Components[object.type])
            local child = usage:instantiate()
            child.x = object.x
            child.y = object.y
            for key, value in pairs(object.properties) do
                child[key] = value
            end
            table.insert(self.children, child)
            child:start()
        end
    end,
    oninstantiate = function(self)
        self.children = {}
        self:load_map(self.file)
    end,
    update = function(self)
        if LOADMAP then
            self:load_map(LOADMAP)
            LOADMAP = nil
        end

        for _, child in pairs(self.children) do
            if child.update then
                child:update()
            end
        end
    end
}

Components.SetMap = Component {
    default_order = 1,
    defaults = {
        map = "", when = false
    },
    update = function(self)
        if self.when then
            LOADMAP = self.map
        end
    end
}
