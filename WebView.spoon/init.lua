--- === WebView ===
---
--- Display a webview popup attached to a menu bar icon in Hammerspoon using native canvas framing.
---
--- Download: https://github.com/badugisoft/Spoons
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "WebView"
obj.version = "0.9"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugisoft/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- WebView.logger
--- Variable
--- Logger object
obj.logger = hs.logger.new(obj.name)

--- Default configurations
obj.items = nil
obj.menubar = {}
obj.timer = {}
obj._loadedItems = {}

local function pointInRect(p, r)
  if not p or not r then return false end
  local px = p.x or p._x
  local py = p.y or p._y
  local rx = r.x or r._x
  local ry = r.y or r._y
  local rw = r.w or r._w
  local rh = r.h or r._h
  if not px or not py or not rx or not ry or not rw or not rh then return false end
  return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end

local function createItem(itemConfig)
  local title = itemConfig.title
  if title == nil then title = "🌐" end

  return {
    title = title,
    url = itemConfig.url or "https://www.google.com",
    width = itemConfig.width or 800,
    height = itemConfig.height or 600,
    padding = itemConfig.padding or 4,
    keepInBackground = (itemConfig.keepInBackground ~= false), -- default true
    closeOnBlur = (itemConfig.closeOnBlur ~= false),           -- default true for popovers
    reloadOnOpen = (itemConfig.reloadOnOpen == true),          -- default false
    showReloadButton = (itemConfig.showReloadButton ~= false), -- default true
    position = itemConfig.position or "menubar",               -- "menubar" or "center"
    popoverStyle = (itemConfig.popoverStyle ~= false),         -- default true for native popover frame
    borderRadius = itemConfig.borderRadius or 12,
    borderWidth = itemConfig.borderWidth or 1.5,
    offsetY = itemConfig.offsetY or 2,
    hotkey = itemConfig.hotkey,
    webview = nil,
    canvas = nil,
    menubar = nil,
    clickTap = nil
  }
end

local function calculateWindowPosition(item, w, h)
  local padding = item.popoverStyle and (item.padding or 6) or 0
  local outerW = w + (padding * 2)
  local outerH = h + (padding * 2)

  local screen = nil
  if item.menubar then
    local mbFrame = item.menubar:frame()
    if mbFrame and mbFrame.w and mbFrame.w > 0 then
      local s = hs.screen.find(mbFrame)
      if s then screen = s:frame() end
    end
  end
  if not screen then
    local s = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
    screen = s:frame()
  end

  local iconX = nil
  local offsetY = item.offsetY or 2

  if item.position == "center" then
    local x = screen.x + (screen.w - outerW) / 2
    local y = screen.y + (screen.h - outerH) / 2
    return x, y, outerW, outerH
  end

  -- Calculate position directly anchored under menubar icon
  if item.menubar then
    local mbFrame = item.menubar:frame()
    if mbFrame and mbFrame.w and mbFrame.w > 0 and mbFrame.x and mbFrame.x > 0 then
      iconX = mbFrame.x + (mbFrame.w / 2)
    end
  end

  if not iconX or iconX <= 0 then
    local mousePos = hs.mouse.absolutePosition()
    iconX = mousePos.x
  end

  local x = math.min(math.max(screen.x + 8, iconX - (outerW / 2)), screen.x + screen.w - outerW - 8)
  local y = screen.y + offsetY

  return x, y, outerW, outerH
end

local function setupCanvas(item, x, y, outerW, outerH)
  local radius = item.borderRadius or 16
  local borderW = item.borderWidth or 1.5

  local bgColor = { red = 0.15, green = 0.15, blue = 0.16, alpha = 0.98 }
  local borderColor = { white = 1, alpha = 0.35 }

  if not item.canvas then
    item.canvas = hs.canvas.new(hs.geometry.rect(x, y, outerW, outerH))
    item.canvas:level(hs.drawing.windowLevels.popUpMenu)
  else
    item.canvas:frame(hs.geometry.rect(x, y, outerW, outerH))
  end

  -- Outer card background & border framing around webview
  item.canvas[1] = {
    type = "rectangle",
    frame = { x = 0, y = 0, w = outerW, h = outerH },
    roundedRectRadii = { xRadius = radius, yRadius = radius },
    fillColor = bgColor,
    strokeColor = borderColor,
    strokeWidth = borderW
  }

  return item.canvas
end

local function applyWebViewCSS(wv, radius)
  local r = tostring(math.max(4, radius)) .. "px"
  local js = string.format([[
    (function() {
      var apply = function() {
        document.documentElement.style.backgroundColor = "transparent";
        document.documentElement.style.borderRadius = "%s";
        document.documentElement.style.overflow = "hidden";
        if (document.body) {
          document.body.style.borderRadius = "%s";
          document.body.style.overflow = "hidden";
        }
      };
      if (document.readyState === 'complete' || document.readyState === 'interactive') {
        apply();
      } else {
        document.addEventListener('DOMContentLoaded', apply);
        window.addEventListener('load', apply);
      }
    })();
  ]], r, r)

  wv:evaluateJavaScript(js)
end

