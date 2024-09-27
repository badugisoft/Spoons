local obj = {}
obj.__index = obj

obj.delaySeconds = 1

obj.brightness = 100

local PowerSource <const> = {
  AC = 'AC Power',
  Battery = 'Battery Power',
  Off = 'Off Line'
}

function obj:init()
  self.prevPowerSource = hs.battery.powerSource()

  self.watcher = hs.battery.watcher.new(function()
    self:onBatteryChange()
  end)
end

function obj:onBatteryChange()
  local powerSource = hs.battery.powerSource()

  if powerSource == PowerSource.AC and powerSource ~= self.prevPowerSource then
    if self.timer then
      return
    end

    self.timer = hs.timer.doAfter(self.delaySeconds, function()
      if self.timer then
        self.timer:stop()
        self.timer = nil

        if hs.battery.powerSource() == PowerSource.AC then
          hs.brightness.set(self.brightness)
        end
      end
    end)

    self.timer:start()
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
