local obj = {}
obj.__index = obj

local PowerSource <const> = {
  AC = 'AC Power',
  Battery = 'Battery Power',
  Off = 'Off Line'
}

function obj:init()
  self.brightness = 100
  self.prevPowerSource = hs.battery.powerSource()

  self.watcher = hs.battery.watcher.new(function()
    self:onBatteryChange()
  end)
end

function obj:onBatteryChange()
  local powerSource = hs.battery.powerSource()

  if powerSource == PowerSource.AC and powerSource ~= self.prevPowerSource then
    hs.brightness.set(self.brightness)
  end

  self.prevPowerSource = powerSource
end

function obj:start()
  self.watcher:start()
end

function obj:stop()
  self.watcher:stop()
end

return obj
