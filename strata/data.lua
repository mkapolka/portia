strata_mt = {
    __index = function(self, idx)
        local output = newstrata()
        rawset(self, idx, output)
        return output
    end,
    __newindex = function(self, idx, value)
        rawset(self[idx], "__VALUE", value)
    end
}

function newstrata()
    local output = {
        value = function(self)
            return rawget(self, "__VALUE")
        end
    }
    setmetatable(output, strata_mt)
    return output
end

ROOT = newstrata()

function testy()
    local st = newstrata()
    st.test.foo = 1234
    assert(st.test.foo:value() == 1234)
    st.test.foo.bleh = "test"
    assert(st.test.foo.bleh:value() == "test")
end

testy()
