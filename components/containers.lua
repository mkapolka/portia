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
    index.add_child = index.add_child or function(self, child)
        table.insert(self.children, child)
    end
    index.destroy_child = index.destroy_child or function(self, child)
        for k, v in pairs(self.children) do
            if v == child then
                table.remove(self.children, k)
                if v.destroy then
                    v:destroy()
                end
            end
        end
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
            end
        end,
    }
    return Container(index)
end

Components.Destroyable = Container {
    defaults = {
        when = false, what = nil
    },
    oninstantiate = function(self)
        self.children = {}
        self.what:instantiate(self)
    end,
    update = function(self)
        self:visit("update")
        if self.when then
            self.child:destroy()
        end
    end
}

Components.Spawner = Container {
    defaults = {
        what = nil, values={}, when = false
    },
    oninstantiate = function(self)
        self.children = {}
    end,
    update = function(self)
        if self.when then
            local child = self.what:instantiate(self)
            for key, value in pairs(self.values) do
                child[key] = value
            end
            child:start()
        end

        self:visit("update")

        to_remove = {}
        for i = #self.children,1,-1 do
            local child = self.children[i]

            if child[self.destroy_when] then
                child:destroy()
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

Components.Map = Container {
    load_map = function(self, map)
        destroy_children(self.children)

        local map = STI(map)
        --local tm = Usage({}, Components.TileMap):instantiate(self)
        --tm.map = map
        --tm.depth = 1000
        table.insert(self.children, tm)

        local usages = {}

        for id, object in pairs(map.objects) do
            if object.type and object.type ~= "" then
                if not Components[object.type] then
                    error("No component named " .. object.type)
                end
                local usage = usages[object.type] or Usage({}, Components[object.type])
                local child = usage:instantiate(self)
                child.x = object.x
                child.y = object.y
                for key, value in pairs(object.properties) do
                    child[key] = value
                end
            end
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

        self:visit("update")
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
