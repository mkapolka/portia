require "portia.lib.luatext"
require "portia.components"
require "portia.definition"
require "portia.functors"

require "portia.lib.ml".import()
tostring=tstring

parser = MakeParser([[
    <composite> := {name}(<ident>) {definition}(<definition>);

    <definition> := 
    !Expected definition.!
    `{`
    [ {components[]}( <usage> )* ]
    !Expected closing bracket.!
    `}`;

    <usage> := {type}(<ident>) `{`
        {inputs[]}( <varline> )*
        !Expected closing bracket.!
    `}`;

    <varline> := {name}(<ident>) `=` {port}(<port>);
    <port> := {dyntable}(<dyntable>) | {const}(<const>) | {functor}(<portfunctor>) | {identity}(<ident>);
    <portfunctor> := {name}(<ident>) `(` {args}(<portfunctorargs>) `)`;
    <portfunctorargs> := {[]}(<port>) (`,` {[]}(<port>))*;
    <const> := {}(<string> | <number> | `false` | `true` | <table>);

    <table> := {tablify()}(<rawtable>);
    <rawtable> := {emptytable()}(`{` `}`) 
        | `{` 
            {[]}(<tablekv>) 
            (`,` {[]}(<tablekv>))* 
          `}`;
    <tablekv> := {key}(<ident>) `=` {val}(<const>) | {val}(<const>);

    <dyntable> := `{`
    ( {[]}(<dyntablekv>) | {[]}(<tablekv>) )
    ( (`,` {[]}(<tablekv>)) | (`,` {[]}(<dyntablekv>)) )*
    `}`;
    <dyntablekv> := {key}(<ident>) `=` {port}(<port>) | {port}(<port>);

    <file> := {[]}(<composite>)*;
]])

local actions = {
    emptytable = function(obj)
        return {}
    end,
    tablify = function(obj)
        local output = {}
        local i = 0
        for _, pair in pairs(obj) do
            local value = pair.val
            if value == "true" then value = true end
            if value == "false" then value = false end
            if pair.key then
                output[pair.key] = value
            else
                table.insert(output, value)
            end
        end
        return output
    end,
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

function make_composites(Components, string)
    local composites = parser("file", string, actions)
    local output = {}
    for _, p_composite in pairs(composites) do
        local ports = {}
        local name = p_composite.name
        local parts = {}
        for _, component in pairs(p_composite.definition.components) do
            local usage = make_usage(component, ports, Components)
            parts[get_name(parts, component.type)] = usage
        end

        local definition = Definition(parts)

        local composite = Components.Composite(definition)
        Components[p_composite.name] = composite
    end
end

function make_port(parsed_port)
    if parsed_port.const then
        local value = parsed_port.const
        if value == "true" then return true end
        if value == "false" then return false end
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

        if not Functors[parsed_port.functor.name] then
            error("No functor named " .. parsed_port.functor.name)
        end

        return FunctorPort(Functors[parsed_port.functor.name], args)
    end

    if parsed_port.dyntable then
        local args = {}
        local i = 1
        local j = 1
        for _, v in ipairs(parsed_port.dyntable) do
            local key = v.key
            if not key then
                key = i
                i = i + 1
            end

            local value = nil
            if v.val then
                value = v.val
            else
                value = make_port(v.port)
            end

            args[j] = key
            args[j+1] = value
            j = j + 2
        end
        return FunctorPort(Functors.table, args)
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
    return Usage(inputs, components[usage.type])
end

function test()
    print(parser("varline", 'foo = sprite.hax'))

    print(parser("usage", "Sprite { hi = blah }"))

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

    print(parser("const", "{1, 2, 3, key=123}", actions))

    print(parser("dyntable", "{key=port, port2, key2=123}", actions))
end
