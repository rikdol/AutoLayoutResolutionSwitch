-- utils.lua
-- Helper functions for Auto Layout Switch

-- The Edit Mode API returns user-created layouts in .layouts (1-indexed),
-- but SetActiveLayout() expects an index where 1 and 2 are the built-in
-- presets (Modern and Classic). So user layout #1 = activeLayout #3.
local PRESET_OFFSET = 2

--- Convert a user-layout index to the activeLayout index used by SetActiveLayout().
-- @param userIndex number  The 1-based index in C_EditMode.GetLayouts().layouts
-- @return number  The ID to pass to C_EditMode.SetActiveLayout()
function ToActiveLayoutID(userIndex)
    return userIndex + PRESET_OFFSET
end

--- Convert an activeLayout index back to the user-layout index.
-- @param activeID number  The value from layoutInfo.activeLayout
-- @return number  The 1-based index in .layouts (or nil if it's a preset)
function ToUserLayoutIndex(activeID)
    local idx = activeID - PRESET_OFFSET
    if idx < 1 then return nil end
    return idx
end

--- Get all user-created layouts as a simple list.
-- @return table|nil  Array of {userIndex, name} or nil on error
function GetUserLayouts()
    local layoutInfo = C_EditMode.GetLayouts()
    if not layoutInfo or not layoutInfo.layouts then return nil end

    local result = {}
    for i, layout in pairs(layoutInfo.layouts) do
        table.insert(result, { userIndex = i, name = layout.layoutName })
    end
    return result
end

--- Find a layout whose name contains a resolution component.
-- Search priority:
--   1. Full resolution string  (e.g. "3440x1440")
--   2. Width as a standalone number (e.g. "3440")
--   3. Height as a standalone number (e.g. "1440")
-- "Standalone" means the number is surrounded by non-digit characters
-- (or sits at the start/end of the name), so "1080" matches "Laptop 1080"
-- but "10800" would not accidentally match.
-- @param width  string  The horizontal pixel count (e.g. "3440")
-- @param height string  The vertical pixel count   (e.g. "1440")
-- @return string|nil layoutName
-- @return number|nil activeLayoutID  (ready for SetActiveLayout)
function FindLayoutForResolution(width, height)
    local layouts = GetUserLayouts()
    if not layouts then return nil, nil end

    local fullRes = width .. "x" .. height

    -- Helper: check if `name` contains `number` as a standalone token
    local function containsNumber(name, number)
        -- Pattern: number not preceded or followed by another digit
        -- We check three cases: start-of-string, end-of-string, or surrounded by non-digits
        return name:find("^" .. number .. "%D")    -- at start, followed by non-digit
            or name:find("%D" .. number .. "$")     -- at end, preceded by non-digit
            or name:find("%D" .. number .. "%D")    -- in middle
            or name == number                        -- exact match
            or name:find("^" .. number .. "$")       -- exact match (redundant safety)
    end

    -- Priority 1: full resolution string in name (e.g. "3440x1440")
    for _, l in ipairs(layouts) do
        if l.name:find(fullRes, 1, true) then
            return l.name, ToActiveLayoutID(l.userIndex)
        end
    end

    -- Priority 2: width as standalone number
    for _, l in ipairs(layouts) do
        if containsNumber(l.name, width) then
            return l.name, ToActiveLayoutID(l.userIndex)
        end
    end

    -- Priority 3: height as standalone number
    for _, l in ipairs(layouts) do
        if containsNumber(l.name, height) then
            return l.name, ToActiveLayoutID(l.userIndex)
        end
    end

    return nil, nil
end

--- Print all available layouts to chat (for debugging / slash command).
function ListAllLayouts()
    local layouts = GetUserLayouts()
    if not layouts then
        print("|cffff0000Error: Could not retrieve layouts.|r")
        return
    end
    print("|cff00ff00Available Edit Mode Layouts:|r")
    for _, l in ipairs(layouts) do
        print(string.format("  |cff00ff00#%d  \"%s\"  (activeID: %d)|r",
            l.userIndex, l.name, ToActiveLayoutID(l.userIndex)))
    end
end
