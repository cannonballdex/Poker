-- poker_gui.lua Poker 23rd Anniversary Quest Script
-- Author: Cannonballdex

---@type Mq
local mq = require('mq')

local M = {}

function M.draw(state, config)
    if not state.gui_open then
        mq.cmd('/lua stop poker')
        return
    end

    local shouldDraw
    state.gui_open, shouldDraw = ImGui.Begin('Paintings Playing Poker', state.gui_open)

    if not state.gui_open then
        ImGui.End()
        mq.cmd('/lua stop poker')
        return
    end

    if not shouldDraw then
        ImGui.End()
        return
    end

    local settingsChanged = false
    local oldValue

    ImGui.Text('Settings')
    ImGui.Separator()

    oldValue = state.settings.Debug
    state.settings.Debug = ImGui.Checkbox('Debug', state.settings.Debug)
    settingsChanged = settingsChanged or (state.settings.Debug ~= oldValue)

    oldValue = state.settings.CloudyPots
    state.settings.CloudyPots = ImGui.Checkbox('Buy Cloudy Potions when low', state.settings.CloudyPots)
    settingsChanged = settingsChanged or (state.settings.CloudyPots ~= oldValue)

    oldValue = state.settings.Philter
    state.settings.Philter = ImGui.Checkbox('Use gate potions', state.settings.Philter)
    settingsChanged = settingsChanged or (state.settings.Philter ~= oldValue)

    oldValue = state.settings.Bulwark
    state.settings.Bulwark = ImGui.Checkbox('Use Bulwark of Many Portals', state.settings.Bulwark)
    settingsChanged = settingsChanged or (state.settings.Bulwark ~= oldValue)

    oldValue = state.settings.LOOP
    state.settings.LOOP = ImGui.Checkbox('Loop quest', state.settings.LOOP)
    settingsChanged = settingsChanged or (state.settings.LOOP ~= oldValue)

    ImGui.Separator()
    ImGui.Text('Campfire mode')
    ImGui.SameLine()
    ImGui.TextDisabled('(?)')
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.Text('Choose only one mode. Campfire in PoK uses a campfire in Plane of Knowledge.')
        ImGui.Text('Campfire / HighPassHold mode uses the Highpass route logic. These options cannot be enabled at the same time.')
        ImGui.EndTooltip()
    end

    local oldCampfire = state.settings.Campfire
    state.settings.Campfire = ImGui.Checkbox('Use Campfire in PoK', state.settings.Campfire)
    if state.settings.Campfire and not oldCampfire then
        state.settings.Campfire_HighPassHold = false
        config.save(state.settings)
        state.statusMessage = 'Settings saved.'
    end

    local oldHPH = state.settings.Campfire_HighPassHold
    state.settings.Campfire_HighPassHold = ImGui.Checkbox('Use Campfire / HighPassHold mode', state.settings.Campfire_HighPassHold)
    if state.settings.Campfire_HighPassHold and not oldHPH then
        state.settings.Campfire = false
        config.save(state.settings)
        state.statusMessage = 'Settings saved.'
    end

    if state.settings.Campfire ~= oldCampfire or state.settings.Campfire_HighPassHold ~= oldHPH then
        config.save(state.settings)
        state.statusMessage = 'Settings saved.'
    end

    if settingsChanged then
        config.save(state.settings)
        state.statusMessage = 'Settings saved.'
    end

    ImGui.Separator()
    ImGui.Text('Runtime')
    ImGui.Text(string.format('Running: %s', tostring(state.running)))
    ImGui.Text(string.format('Loop count: %d', state.loop_count))
    ImGui.Text(string.format('Last run time: %s', state.last_run_time_text or 'n/a'))
    ImGui.Text(string.format('Config file: %s', config.path()))

    if state.statusMessage and state.statusMessage ~= '' then
        ImGui.Separator()
        ImGui.TextWrapped(state.statusMessage)
    end

    ImGui.Separator()

    if ImGui.Button('Save Settings') then
        config.save(state.settings)
        state.statusMessage = 'Settings saved.'
    end

    ImGui.SameLine()

    if ImGui.Button('Reload Settings') then
        state.settings = config.load()
        state.statusMessage = 'Settings reloaded from disk.'
    end

    ImGui.SameLine()

    if ImGui.Button('Defaults') then
        state.settings = config.defaults()
        config.save(state.settings)
        state.statusMessage = 'Defaults loaded and saved.'
    end

    ImGui.Separator()

    if ImGui.Button('Stop After Current Run') then
        state.settings.LOOP = false
        config.save(state.settings)
        state.statusMessage = 'Loop disabled. Script will stop after the current run.'
    end

    ImGui.SameLine()

    if ImGui.Button('Save + Stop') then
        state.settings.LOOP = false
        config.save(state.settings)
        state.running = false
        state.statusMessage = 'Stopping script.'
    end

    ImGui.SameLine()

    if ImGui.Button('Exit') then
        mq.cmd('/lua stop poker')
    end

    ImGui.End()
end

return M