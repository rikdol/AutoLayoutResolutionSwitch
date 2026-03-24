-- Initialize the frame and register events
local layloFrame = CreateFrame("FRAME", "LayLo_frame")
layloFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Define the offset for default layouts
local DEFAULT_LAYOUT_OFFSET = 2

-- Function to get the current screen resolution
local function GetCurrentResolution()
    local width, height = GetPhysicalScreenSize()
    return width .. "x" .. height
end

-- Function to find the layoutID by layout name
local function GetLayoutIDByName(layoutName)
    local layoutInfo = C_EditMode.GetLayouts()
    if not layoutInfo or not layoutInfo.layouts then
        print("|cffff0000Error: Could not retrieve layouts.|r")
        return nil
    end
    for layoutID, layout in pairs(layoutInfo.layouts) do
        if layout.layoutName == layoutName then
            return layoutID
        end
    end
    return nil
end

-- Function to print available layouts
local function PrintAvailableLayouts()
    local layoutInfo = C_EditMode.GetLayouts()
    if not layoutInfo or not layoutInfo.layouts then
        print("|cffff0000Error: Could not retrieve layouts.|r")
        return
    end
    print("|cff00ff00Available Layouts:|r")
    for layoutID, layout in pairs(layoutInfo.layouts) do
        print("|cff00ff00- layoutID: " .. layoutID .. ", Name: '" .. layout.layoutName .. "'|r")
    end
end

-- Event handler function
layloFrame:SetScript("OnEvent", function(self, event)
    -- Get the current screen resolution
    local resolution = GetCurrentResolution()
    print("|cff00ff00Resolution: [" .. resolution .. "]|r")
    
    -- Print available layouts
    PrintAvailableLayouts()
    
    -- Define the mapping between resolutions and layout names
    local resolutionLayouts = {
        ["3440x1440"] = "PC 3440",
        ["1920x1080"] = "Laptop 1080",
        -- Add more resolutions and their corresponding layout names here
    }

    -- Get the layout name for the current resolution
    local layoutName = resolutionLayouts[resolution]
    if layoutName then
        -- Find the layoutID by name
        local layoutID = GetLayoutIDByName(layoutName)
        print("Layout with name: " .. layoutName .. " has ID: " .. (layoutID or "nil"))
        if layoutID then
            -- Calculate the actual layout ID by adding the offset
            local actualLayoutID = layoutID + DEFAULT_LAYOUT_OFFSET
            print("Actual layoutID to set: " .. actualLayoutID)
            
            -- Get the currently active layout ID
            --local activeLayoutID = C_EditMode.GetActiveLayout()
			local layoutInfo = C_EditMode.GetLayouts()
			local activeLayoutID = layoutInfo.activeLayout
			print("ActivelayoutID = "..activeLayoutID)
			
            print("Current activeLayoutID: " .. activeLayoutID)
            
            -- Check and set the new layout if different
            if activeLayoutID ~= actualLayoutID then
                print("|cff00ff00Switching active layout to '" .. layoutName .. "'.|r")
                C_EditMode.SetActiveLayout(actualLayoutID)
                
                -- Verify the change
                local newActiveLayoutID = C_EditMode.GetActiveLayout()
                print("New activeLayoutID: " .. newActiveLayoutID)
                
                if newActiveLayoutID == actualLayoutID then
                    print("|cff00ff00Layout '" .. layoutName .. "' has been loaded.|r")
                else
                    print("|cffff0000Failed to switch to '" .. layoutName .. "'.|r")
                end
            else
                print("|cffffff00Layout '" .. layoutName .. "' is already active.|r")
            end
        else
            print("|cffff0000Layout '" .. layoutName .. "' not found.|r")
        end
    else
        print("|cffff0000No layout configured for resolution: " .. resolution .. ".|r")
    end
end)
