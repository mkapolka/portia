function table_remove(t, value)
    for key, v in pairs(t) do
        if value == v then
            if type(key) == "number" then
                table.remove(t, key)
            else
                t[key] = nil
            end
        end
    end
end
