-- Beacons have a position and data. They can be detected by "NearestBeacon" components
-- In order to communicate data between two game objects.

BEACONS = {}
Components.Beacon = Component {
    defaults = {
        x = 0, y = 0, tag="default",
        data = "",
    },
    start = function(self)
        self._id = new_id()
        BEACONS[self._id] = self
    end,
    destroy = function(self)
        BEACONS[self._id] = nil
    end
}

Components.NearestBeacon = Component {
    defaults = {
        x = 0, y = 0, data ="", tag = "default",
        ox = 0, oy = 0, match = false, within = 0
    },
    update = function(self)
        local ld = 10000000
        local lb = nil
        local x = self.x
        local y = self.y
        for _, beacon in pairs(BEACONS) do
            if beacon.tag == self.tag then
                local dx = beacon.x - x
                local dy = beacon.y - y
                local d = math.sqrt(dx * dx + dy * dy)
                if d < self.within and d < ld then
                    lb = beacon
                    ld = d
                end
            end
        end

        if lb then
            self.ox = lb.x
            self.oy = lb.y
            self.data = lb.data
            self.match = true
        else
            self.match = false
            self.data = nil
            self.ox = x
            self.oy = y
        end
    end
}
