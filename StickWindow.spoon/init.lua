--- === ExitOnClose ===
---
--- Exit a program when it's last window has closed
---
--- Download: https://...
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "StickWindow"
obj.version = "0.1"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugiss/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- StickWindow.logger
--- Variable
--- Logger object
obj.logger = hs.logger.new(obj.name)

--- StickWindow.x
--- Variable
--- x
obj.x = nil

--- StickWindow.y
--- Variable
--- y
obj.y = nil

--- StickWindow.x1
--- Variable
--- x1
obj.x1 = nil

--- StickWindow.y1
--- Variable
--- y1
obj.y1 = nil

--- StickWindow.x2
--- Variable
--- x2
obj.x2 = nil

--- StickWindow.y2
--- Variable
--- y2
obj.y2 = nil

--- StickWindow.rectDisplaySeconds
--- Variable
--- rectDisplaySeconds
obj.rectDisplaySeconds = 10

--- Local functions
local function screenRect()
  return hs.window.focusedWindow():screen():frame()
end

local function moveWindow(x, y, w, h)
  hs.window.focusedWindow():move(hs.geometry(x, y, w, h))
end

--- Internal functions
function obj:_toLeft(x)
  local s = screenRect()
  local d = x or (s.w / 2)
  moveWindow(s.x, s.y, d, s.h)
end

function obj:_toRight(x)
  local s = screenRect()
  local d = x or (s.w / 2)
  moveWindow(s.x + d + 1, s.y, s.w - d - 1, s.h)
end

function obj:_toTop(y)
  local s = screenRect()
  local d = y or (s.h / 2)
  moveWindow(s.x, s.y, s.w, d)
end

function obj:_toBottom(y)
  local s = screenRect()
  local d = y or (s.h / 2)
  moveWindow(s.x, s.y + d + 1, s.w, s.h - d - 1)
end

--- StickWindow:toLeft()
--- Method
--- Start watching applications
function obj:toLeft()
  self:_toLeft(self.x)
end

function obj:toRight()
  self:_toRight(self.x)
end

function obj:toTop()
  self:_toTop(self.y)
end

function obj:toBottom()
  self:_toBottom(self.y)
end

function obj:toLeft1()
  self:_toLeft(self.x1)
end

function obj:toRight1()
  self:_toRight(self.x1)
end

function obj:toTop1()
  self:_toTop(self.y1)
end

function obj:toBottom1()
  self:_toBottom(self.y1)
end

function obj:toLeft2()
  self:_toLeft(self.x2)
end

function obj:toRight2()
  self:_toRight(self.x2)
end

function obj:toTop2()
  self:_toTop(self.y2)
end

function obj:toBottom2()
  self:_toBottom(self.y2)
end

--- StickWindow:showRect()
--- Method
--- Show current windows's rect
function obj:showRect()
  if self.closeTimer then
    self.closeTimer:stop()
    hs.alert.closeSpecific(self.alertUuid)
    self.alertUuid = nil
    self.closeTimer = nil
    return
  end

  local r = hs.window.focusedWindow():frame()
  local text = string.format("Left: %d\nTop: %d\nWidth: %d\nHeight: %d", r.x, r.y, r.w, r.h)
  self.alertUuid = hs.alert(text, {}, hs.screen.mainScreen(), "")
  self.closeTimer = hs.timer.doAfter(self.rectDisplaySeconds or 10, function()
    hs.alert.closeSpecific(self.alertUuid)
    self.alertUuid = nil
    self.closeTimer = nil
  end)
end

--- StickWindow:bindHotKeys()
--- Method
--- Bind hotkeys
function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
    toLeft = hs.fnutils.partial(self.toLeft, self),
    toRight = hs.fnutils.partial(self.toRight, self),
    toTop = hs.fnutils.partial(self.toTop, self),
    toBottom = hs.fnutils.partial(self.toBottom, self),
    toLeft1 = hs.fnutils.partial(self.toLeft1, self),
    toRight1 = hs.fnutils.partial(self.toRight1, self),
    toTop1 = hs.fnutils.partial(self.toTop1, self),
    toBottom1 = hs.fnutils.partial(self.toBottom1, self),
    toLeft2 = hs.fnutils.partial(self.toLeft2, self),
    toRight2 = hs.fnutils.partial(self.toRight2, self),
    toTop2 = hs.fnutils.partial(self.toTop2, self),
    toBottom2 = hs.fnutils.partial(self.toBottom2, self),
    showRect = hs.fnutils.partial(self.showRect, self),
  }, mapping)
  return self
end

return obj
