require "portia.lib.luatext"
require "portia.component"
require "portia.lib.ml".import()
tostring=tstring

parser = MakeParser([[
    <thingdef> := {name}(<ident>) `{` 
    [
        {components[]}( <thinginstance> )*
    ]
    `}`;
    <thinginstance> := {type}(<ident>) `{`
        {inputs[]}( <varline> )*
    `}`;
    <varline> := {name}(<ident>) `=` (
        | {val}(<constdef>)
        | {port}(<ident>)
    );
    <constdef> := {}(<string> | <number> | <tabledef>);
    <tabledef> := {tablify()}(<rawtabledef>);
    <rawtabledef> := {emptytable()}(`{` `}`) | `{` ({[]}(<tablekv>)[`,`])+ `}`;
    <tablekv> := {key}(<ident>) `=` {val}(<constdef>);
    <filedef> := {[]}(<thingdef>)*;
]])

local actions = {
    emptytable = function(obj)
        return {}
    end,
    tablify = function(obj)
        local output = {}
        for _, pair in pairs(obj) do
            output[pair.key] = pair.val
        end
        return output
    end
}

function get_name(parts, desired)
    if parts[desired] then
        local i = 1
        while parts[desired.."_"..i] do
            i = i + 1
        end
        return desired.."_"..i
    else
        return desired
    end
end

function make_composites(components, string)
    local composites = parser("filedef", string, actions)
    local output = {}
    for _, definition in pairs(composites) do
        local ports = {}
        local name = definition.name
        local parts = {}
        for _, component in pairs(definition.components) do
            local usage = make_usage(component, ports, components)
            parts[get_name(parts, component.type)] = usage
        end

        local composite = Composite(function(c)
            for name, usage in pairs(parts) do
                c[name] = usage
            end
        end)
        components[definition.name] = composite
    end
end

function make_usage(usage, ports, components)
    local inputs = {}
    for _, input in pairs(usage.inputs) do
        local value = nil
        if input.val then value = input.val end
        if input.port then
            if ports[input.port] then
                value = ports[input.port]
            else
                ports[input.port] = Port(nil, input.port)
                value = ports[input.port]
            end
        end

        inputs[input.name] = value
    end
    return components[usage.type](inputs)
end

function test()
    print(parser("varline", 'foo = sprite.hax'))

    print(parser("thinginstance", "Sprite { hi = blah }"))

    print(parser("filedef", [[
        SpriteMover {
            Sprite {
                sprite = "sprite.png"
                x = x
                y = y
            }
            Mouse {
                x = x
            }
        }

        Game {
            SpriteMover {}
            SpriteMover {}
        }
    ]]))

    print(parser("tabledef", "{hi = 123, sup={blarg = 123}}", actions))
end
