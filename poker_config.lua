-- poker_config.lua Poker 23rd Anniversary Quest Script
-- Author: Cannonballdex

---@type Mq
local mq = require('mq')

local M = {}

local function joinPath(...)
    return table.concat({ ... }, '\\')
end

local function dir_exists(path)
    local ok, _, code = os.rename(path, path)
    if ok then
        return true
    end
    if code == 13 then
        return true
    end
    return false
end

local function file_exists(path)
    local file = io.open(path, 'r')
    if file ~= nil then
        file:close()
        return true
    end
    return false
end

local function ensure_dir(path)
    if not path or path == '' then
        return false
    end

    local p = tostring(path):gsub('[\\/]+$', '')
    if dir_exists(p) then
        return true
    end

    local ok, lfs = pcall(require, 'lfs')
    if ok and lfs and lfs.mkdir then
        pcall(lfs.mkdir, p)
        if dir_exists(p) then
            return true
        end
    end

    pcall(function()
        if package.config:sub(1, 1) == '\\' then
            os.execute('mkdir "' .. p .. '" >nul 2>&1')
        else
            os.execute('mkdir -p "' .. p .. '" >/dev/null 2>&1')
        end
    end)

    return dir_exists(p)
end

local function sanitize_filename(name)
    name = tostring(name or 'Unknown')
    return name:gsub('[<>:"/\\|%?%*]', '_')
end

local defaults = {
    Debug = false,
    Campfire = false,
    CloudyPots = true,
    Philter = true,
    Bulwark = true,
    Campfire_HighPassHold = false,
    LOOP = false,
}

local function deepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function serializeValue(v)
    local t = type(v)

    if t == 'boolean' or t == 'number' then
        return tostring(v)
    elseif t == 'string' then
        return string.format('%q', v)
    else
        error('Unsupported config value type: ' .. t)
    end
end

local function saveTable(path, tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)

    local lines = { 'return {' }
    for _, k in ipairs(keys) do
        lines[#lines + 1] = string.format('    %s = %s,', k, serializeValue(tbl[k]))
    end
    lines[#lines + 1] = '}'

    local f, err = io.open(path, 'w')
    if not f then
        error('Could not open config file for writing: ' .. tostring(err))
    end

    f:write(table.concat(lines, '\n'))
    f:close()
end

local function mergeDefaults(loaded)
    local result = deepCopy(defaults)

    if type(loaded) ~= 'table' then
        return result
    end

    for k, v in pairs(loaded) do
        if result[k] ~= nil then
            result[k] = v
        end
    end

    return result
end

local baseConfigDir = tostring(mq.configDir or joinPath(mq.TLO.MacroQuest.Path(), 'config'))
baseConfigDir = baseConfigDir:gsub('[\\/]+$', '')

local preferredPokerDir = joinPath(baseConfigDir, 'Poker')

local activeConfigDir
if ensure_dir(preferredPokerDir) then
    activeConfigDir = preferredPokerDir
else
    activeConfigDir = baseConfigDir
    print('\ay[poker] Could not create Config\\Poker. Saving settings in Config instead.')
end

local charName = sanitize_filename(mq.TLO.Me.Name() or 'Unknown')
local configFile = joinPath(activeConfigDir, string.format('%s_poker_settings.lua', charName))

function M.validate(settings)
    if settings.Campfire and settings.Campfire_HighPassHold then
        settings.Campfire = false
    end
    return settings
end

function M.load()
    local settings = deepCopy(defaults)

    if file_exists(configFile) then
        local ok, loaded = pcall(dofile, configFile)
        if ok then
            settings = mergeDefaults(loaded)
        else
            print('\ar[poker] Failed to load config. Using defaults.')
            print('\ar[poker] ' .. tostring(loaded))
        end
    else
        saveTable(configFile, settings)
    end

    return M.validate(settings)
end

function M.save(settings)
    settings = M.validate(settings)
    saveTable(configFile, settings)
end

function M.defaults()
    return deepCopy(defaults)
end

function M.path()
    return configFile
end

return M