-- commands.lua
-- Slash commands for debugging and information

local ADDON_PREFIX = "|cff00ccff[AutoLayout]|r "

local function HandleSlashCommand(msg)
    local command = msg:match("^(%S*)") or ""
    command = command:lower()

    if command == "list" then
        ListAllLayouts()

    elseif command == "status" then
        local width, height = GetPhysicalScreenSize()
        local widthStr, heightStr = tostring(width), tostring(height)
        print(ADDON_PREFIX .. string.format("Resolution: %sx%s", widthStr, heightStr))

        local layoutName, activeID = FindLayoutForResolution(widthStr, heightStr)
        if layoutName then
            print(ADDON_PREFIX .. string.format("Matched layout: \"%s\" (activeID: %d)", layoutName, activeID))
        else
            print(ADDON_PREFIX .. "|cffff0000No matching layout found.|r")
        end

        local layoutInfo = C_EditMode.GetLayouts()
        local currentIdx = ToUserLayoutIndex(layoutInfo.activeLayout)
        if currentIdx then
            local current = layoutInfo.layouts[currentIdx]
            print(ADDON_PREFIX .. string.format("Currently active: \"%s\" (activeID: %d)", 
                current and current.layoutName or "?", layoutInfo.activeLayout))
        else
            print(ADDON_PREFIX .. string.format("Currently active: preset (activeID: %d)", layoutInfo.activeLayout))
        end

    elseif command == "switch" then
        -- Manually trigger the switch logic
        local width, height = GetPhysicalScreenSize()
        local widthStr, heightStr = tostring(width), tostring(height)
        local layoutName, activeID = FindLayoutForResolution(widthStr, heightStr)
        if layoutName then
            C_EditMode.SetActiveLayout(activeID)
            print(ADDON_PREFIX .. string.format("|cff00ff00Switched to \"%s\".|r", layoutName))
        else
            print(ADDON_PREFIX .. "|cffff0000No matching layout for current resolution.|r")
        end

    else
        print(ADDON_PREFIX .. "Commands:")
        print("  |cffffd700/alt list|r    - Show all Edit Mode layouts")
        print("  |cffffd700/alt status|r  - Show current resolution and matched layout")
        print("  |cffffd700/alt switch|r  - Manually trigger layout switch")
    end
end

SLASH_ALTSWITCH1 = "/alt"
SlashCmdList["ALTSWITCH"] = HandleSlashCommand
