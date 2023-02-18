--- === SpoonLoader ===
---
--- ${description}
---
--- Download: [${download_url}](${download_url})
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SpoonLoader"
obj.version = "0.1"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugisoft/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--
local function dumpTable(o) print(hs.json.encode(o or {}, true)) end

--- SpoonLoader.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('SpoonLoader')

--- Some internal variable
local TinyYaml = hs.loadSpoon('TinyYaml')

--- SpoonLoader.configPath
--- Variable
--- Configuration yaml file path. Default value is "./spoons.yaml".
obj.configPath = './spoons.yaml'

--- SpoonLoader:init()
--- Method
--- Init
function obj:init()
end

--- SpoonLoader:start()
--- Method
--- Start to load spoons
function obj:start()
    self.logger.df('start')

    local data = TinyYaml:load(self.configPath)

    for _, elem in ipairs(data) do
        local success = hs.spoons.use(elem.name, elem, true)
        if not success then
            self.logger.ef('failed to start : %s', elem.name)
        end
    end

    self.logger.df('started')
end

return obj
