require "portia.lib.luatext"
require "portia.component"

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
        | {val}(<string>)
        | {val}(<number>)
        | {port}(<ident>)
    );
    <filedef> := {[]}(<thingdef>)*;
]])

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
    local composites = parser("filedef", string)
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
end
