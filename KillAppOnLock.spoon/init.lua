local obj = {}
obj.__index = obj

obj.list = {}

function obj:init()
  self.watcher = hs.caffeinate.watcher.new(function(type)
    self:onEvent(type)
  end)
end

function obj:onEvent(type)
  if type == hs.caffeinate.watcher.screensDidLock then
    for _, item in ipairs(self.list) do
      local app = hs.application.find(item.hint, item.exact, item.stringLiteral)
      if app then
        app:kill()
      end
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
