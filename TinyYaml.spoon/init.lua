--- === TinyYaml ===
---
--- ${description}
---
--- Download: [${download_url}](${download_url})
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "TinyYaml"
obj.version = "0.1"
obj.author = "Inkyu Park <badugiss@gmail.com>"
obj.homepage = "https://github.com/badugisoft/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- TinyYaml.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new("TinyYaml")

--- Some internal variable
local yaml = dofile(hs.spoons.resourcePath("api7-lua-tinyyaml/tinyyaml.lua"))

--- TinyYaml.Parser
--- Variable
--- Parser
obj.Parser = yaml.Parser

--- TinyYaml:decode()
--- Method
--- decode
function obj:decode(source, options) return yaml.parse(source, options) end

--- TinyYaml:load()
--- Method
--- load
function obj:load(path, options)
    local file = io.open(path, "r")

    if file ~= nil then
        local tbl  = yaml.parse(file:read('*all'), options)
        file:close()
        return tbl
    end

    return nil
end

return obj
