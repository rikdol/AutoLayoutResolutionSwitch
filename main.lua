-- main.lua
-- Core logic: detect resolution on login and switch to the matching layout

local ADDON_PREFIX = "|cff00ccff[AutoLayout]|r "

local frame = CreateFrame("Frame", "AutoLayoutSwitch_Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event)
    -- Get current screen resolution
    local width, height = GetPhysicalScreenSize()
    local widthStr  = tostring(width)
    local heightStr = tostring(height)
    print(ADDON_PREFIX .. string.format("Resolution detected: %sx%s", widthStr, heightStr))

    -- Find a layout whose name contains this resolution
    local layoutName, activeID = FindLayoutForResolution(widthStr, heightStr)

    if not layoutName then
        print(ADDON_PREFIX .. "|cffff0000No layout found matching this resolution.|r")
        print(ADDON_PREFIX .. "Tip: name a layout with \"" .. widthStr .. "\" or \"" .. heightStr .. "\" in it.")
        return
    end

    -- Check if it's already active
    local layoutInfo = C_EditMode.GetLayouts()
    local currentActiveID = layoutInfo.activeLayout

    if currentActiveID == activeID then
        print(ADDON_PREFIX .. string.format("Layout \"%s\" is already active.", layoutName))
        return
    end

    -- Switch
    print(ADDON_PREFIX .. string.format("Switching to \"%s\" ...", layoutName))
    C_EditMode.SetActiveLayout(activeID)

    -- Verify
    local newInfo = C_EditMode.GetLayouts()
    if newInfo.activeLayout == activeID then
        print(ADDON_PREFIX .. string.format("|cff00ff00Layout \"%s\" activated.|r", layoutName))
    else
        print(ADDON_PREFIX .. string.format("|cffff0000Failed to activate \"%s\".|r", layoutName))
    end
end)
