--- === ExitOnClose ===
---
--- Exit a program when it's last window has closed
---
--- Download: https://...
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ExitOnClose"
obj.version = "0.1"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugiss/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--
local function dumpTable(o)
  print(hs.json.encode(o or {}, true))
end

--- ExitOnClose.logger
--- Variable
--- Logger object
obj.logger = hs.logger.new(obj.name)

--- ExitOnClose.blacklist
--- Variable
--- Blacklist
obj.blacklist = nil

--- ExitOnClose.minWindowCount
--- Variable
--- Minimum window count
obj.minWindowCount = 1

--- Local functions
local function isInList(list, name)
  for _, pattern in ipairs(list) do
    if name:match(pattern) == name then
      return true
    end
  end
  return false
end

--- Internal methods
function obj:_onDeactivated(name, app)
  local windowCount = #app:allWindows()
  self.logger.df('onDeactivated: name="%s" windowCount=%d', name, windowCount)

  if windowCount >= self.minWindowCount then
    return
  end

  if self.blacklist and isInList(self.blacklist, name) then
    app:kill()
    self.logger.f("killed: name=%s", name)
  end
end

--- SpoonLoader:start()
--- Method
--- Start watching applications
function obj:start()
  self.logger.df("starting...")

  dumpTable(obj.blacklist)

  if not self._watcher then
    self._watcher = hs.application.watcher.new(function(name, type, app)
      if type == hs.application.watcher.deactivated then
        self:_onDeactivated(name, app)
      end
    end)

    self._watcher:start()
    self.logger.df("started")
  end
end

--- SpoonLoader:stop()
--- Method
--- Stop watching applications
function obj:stop()
  self.logger.df("stopping...")

  if self._watcher then
    self._watcher:stop()
    self._watcher = nil
    self.logger.df("stopped")
  end
end

return obj
