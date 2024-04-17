local obj = {}
obj.__index = obj

obj.delaySeconds = 1

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

  if powerSource == PowerSource.Battery and powerSource ~= self.prevPowerSource then
    self:setMuted()
  end

  self.prevPowerSource = powerSource
end

function obj:setMuted()
  if self.timer then
    return
  end

  self.timer = hs.timer.doAfter(self.delaySeconds, function()
    self:onTimer()
  end)

  self.timer:start()
end

function obj:onTimer()
  if self.timer then
    self.timer:stop()
    self.timer = nil

    if hs.battery.powerSource() == PowerSource.Battery then
      hs.audiodevice.defaultOutputDevice():setMuted(true)
    end
  end
end

function obj:start()
  self.watcher:start()
end

function obj:stop()
  self.watcher:stop()
end

return obj
