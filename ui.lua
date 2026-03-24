-- ui.lua

local mappings = {} -- Temporary table to hold mappings before saving

-- Function to create the UI window
function OpenMappingUI()
    print("|cff00ff00Opening Mapping UI|r") -- Debug statement

    if not AutoLayoutFrame then
        -- Create the frame
        AutoLayoutFrame = CreateFrame("Frame", "AutoLayoutFrame", UIParent, "BasicFrameTemplateWithInset")
        AutoLayoutFrame:SetSize(600, 350)
        AutoLayoutFrame:SetPoint("CENTER")
        AutoLayoutFrame:SetMovable(true)
        AutoLayoutFrame:EnableMouse(true)
        AutoLayoutFrame:RegisterForDrag("LeftButton")
        AutoLayoutFrame:SetScript("OnDragStart", AutoLayoutFrame.StartMoving)
        AutoLayoutFrame:SetScript("OnDragStop", AutoLayoutFrame.StopMovingOrSizing)

        -- Title
        AutoLayoutFrame.title = AutoLayoutFrame:CreateFontString(nil, "OVERLAY")
        AutoLayoutFrame.title:SetFontObject("GameFontHighlight")
        AutoLayoutFrame.title:SetPoint("LEFT", AutoLayoutFrame.TitleBg, "LEFT", 5, 0)
        AutoLayoutFrame.title:SetText("Map Layout to Resolution")

        -- Function to create a mapping row
        local function CreateMappingRow(index)
            local row = CreateFrame("Frame", nil, AutoLayoutFrame)
            row:SetSize(460, 30)
            row:SetPoint("TOP", AutoLayoutFrame, "TOP", 0, -50 - (index - 1) * 80)

            -- Label
            row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.label:SetPoint("LEFT", row, "LEFT", 0, 0)
            row.label:SetText("Mapping " .. index .. ":")

            -- Resolution Dropdown
            row.resolutionDropdown = CreateFrame("Frame", "ResolutionDropdown" .. index, row, "UIDropDownMenuTemplate")
            row.resolutionDropdown:SetPoint("LEFT", row.label, "RIGHT", 10, 0)
            UIDropDownMenu_SetWidth(row.resolutionDropdown, 150)
            UIDropDownMenu_SetText(row.resolutionDropdown, "Select Resolution")
            UIDropDownMenu_Initialize(row.resolutionDropdown, function(self, level, menuList)
                local resolutions = {
                    "1920x1080",
                    "3440x1440",
                    "2560x1440",
                    "1600x900",
                    "1366x768",
                    "Other",
                }
                for i, res in ipairs(resolutions) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = res
                    info.func = function()
                        UIDropDownMenu_SetSelectedID(row.resolutionDropdown, i)
                        mappings[index] = mappings[index] or {}
                        mappings[index].resolution = res
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end)

            -- Layout Dropdown
            row.layoutDropdown = CreateFrame("Frame", "LayoutDropdown" .. index, row, "UIDropDownMenuTemplate")
            row.layoutDropdown:SetPoint("LEFT", row.resolutionDropdown, "RIGHT", 20, 0)
            UIDropDownMenu_SetWidth(row.layoutDropdown, 150)
            UIDropDownMenu_SetText(row.layoutDropdown, "Select Layout")
            UIDropDownMenu_Initialize(row.layoutDropdown, function(self, level, menuList)
                local layoutInfo = C_EditMode.GetLayouts()
                if layoutInfo and layoutInfo.layouts then
                    local layoutList = {}
                    for layoutID, layout in pairs(layoutInfo.layouts) do
                        table.insert(layoutList, {id = layoutID, name = layout.layoutName})
                    end
                    -- Sort layouts alphabetically for better usability
                    table.sort(layoutList, function(a, b) return a.name < b.name end)
                    for i, layout in ipairs(layoutList) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = layout.name
                        info.func = function()
                            UIDropDownMenu_SetSelectedID(row.layoutDropdown, i)
                            mappings[index] = mappings[index] or {}
                            mappings[index].layoutID = layout.id
                        end
                        UIDropDownMenu_AddButton(info)
                    end
                else
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = "No Layouts Available"
                    info.notClickable = true
                    UIDropDownMenu_AddButton(info)
                end
            end)
        end

        -- Create three mapping rows
        for i = 1, 3 do
            CreateMappingRow(i)
        end

        -- Save Button
        AutoLayoutFrame.saveButton = CreateFrame("Button", nil, AutoLayoutFrame, "GameMenuButtonTemplate")
        AutoLayoutFrame.saveButton:SetPoint("BOTTOM", 0, 20)
        AutoLayoutFrame.saveButton:SetSize(150, 40)
        AutoLayoutFrame.saveButton:SetText("Save Mappings")
        AutoLayoutFrame.saveButton:SetNormalFontObject("GameFontNormalLarge")
        AutoLayoutFrame.saveButton:SetScript("OnClick", function()
            local savedMappings = {}
            for i = 1, 3 do
                local map = mappings[i]
                if map and map.resolution and map.layoutID then
                    savedMappings[map.resolution] = map.layoutID + 2 -- Apply the +2 offset here
                end
            end

            if next(savedMappings) then
                AccountLayoutDB = savedMappings
                -- Confirmation Message
                local msg = "|cff00ff00Mappings Saved:\n|r"
                for res, layoutID in pairs(AccountLayoutDB) do
                    local layout = C_EditMode.GetLayouts().layouts[layoutID - 2] -- Adjust back for display
                    local layoutName = layout and layout.layoutName or "Unknown"
                    msg = msg .. "- " .. res .. " : " .. layoutName .. "\n"
                end
                print(msg)

                -- Apply the layout for the current resolution immediately
                local width, height = GetPhysicalScreenSize()
                local currentResolution = width .. "x" .. height
                local mappedLayoutID = AccountLayoutDB[currentResolution]
                if mappedLayoutID then
                    C_EditMode.SetActiveLayout(mappedLayoutID)
                    print(string.format("|cff00ff00Applied layout '%s' for resolution '%s'.|r", 
                        C_EditMode.GetLayouts().layouts[mappedLayoutID - 2].layoutName, currentResolution))
                end

                AutoLayoutFrame:Hide()
            else
                print("|cffff0000No valid mappings to save.|r")
            end
        end)

        -- Close Button (Optional: Add a close button for user convenience)
        --AutoLayoutFrame.closeButton = CreateFrame("Button", nil, AutoLayoutFrame, "UIPanelCloseButton")
        --AutoLayoutFrame.closeButton:SetPoint("TOPRIGHT", AutoLayoutFrame, "TOPRIGHT", -5, -5)

        -- Close on Escape
        AutoLayoutFrame:SetClampedToScreen(true)
        AutoLayoutFrame:Hide()
    end -- Closing the OpenMappingUI function

    -- Show the frame every time the function is called
    AutoLayoutFrame:Show()
end
