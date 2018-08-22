require "portia.lib.luatext"
require "portia.component"
require "portia.operands"
require "portia.lib.ml".import()
tostring=tstring

parser = MakeParser([[
    <thing> := {name}(<ident>) `{` 
    [
        {components[]}( <thinginstance> )*
    ]
    `}`;
    <thinginstance> := {type}(<ident>) `{`
        {inputs[]}( <varline> )*
    `}`;
    <varline> := {name}(<ident>) `=` {port}(<port>);
    <port> := {functor}(<portfunctor>) | {identity}(<ident>) | {const}(<const>);
    <portfunctor> := {name}(<ident>) `(` {args}(<portfunctorargs>) `)`;
    <portfunctorargs> := {[]}(<port>) (`,` {[]}(<port>))*;
    <const> := {}(<string> | <number> | <table>);
    <table> := {tablify()}(<rawtable>);
    <rawtable> := {emptytable()}(`{` `}`) | `{` ({[]}(<tablekv>)[`,`])+ `}`;
    <tablekv> := {key}(<ident>) `=` {val}(<const>);
    <file> := {[]}(<thing>)*;
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
    local composites = parser("file", string, actions)
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

function make_port(parsed_port)
    if parsed_port.const then
        return parsed_port.const
    end

    if parsed_port.identity then
        return Port(nil, parsed_port.identity)
    end

    if parsed_port.functor then
        local args = {}
        for key, value in pairs(parsed_port.functor.args) do
            args[key] = make_port(value)
        end

        if not Operands[parsed_port.functor.name] then
            error("No operaned named " .. parsed_port.functor.name)
        end

        return FunctorPort(Operands[parsed_port.functor.name], args)
    end
end

function make_usage(usage, ports, components)
    local inputs = {}
    for _, input in pairs(usage.inputs) do
        local port = make_port(input.port)
        inputs[input.name] = port
    end
    if not components[usage.type] then
        error("No component named " .. usage.type)
    end
    return components[usage.type](inputs)
end

function test()
    print(parser("varline", 'foo = sprite.hax'))

    print(parser("thinginstance", "Sprite { hi = blah }"))

    print(parser("file", [[
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

    print(parser("table", "{hi = 123, sup={blarg = 123}}", actions))

    print(parser("port", "foo(hi, bar(hi))"))
    print(parser("port", "hi_there"))
    print(parser("varline", "asdf = add(x, 1)"))
end
