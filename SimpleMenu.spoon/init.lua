local obj = {}
obj.__index = obj

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
    -- createMenuFn(menuData.menu)

    -- self.menubar = hs.menubar.new():setTitle(menuData.title):setMenu(menuData.menu)

    -- self.timer = hs.timer.new(1, function()
    --     if not self.menubar:isInMenuBar() then
    --         self.menubar:returnToMenuBar()
    --     end
    -- end):start()
end

return obj
