--local pg = require "parser-gen"
local lpeg = require "lpeg"
require "ml".import()
tostring = tstring

local P, R, C, Ct = lpeg.P, lpeg.R, lpeg.C, lpeg.Ct

function load_file(filename)
    local f = io.open(filename, 'r')
    local output = f:read("*all")
    f:close()
    return output
end

lpeg.locale(lpeg)

local SPACE = (lpeg.space + P '\n')^0

function SPACED(pattern)
    return SPACE * pattern * SPACE
end

function FIT(pattern)
    return function(values)
        output = {}
        for i, key in ipairs(pattern) do
            print(key, i, values[i])
            output[key] = values[i]
        end
        return output
    end
end

local NAME = SPACED(lpeg.alnum^1)
local THINGTYPE = SPACED(P "composite" + P "external")
local INOROUT = SPACED(P "input" + P "output")
local INOUTLINE = Ct(SPACED(C(INOROUT) * C(NAME) * P";")) / FIT {"DIRECTION", "NAME"}
--local PART = Ct(SPACED(C(NAME)) + P"=" + 
local THINGLINE = SPACED(INOUTLINE)
local THINGCONTENTS = SPACED(P "{" * THINGLINE^0 * P "}")
local THINGDEF = Ct(SPACED(C(THINGTYPE) * C(NAME) * Ct(THINGCONTENTS))) / FIT {'TYPE', 'NAME', 'CONTENTS'}

local TESTDEF = C(NAME)^0

print(lpeg.match(THINGDEF, [[
    external Hello {
        input hi;
        output bye;
    }
]]))

--local grammar = pg.compile(load_file("grammar"), {})
--print(pg.parse(load_file("example.sol"), grammar))
