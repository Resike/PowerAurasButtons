--[[
	PowerAurasButtons
	
	Module: ButtonsConfig
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons
local ModuleFrame      = CoreFrame:RegisterModule("ButtonsConfig", { "Buttons", "Config" })
local Modules          = CoreFrame.Modules
--[[
----------------------------------------------------------------------------------------------------
OnCreateConfigurationFrame

Creates the configuration frame for the Config module.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnCreateConfigurationFrame(name)
	-- Only do this if the name matches the module name.
	if(name ~= ModuleFrame.Name and name) then return end
	-- Make the parent frame.
	local ActionEditor = CreateFrame("Frame", nil, UIParent)
	ActionEditor:SetHeight(51)
	-- Label.
	ActionEditor.DisplayLabel = Modules.Config:CreateHeaderWidget("Module: Buttons", ActionEditor, 
		0)
	-- Display glows?
	ActionEditor.DisplayGlow = Modules.Config:CreateButtonWidget(ActionEditor, "Display Glow")
	ActionEditor.DisplayGlow:SetPoint("TOP", ActionEditor, "TOP", 0, -25)
	ActionEditor.DisplayGlow:SetScript("OnClick", function(self)
			-- Toggle self.
			if(self.Selected) then
				self:Deselect()
				Modules.Config:UpdateActionData("glow", nil)
			else
				self:Select()
				Modules.Config:UpdateActionData("glow", true)
			end
		end)
	-- Tooltips (localization handled by the config module)
	Modules.Config:RegisterConfigTooltip(ActionEditor.DisplayGlow, { 
		title = "Display Glow", 
		text = "Displays the shiny glow on the button when this aura is active."
	})
	-- Add the necessary functions.
	ActionEditor.UpdateAction = function(self, actionData)
		if(actionData["glow"]) then
			ActionEditor.DisplayGlow:Select()
		else
			ActionEditor.DisplayGlow:Deselect()
		end
	end
	-- Done.
	Modules.Config:RegisterActionConfigFrame(ActionEditor, 2)
end
--[[
----------------------------------------------------------------------------------------------------
OnCreateInterfaceOptionsFrame

Creates the interface options configuration frame for the Config module.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnCreateInterfaceOptionsFrame(name)
	-- Only do this if the name matches the module name.
	if(name ~= ModuleFrame.Name and name) then return end
	-- Base frame.
	local InterfaceOptions = Modules.Config:RegisterInterfaceOptionsFrame("Module: Buttons")
	-- Two things needed: Slider, checkbutton. Slider first.
	InterfaceOptions.ThrottleSlider = CreateFrame("Slider", "PowerAurasButtons_ButtonsThrottle", InterfaceOptions, "OptionsSliderTemplate")
	InterfaceOptions.ThrottleSlider:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 20, -80)
	InterfaceOptions.ThrottleSlider:SetMinMaxValues(0.05, 1)
	InterfaceOptions.ThrottleSlider:SetValue(CoreFrame:GetModuleSetting("Buttons", "Throttle"))
	InterfaceOptions.ThrottleSlider:SetValueStep(0.05)
	InterfaceOptions.ThrottleSlider:SetWidth(250)
	
	PowerAurasButtons_ButtonsThrottleLow:SetText("0.05")
	PowerAurasButtons_ButtonsThrottleHigh:SetText("1")
	PowerAurasButtons_ButtonsThrottleText:SetText(CoreFrame.L["Update Throttle"] .. " (" .. CoreFrame:GetModuleSetting("Buttons", "Throttle") .. " " .. CoreFrame.L["Seconds"] .. ")")
	-- Update on value change.
	InterfaceOptions.ThrottleSlider:SetScript("OnValueChanged", function(self)
		-- Set it.
		CoreFrame:SetModuleSetting("Buttons", "Throttle", tonumber(string.format("%.2f", self:GetValue()), 10))	
		-- Update label too.
		PowerAurasButtons_ButtonsThrottleText:SetText(CoreFrame.L["Update Throttle"] .. " (" .. tonumber(string.format("%.2f", self:GetValue()), 10) .. " " .. CoreFrame.L["Seconds"] .. ")")
	end)
	-- Checkbutton.
	InterfaceOptions.Blizz = CreateFrame("CheckButton", "PowerAurasButtons_ButtonsBlizz", 
		InterfaceOptions, "ChatConfigCheckButtonTemplate")
	InterfaceOptions.Blizz:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -115)
	PowerAurasButtons_ButtonsBlizzText:SetText(CoreFrame.L["Register Blizzard Buttons"])
	InterfaceOptions.Blizz:SetChecked(CoreFrame:GetModuleSetting("Buttons", "RegisterBlizzardButtons"))
	-- Save on click.
	InterfaceOptions.Blizz:SetScript("OnClick", function(self)
		-- Requires a reload to take effect, so get a glowbox ready and running.
		Modules.Config:CreateGlowBoxWidget(InterfaceOptions)
		-- Save.
		CoreFrame:SetModuleSetting("Buttons", "RegisterBlizzardButtons", self:GetChecked())
	end)
	-- One more checkbutton.
	InterfaceOptions.SGlow = CreateFrame("CheckButton", "PowerAurasButtons_ButtonsShowBlizzGlows", 
		InterfaceOptions, "ChatConfigCheckButtonTemplate")
	InterfaceOptions.SGlow:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -140)
	PowerAurasButtons_ButtonsShowBlizzGlowsText:SetText(CoreFrame.L["Show Blizzard Glows"])
	InterfaceOptions.SGlow:SetChecked(
		CoreFrame:GetModuleSetting("Buttons", "ShowBlizzardGlows"))
	-- Save on click.
	InterfaceOptions.SGlow:SetScript("OnClick", function(self)
		-- Save.
		CoreFrame:SetModuleSetting("Buttons", "ShowBlizzardGlows", self:GetChecked())
	end)
--	-- And another.
--	InterfaceOptions.Cache = CreateFrame("CheckButton", "PowerAurasButtons_ButtonsCacheActions", 
--		InterfaceOptions, "ChatConfigCheckButtonTemplate")
--	InterfaceOptions.Cache:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -165)
--	PowerAurasButtons_ButtonsCacheActionsText:SetText(CoreFrame.L["Enable Action Cache"])
--	InterfaceOptions.Cache:SetChecked(
--		CoreFrame:GetModuleSetting("Buttons", "EnableCache"))
--	-- Save on click.
--	InterfaceOptions.Cache:SetScript("OnClick", function(self)
--		-- Requires a reload to take effect, so get a glowbox ready and running.
--		Modules.Config:CreateGlowBoxWidget(InterfaceOptions)
--		-- Save.
--		CoreFrame:SetModuleSetting("Buttons", "EnableCache", self:GetChecked())
--	end)
	
	-- Buttons blacklist.
	InterfaceOptions.BlacklistTitle = InterfaceOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	InterfaceOptions.BlacklistTitle:SetText(CoreFrame.L["Registered Buttons"])
	InterfaceOptions.BlacklistTitle:SetPoint("TOP", InterfaceOptions, "TOP", 0, -190)
	-- Make a scrolly area.
	InterfaceOptions.Buttons = CreateFrame("Frame", nil, InterfaceOptions)
	InterfaceOptions.Buttons:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	})
	InterfaceOptions.Buttons:SetBackdropColor(0, 0, 0, 0.75)
	InterfaceOptions.Buttons:SetBackdropBorderColor(0.4, 0.4, 0.4)
	InterfaceOptions.Buttons:SetPoint("TOP", InterfaceOptions, "TOP", 0, -205)
	InterfaceOptions.Buttons:SetHeight(200)	
	InterfaceOptions.Buttons:SetWidth(375)	
	-- List frame needs a scroll frame.
	InterfaceOptions.Buttons.Scroll = CreateFrame("ScrollFrame", "PowerAurasButtons_ButtonsScrollFrame", InterfaceOptions.Buttons, 
		"UIPanelScrollFrameTemplate")
	InterfaceOptions.Buttons.Scroll:SetPoint("TOPLEFT", InterfaceOptions.Buttons, "TOPLEFT", 5, -5)
	InterfaceOptions.Buttons.Scroll:SetPoint("BOTTOMRIGHT", InterfaceOptions.Buttons, "BOTTOMRIGHT", -26, 4)	
	-- Scroll frame needs something to actually scroll.
	InterfaceOptions.Buttons.List = CreateFrame("Frame", nil, InterfaceOptions.Buttons.Scroll)
	InterfaceOptions.Buttons.List:SetPoint("TOPLEFT", InterfaceOptions.Buttons.Scroll, "TOPLEFT")
	-- Height needs to be set.
	InterfaceOptions.Buttons.List:SetHeight(0)
	-- The height needs to match the content, but the width can be that of the box...
	InterfaceOptions.Buttons.List:SetWidth(350)
	-- Add the list frame as a scroll child of our SUPER SCROLL FRAME.
	InterfaceOptions.Buttons.Scroll:SetScrollChild(InterfaceOptions.Buttons.List)
	-- Store the row frames in this table - we'll reuse them as needed.
	InterfaceOptions.Buttons.List.Items = {}
	InterfaceOptions.Buttons.List.Rows = {}
	-- Make a small function, hook it to OnShow. It'll scan the Buttons and update the list.
	local scanButtons
	scanButtons = function()
		-- Make a table of all Buttons that can be enabled/disabled.
		wipe(InterfaceOptions.Buttons.List.Items)
		for buttonID, _ in pairs(Modules.Buttons:GetButtons()) do
			tinsert(InterfaceOptions.Buttons.List.Items, buttonID)
		end
		-- Merge in the configured ones.
		for buttonID, state in pairs(CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")) do
			if(not tContains(InterfaceOptions.Buttons.List.Items, buttonID)) then
				tinsert(InterfaceOptions.Buttons.List.Items, buttonID)
			end
		end
		-- Sort list.
		sort(InterfaceOptions.Buttons.List.Items)
		-- Hide existing rows.
		for _, row in pairs(InterfaceOptions.Buttons.List.Rows) do
			row:Hide()
		end
		-- Using that, fill in the rows.
		for i, buttonID in pairs(InterfaceOptions.Buttons.List.Items) do
			-- Make rows dynamically and reuse existing ones.
			if(not InterfaceOptions.Buttons.List.Rows[i]) then
				local row = CreateFrame("Frame", nil, InterfaceOptions.Buttons.List)
				-- Add textures.
				row.Texture = row:CreateTexture(nil, "BACKGROUND")
				row.Texture:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
				row.Texture:SetAllPoints(row)
				row.Texture:SetVertexColor(1, 1, 1, 0.15)
				-- Height, anchor.
				row:SetHeight(20)
				row:SetPoint("TOPLEFT", InterfaceOptions.Buttons.List, "TOPLEFT", 0, -((i-1)*20))
				row:SetPoint("TOPRIGHT", InterfaceOptions.Buttons.List, "TOPRIGHT", 0, -((i-1)*20))
				-- Label.
				row.Label = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				row.Label:SetHeight(20)
				row.Label:SetPoint("TOPLEFT", row, "TOPLEFT", 10, 0)
				row.Label:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 10, 0)
				-- And a delete button.
				row.Button = CreateFrame("Button", nil, row)
				row.Button:SetPoint("RIGHT", row, "RIGHT", -2, 0)
				row.Button:SetWidth(16)
				row.Button:SetHeight(16)
				-- Register the row.
				InterfaceOptions.Buttons.List.Rows[i] = row
				-- And when you click, we toggle.
				row.Button:SetScript("OnClick", function()
					local id = row.Label:GetText()
					-- Toggle state.
					CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")[id] = 
						not CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")[buttonID]
					-- ReloadUI is needed :)
					Modules.Config:CreateGlowBoxWidget(InterfaceOptions)
					-- Rescan.
					scanButtons()
				end)
				-- Tooltip.
				Modules.Config:RegisterConfigTooltip(row.Button, {
					override = function()
						-- Check status.
						if(not CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")[buttonID]) then
							GameTooltip:SetText(CoreFrame.L["Disable Button"])
							GameTooltip:AddLine(CoreFrame.L["Click to disable this button from being registered and processed."], 1, 1, 1, 1)
						else
							GameTooltip:SetText(CoreFrame.L["Enable Button"])
							GameTooltip:AddLine(CoreFrame.L["Click to enable this button for processing."], 1, 1, 1, 1)
						end
					end
				})
			end
			-- Get row.
			local row = InterfaceOptions.Buttons.List.Rows[i]
			-- Set stuff.
			row.Label:SetText(buttonID)
			-- Is the button enabled?
			if(not CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")[buttonID]) then
				-- Enabled, so show disable stuff and color the background greenish.
				row.Button:SetNormalTexture("Interface\\FriendsFrame\\StatusIcon-DnD")
				row.Button:SetHighlightTexture("Interface\\FriendsFrame\\StatusIcon-DnD", "BLEND")
				row.Button:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5)
				row.Button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0)
				row.Texture:SetVertexColor(0.3, 0.8, 0.3, 0.6)
			else
				-- Disabled. Show enable stuff and color BG red.
				row.Button:SetNormalTexture("Interface\\FriendsFrame\\StatusIcon-Online")
				row.Button:SetHighlightTexture("Interface\\FriendsFrame\\StatusIcon-Online", "BLEND")
				row.Button:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5)
				row.Button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0)
				row.Texture:SetVertexColor(1.0, 0.5, 0.5, 1.0)
			end
			-- Add height to the list.
			InterfaceOptions.Buttons.List:SetHeight(i*20)
			row:Show()
		end
	end
	-- Set the script.
	InterfaceOptions:SetScript("OnShow", scanButtons)
	-- Optimize!
	InterfaceOptions.Optimize = CreateFrame("Button", "PowerAurasButtons_OptimizeStuff", InterfaceOptions, "UIPanelButtonTemplate")
	InterfaceOptions.Optimize:SetPoint("TOPRIGHT", InterfaceOptions.Buttons, "BOTTOMRIGHT", 0, -5)
	InterfaceOptions.Optimize:SetSize(118, 23)
	InterfaceOptions.Optimize:SetText(CoreFrame.L["Optimize"])
	InterfaceOptions.Optimize:SetScript("OnClick", function(self)
		-- Create a copy of the buttons list.
		local buttons = {}
		for id, button in pairs(Modules.Buttons:GetButtons()) do
			-- Resolve global ref if needed.
			if(button == true and _G[id]) then
				button = _G[id]
			end
			-- Copy entry.
			if(button and button ~= true) then
				buttons[id] = button
			end
		end
		-- Merge in blacklisted ones too.
		for buttonID, state in pairs(CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")) do
			buttons[buttonID] = _G[buttonID] or buttons[buttonID] or nil
		end
		-- Settings table shortcut.
		local blacklist = CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")
		-- Go over all auras and their actions.
		local settingTables = { PowerAurasButtons_AurasDB, PowerAurasButtons_CharacterAurasDB }
		for _, settingTable in pairs(settingTables) do
			for auraID, actions in pairs(settingTable) do
				for actionID, action in pairs(actions) do
					-- Sanity check.
					if(type(action) == "table") then
						-- Go over remaining buttons.
						for id, button in pairs(buttons) do
							-- Make sure it's a valid button.
							local buttonActionID = button and (button._state_action or button.action)
							if(type(buttonActionID) == "number") then
								-- Get action data.
								local actionType, actionID = GetActionInfo(buttonActionID)
								-- Is it a macro?
								if(actionType ~= "macro") then
									-- Right, valid action?
									if(actionType == action["type"] and actionID == action["id"]) then
										-- Enable!
										buttons[id] = nil
										blacklist[id] = false
									end
								else
									-- Perma-enable!
									buttons[id] = nil
									blacklist[id] = false
								end
							end
						end
					end
				end
			end
		end
		-- Blacklist the rest of the buttons.
		for id, button in pairs(buttons) do
			if(button) then
				blacklist[id] = true
			else
				blacklist[id] = false
			end
		end
		-- Rescan.
		scanButtons()
		-- ReloadUI is needed :)
		Modules.Config:CreateGlowBoxWidget(InterfaceOptions)
	end)
	-- Tooltips.
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.ThrottleSlider, {
		title = "Update Throttle",
		text = "Controls the throttle for button updates. This affects both " .. "performance and responsiveness, so leaving it at around 0.05 to 0.1 is a good idea."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.Blizz, {
		title = "Register Blizzard Buttons",
		text = "Select this if you want Blizzard's default action buttons to be included. " .. "If you are using another addon like Bartender or Dominos, you can disable this."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.SGlow, {
		title = "Show Blizzard Glows |cFFFF0000*BETA*|r",
		text = "Select this if you want Blizzard's default action button glows to be displayed."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.Optimize, {
		title = "Optimize |cFFFF0000*BETA*|r",
		text = "Scans your current configuration and automatically disables any buttons that are not used. " .. "Buttons that contain macros are not disabled with this tool.\n\nHold Shift to also include buttons " .. "that are not visible in the scan."
	})
end
--[[
----------------------------------------------------------------------------------------------------
OnInitialize

Fired by the module handler. Put all the loading code into here.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnInitialize()
	-- Register module events for config frames.
	CoreFrame:RegisterModuleEventListener("OnCreateConfigurationFrame", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnCreateInterfaceOptionsFrame", ModuleFrame)
	-- Done.
	return true
end
