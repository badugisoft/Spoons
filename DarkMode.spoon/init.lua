--- === ExitOnClose ===
---
--- Exit a program when it's last window has closed
---
--- Download: https://...
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "DarkMode"
obj.version = "0.1"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugiss/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- DarkMode.logger
--- Variable
--- Logger object
obj.logger = hs.logger.new(obj.name)

--- DarkMode:change()
--- Method
--- Change to dark mode
function obj:change(isDarkMode)
  hs.osascript.applescript(string.format(
    [[
    tell application "System Events"
      tell appearance preferences
        set dark mode to %s
      end tell
    end tell
  ]],
    isDarkMode
  ))
end

--- DarkMode:toggle()
--- Method
--- Toggle between dark and light mode
function obj:toggle()
  hs.osascript.applescript([[
    tell application "System Events"
      tell appearance preferences
        set dark mode to not dark mode
      end tell
    end tell
  ]])
end

--- DarkMode:bindHotKeys()
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
