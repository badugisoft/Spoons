--- === ExitOnClose ===
---
--- Exit a program when it's last window has closed
---
--- Download: https://...
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "FullScreen"
obj.version = "0.1"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugiss/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- FullScreen.logger
--- Variable
--- Logger object
obj.logger = hs.logger.new(obj.name)

--- FullScreen:change()
--- Method
--- Set dark mode
function obj:change(isFullScreen)
  hs.window.focusedWindow():setFullScreen(isFullScreen)
end

--- FullScreen:toggle()
--- Method
--- Toggle dark mode
function obj:toggle()
  local win = hs.window.focusedWindow()
  win:setFullScreen(not win:isFullScreen())
end

--- FullScreen:bindHotKeys()
--- Method
--- Bind hotkeys
function obj:bindHotkeys(mapping)
    hs.spoons.bindHotkeysToSpec({
        change = hs.fnutils.partial(self.change, self),
        toggle = hs.fnutils.partial(self.toggle, self),
    }, mapping)
    return self
end

return obj
