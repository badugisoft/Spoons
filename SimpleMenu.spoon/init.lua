local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SimpleMenu"
obj.version = "0.1"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugiss/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new(obj.name)

obj.menu = nil

obj.timer = {}
obj.menubar = {}

local keySymbols = {
    cmd = '⌘',
    command = '⌘',
    ctrl = '^',
    control = '^',
    shift = '⇧',
    option = '⌥',
    alt = '⌥'
}

local function keyToString(key) return keySymbols[key:lower()] or key:upper() end

local function hotkeyToString(hotkey)
    local keys = {}

    for _, v in ipairs(hotkey[1]) do table.insert(keys, keyToString(v)) end
    table.insert(keys, hotkey[2]:upper())

    return table.concat(keys, '+')
end

local function createMenuFn(menu)
    for i in ipairs(menu) do
        if menu[i].menu then
            createMenuFn(menu[i].menu)
        elseif menu[i].exec then
            menu[i].fn = function() hs.execute(menu[i].exec) end
        elseif menu[i].eval then
            local fn = load(menu[i].eval);
            if fn then menu[i].fn = fn end
        end

        if menu[i].fn and menu[i].hotkey then
            hs.hotkey.bindSpec(menu[i].hotkey, menu[i].fn)
            menu[i].title = menu[i].title .. ' [' ..
                hotkeyToString(menu[i].hotkey) .. ']'
        end
    end
end

function obj:read(path)
    local lower = path:lower()
    local data

    if lower:sub(- #'.json') == '.json' then
        data = hs.json.read(path)
    elseif lower:sub(- #'.yaml') == '.yaml' or lower:sub(- #'.yml') == '.yml' then
        local yaml = hs.loadSpoon("TinyYaml")
        data = yaml.read(path)
    end

    return data
end

function obj:start()
  for i, v in ipairs(self.menu) do
    createMenuFn(self.menu[i].menu)

    self.menubar[i] = hs.menubar.new():setTitle(self.menu[i].title):setMenu(self.menu[i].menu)

    self.timer[i] = hs.timer.new(1, function()
        if not self.menubar[i]:isInMenuBar() then
            self.menubar[i]:returnToMenuBar()
        end
    end):start()
  end
end

return obj
