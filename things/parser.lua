require "lib/luatext/luatext"
require "ml".import()
tostring = tstring

parser = MakeParser([[
    <thingtype> := `external` | `composite`;
    <inputline> := `input` {name}(<ident>) `;`;
    <outputline> := `output` {name}(<ident>) `;`;
    <thingdef> := {type}(<thingtype>) {name}(<ident>) `{` 
    (
        | {inputs[]}( <inputline> )
        | {outputs[]}( <outputline> )
        | {components[]}( <thinginstance> )
    )*
    `}`;
    <thinginstance> := {name}(<ident>) {type}(<ident>) `{`
        [
            {inputs[]}( <varline> )
            (`,` {inputs[]}( <varline> ))*
        ] 
    `}`;
    <varline> := {name}(<ident>) `=` {value}(<varvalue>);
    <varvalue> := <string> | <number> | {[]}(<ident>)`.`{[]}(<ident>);
]])

print(parser("varline", 'foo = sprite.hax'))

print(parser("thingdef", [[
    external Monster {
        input hi;
        output bye;
        sprite Sprite {
            image = "asdf",
            hax = 123,
            jommy = patch.mono
        }
    }
]]))