local function injectReloadButton(wv)
  local js = [[
    (function() {
      var inject = function() {
        if (!document.body || document.getElementById('__hs_reload_btn__')) return;
        var btn = document.createElement('div');
        btn.id = '__hs_reload_btn__';
        btn.title = 'Reload';
        btn.style.position = 'fixed';
        btn.style.right = '10px';
        btn.style.bottom = '10px';
        btn.style.width = '24px';
        btn.style.height = '24px';
        btn.style.borderRadius = '50%';
        btn.style.background = 'rgba(30, 30, 30, 0.6)';
        btn.style.backdropFilter = 'blur(6px)';
        btn.style.webkitBackdropFilter = 'blur(6px)';
        btn.style.border = '1px solid rgba(255, 255, 255, 0.2)';
        btn.style.boxShadow = '0 2px 6px rgba(0, 0, 0, 0.25)';
        btn.style.display = 'flex';
        btn.style.alignItems = 'center';
        btn.style.justifyContent = 'center';
        btn.style.cursor = 'pointer';
        btn.style.opacity = '0.35';
        btn.style.transition = 'opacity 0.2s ease, transform 0.2s ease, background 0.2s ease';
        btn.style.zIndex = '2147483647';
        btn.style.userSelect = 'none';
        btn.style.webkitUserSelect = 'none';
        btn.innerHTML = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.9)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="pointer-events:none;display:block;"><path d="M23 4v6h-6"></path><path d="M1 20v-6h6"></path><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>';

        btn.addEventListener('mouseenter', function() {
          btn.style.opacity = '1.0';
          btn.style.background = 'rgba(40, 40, 40, 0.85)';
          btn.style.transform = 'scale(1.08)';
        });
        btn.addEventListener('mouseleave', function() {
          btn.style.opacity = '0.35';
          btn.style.background = 'rgba(30, 30, 30, 0.6)';
          btn.style.transform = 'scale(1.0)';
        });
        btn.addEventListener('mousedown', function(e) {
          e.stopPropagation();
          btn.style.transform = 'scale(0.92)';
        });
        btn.addEventListener('mouseup', function(e) {
          e.stopPropagation();
          btn.style.transform = 'scale(1.08)';
        });
        btn.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          var svg = btn.querySelector('svg');
          if (svg) {
            svg.style.transition = 'transform 0.4s ease';
            svg.style.transform = 'rotate(360deg)';
          }
          setTimeout(function() {
            window.location.reload();
          }, 100);
        });

        document.body.appendChild(btn);
      };

      if (document.readyState === 'complete' || document.readyState === 'interactive') {
        inject();
      } else {
        document.addEventListener('DOMContentLoaded', inject);
        window.addEventListener('load', inject);
      }
    })();
  ]]
  wv:evaluateJavaScript(js)
end

local function stopClickTap(item)
  if item.clickTap then
    item.clickTap:stop()
    item.clickTap = nil
  end
end

local function closeWebView(item)
  stopClickTap(item)

  if item.webview and item.webview:isVisible() then
    item.webview:hide()
  end
  if item.canvas and item.canvas:isShowing() then
    item.canvas:hide()
  end

  if not item.keepInBackground then
    if item.webview then
      item.webview:delete()
      item.webview = nil
    end
    if item.canvas then
      item.canvas:delete()
      item.canvas = nil
    end
  end
end

local function startClickTap(item)
  if not item.closeOnBlur then return end
  stopClickTap(item)

  item.clickTap = hs.eventtap.new({
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.rightMouseDown,
    hs.eventtap.event.types.otherMouseDown,
  }, function(event)
    if not item.webview or not item.webview:isVisible() then
      stopClickTap(item)
      return false
    end

    local mousePos = hs.mouse.absolutePosition()

    -- Check if click is inside webview or outer canvas frame
    local frame = nil
    if item.canvas and item.canvas:isShowing() then
      frame = item.canvas:frame()
    elseif item.webview then
      frame = item.webview:frame()
    end

    if frame and pointInRect(mousePos, frame) then
      return false
    end

    -- Check if click is inside menubar item (allow menubar callback to handle toggle)
    if item.menubar then
      local mbFrame = item.menubar:frame()
      if mbFrame and mbFrame.w and mbFrame.w > 0 and mbFrame.h and mbFrame.h > 0 then
        local paddedMbFrame = {
          x = mbFrame.x - 2,
          y = mbFrame.y,
          w = mbFrame.w + 4,
          h = mbFrame.h + 2
        }
        if pointInRect(mousePos, paddedMbFrame) then
          return false
        end
      end
    end

    -- Clicked outside! Close webview
    closeWebView(item)
    return false -- Let the click event pass through to other windows/apps
  end)

  item.clickTap:start()
end

