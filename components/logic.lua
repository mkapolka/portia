-- Logic Components
-- Various components that handle storing values, handling streams, etc.

-- Togglue a boolean when <when> is true
-- Starts as <initial>, current value is <on>
Components.Toggle = Component {
    defaults = {
        on = false, when = 0, initial = false
    },
    start = function(self)
        self.on = self.initial
    end,
    update = function(self)
        if self.when then
            self.on = not self.on
        end
    end
}

-- Stores a timer that lasts for <time>, restarts when <restart> is true,
-- returns whether it's <done> or <not_done>(deprecated- use not(done))
Components.Timer = Component {
    defaults = {
        _t = 0, time = 1, restart = false, start_on=false, done = true, not_done = false
    },
    start = function(self)
        if self.start_on then
            self._t = self.time
            self.done = false
            self.not_done = true
        end
    end,
    update = function(self)
        if self.restart then
            self._t = self.time
        end
        self._t = self._t - love.timer.getDelta()
        self.done = self._t <= 0
        self.not_done = not self.done
    end
}

-- Fires this event about once every frequency, with jitter.
Components.Periodically = Component {
    defaults = {
        frequency = 1,
        randomness = 0,
        event = 0,
    },
    start = function(self)
        self._t = self.frequency
    end,
    update = function(self)
        if self.event then
            self.event = false
        end

        self._t = self._t - love.timer.getDelta();
        if self._t < 0 then
            local r = self.randomness * self.frequency
            self._t = self.frequency + love.math.random(-r, r)
            self.event = true
        end
    end
}

-- Stores <input> to <value> whenever <when> is true.
Components.Store = Component {
    defaults = {
        input = nil, value = nil, when = false, initial = false, initial_value = nil
    },
    start = function(self)
        if self.initial_value ~= nil then
            self.value = self.initial_value
        end

        if self.initial then
            self.value = self.input
        end
    end,
    update = function(self)
        if self.when then
            self.value = self.input
        end
    end
}

Components.Once = Component {
    default_order = -1,
    defaults = {
        when = false, value = false
    },
    start = function(self)
        self._triggered = false
    end,
    update = function(self)
        self.value = false
        if self.when and not self._triggered then
            self.value = true
            self._triggered = true
        end
    end

}
