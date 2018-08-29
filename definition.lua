Definition = function(usages)
    -- Sort the components
    local sorted = {}
    for key, component in pairs(usages) do
        table.insert(sorted, key)
    end
    function get_order(e)
        return usages[e].order or 0
    end
    table.sort(sorted, function(a, b) return get_order(a) < get_order(b) end)

    return {
        components = usages,
        sorted = sorted
    }
end