local function setupWebView(item)
  local w = item.width
  local h = item.height
  local padding = item.popoverStyle and (item.padding or 6) or 0
  local x, y, outerW, outerH = calculateWindowPosition(item, w, h)

  if item.popoverStyle then
    setupCanvas(item, x, y, outerW, outerH)
  end

  if item.webview then return item.webview end

  local wvX = x + padding
  local wvY = y + padding
  local wvW = w
  local wvH = h

  local wv = hs.webview.new(hs.geometry.rect(wvX, wvY, wvW, wvH), { developerExtras = true })

  if item.popoverStyle then
    wv:windowStyle({ "borderless" })
    wv:transparent(true)
    wv:level(hs.drawing.windowLevels.popUpMenu)
  end

  wv:allowTextEntry(true)
  wv:url(item.url)
  wv:windowTitle(item.title ~= "" and item.title or "WebView")

  wv:navigationCallback(function(action, webview, error)
    if item.popoverStyle then
      applyWebViewCSS(webview, (item.borderRadius or 16) - padding)
    end
    if item.showReloadButton then
      injectReloadButton(webview)
    end
  end)

  wv:windowCallback(function(action, webview, state)
    if action == "closing" then
      closeWebView(item)
    elseif action == "focusChange" and state == false then
      if item.closeOnBlur then
        local buttons = hs.eventtap.checkMouseButtons()
        local isClicking = (buttons and (buttons.left or buttons[1]))
        local isClickingMenubar = false
        if isClicking and item.menubar then
          local mbFrame = item.menubar:frame()
          if mbFrame and mbFrame.w and mbFrame.w > 0 and mbFrame.h and mbFrame.h > 0 then
            local mousePos = hs.mouse.absolutePosition()
            local paddedMbFrame = {
              x = mbFrame.x - 2,
              y = mbFrame.y,
              w = mbFrame.w + 4,
              h = mbFrame.h + 2
            }
            if pointInRect(mousePos, paddedMbFrame) then
              isClickingMenubar = true
            end
          end
        end

        if not isClickingMenubar then
          closeWebView(item)
        end
      end
    end
  end)

  item.webview = wv
  return wv
end

local function toggleWebView(item)
  if item.webview and item.webview:isVisible() then
    closeWebView(item)
  else
    local w = item.width
    local h = item.height
    local padding = item.popoverStyle and (item.padding or 6) or 0
    local x, y, outerW, outerH = calculateWindowPosition(item, w, h)

    if item.popoverStyle then
      setupCanvas(item, x, y, outerW, outerH)
      item.canvas:show()
    end

    local isReopen = (item.webview ~= nil)
    local wv = setupWebView(item)

    local wvX = x + padding
    local wvY = y + padding
    local wvW = w
    local wvH = h
    wv:frame(hs.geometry.rect(wvX, wvY, wvW, wvH))

    wv:show()
    if item.popoverStyle then
      applyWebViewCSS(wv, (item.borderRadius or 16) - padding)
    end
    if item.showReloadButton then
      injectReloadButton(wv)
    end

    if isReopen then
      if item.reloadOnOpen then
        wv:reload()
      else
        wv:evaluateJavaScript([[
          try {
            document.dispatchEvent(new Event('visibilitychange'));
            window.dispatchEvent(new Event('focus'));
          } catch (e) {}
        ]])
      end
    end

    if wv:hswindow() then wv:hswindow():focus() end

    startClickTap(item)
  end
end

function obj:stop()
  if self._loadedItems then
    for _, item in ipairs(self._loadedItems) do
      closeWebView(item)
      if item.menubar then
        item.menubar:delete()
        item.menubar = nil
      end
    end
    self._loadedItems = {}
  end
  for _, timer in ipairs(self.timer or {}) do
    timer:stop()
  end
  self.timer = {}
  self.menubar = {}
end

function obj:start()
  self:stop()
  self._loadedItems = {}

  local itemsToLoad = {}

  if self.items and type(self.items) == "table" and #self.items > 0 then
    itemsToLoad = self.items
  else
    -- Fallback to single item configuration
    itemsToLoad = {
      {
        title = self.title,
        url = self.url,
        width = self.width,
        height = self.height,
        padding = self.padding,
        keepInBackground = self.keepInBackground,
        closeOnBlur = self.closeOnBlur,
        reloadOnOpen = self.reloadOnOpen,
        showReloadButton = self.showReloadButton,
        position = self.position,
        popoverStyle = self.popoverStyle,
        borderRadius = self.borderRadius,
        borderWidth = self.borderWidth,
        offsetY = self.offsetY,
        hotkey = self.hotkey
      }
    }
  end

  for i, itemConfig in ipairs(itemsToLoad) do
    local item = createItem(itemConfig)
    table.insert(self._loadedItems, item)

    local mb = hs.menubar.new():setTitle(item.title):setClickCallback(function()
      toggleWebView(item)
    end)

    item.menubar = mb
    self.menubar[i] = mb

    -- Preload webview if keepInBackground is true and preload requested
    if item.keepInBackground and itemConfig.preload then
      setupWebView(item)
    end

    if item.hotkey then
      hs.hotkey.bindSpec(item.hotkey, function()
        toggleWebView(item)
      end)
    end

    -- Timer watchdog to ensure menubar presence
    self.timer[i] = hs.timer.new(1, function()
      if self.menubar[i] and not self.menubar[i]:isInMenuBar() then
        self.menubar[i]:returnToMenuBar()
      end
    end):start()
  end
end

return obj
