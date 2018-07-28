require "lib/luatext"
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

    composite SpriteMover {
        Sprite {
            sprite = "sprite.png",
            x = x
            y = y
        }

        Mouse {
            x = x
            y = y
        }
    }

    composite Guy {
        Sprite {
            sprite="sprite.png"
            x = x
            y = y,
            width = width
            height = height
        }

        Hoverable {
            x = x
            y = y,
            width = width
            height = height
            data1 = "hi there"
        }

        Shaker {
            min = -10
            max = 10
            output1 = x
            output2 = y
        }
    }
]]))
