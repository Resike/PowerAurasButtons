--[[
	PowerAurasButtons
	
	Module: TimerStacksConfig
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons
local ModuleFrame      = CoreFrame:RegisterModule("TimerStacksConfig", { "TimerStacks", "Config" })
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
	ActionEditor.DisplayLabel = Modules.Config:CreateHeaderWidget("Module: Timer/Stacks", 
		ActionEditor, 0)
	-- Display timers?
	ActionEditor.DisplayTimer = Modules.Config:CreateButtonWidget(ActionEditor, "Display Timer")
	ActionEditor.DisplayTimer:SetPoint("TOP", ActionEditor, "TOP", -60, -25)
	ActionEditor.DisplayTimer:SetScript("OnClick", function(self)
		-- Toggle self.
		if(self.Selected) then
			self:Deselect()
			Modules.Config:UpdateActionData("timer", nil)
		else
			self:Select()
			Modules.Config:UpdateActionData("timer", true)
		end
	end)
	-- Display stacks?
	ActionEditor.DisplayStacks = Modules.Config:CreateButtonWidget(ActionEditor, "Display Stacks")
	ActionEditor.DisplayStacks:SetPoint("TOP", ActionEditor, "TOP", 60, -25)
	ActionEditor.DisplayStacks:SetScript("OnClick", function(self)
		-- Toggle self.
		if(self.Selected) then
			self:Deselect()
			Modules.Config:UpdateActionData("stacks", nil)
		else
			self:Select()
			Modules.Config:UpdateActionData("stacks", true)
		end
	end)
	-- Tooltips (localization handled by the config module)
	Modules.Config:RegisterConfigTooltip(ActionEditor.DisplayTimer, { 
		title = "Display Timer", 
		text = "Allows this button to display any enabled timers this aura has."
	})
	Modules.Config:RegisterConfigTooltip(ActionEditor.DisplayStacks, { 
		title = "Display Stacks", 
		text = "Allows this button to display any enabled stacks this aura has."
	})
	-- Add the necessary functions.
	ActionEditor.UpdateAction = function(self, actionData)
		if(actionData["timer"]) then
			ActionEditor.DisplayTimer:Select()
		else
			ActionEditor.DisplayTimer:Deselect()
		end
		if(actionData["stacks"]) then
			ActionEditor.DisplayStacks:Select()
		else
			ActionEditor.DisplayStacks:Deselect()
		end
	end
	-- Done.
	Modules.Config:RegisterActionConfigFrame(ActionEditor, 3)
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
	-- Split into two functions so I don't kill myself.
	ModuleFrame:CreateInterfaceOptionsTimerFrame()
	ModuleFrame:CreateInterfaceOptionsStacksFrame()
end
--[[
----------------------------------------------------------------------------------------------------
CreateInterfaceOptionsTimerFrame

Creates the timers configuration editor.

WARNING: This function will drive you insane. I'm not optimizing it, I NEVER WANT TO SEE IT AGAIN.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateInterfaceOptionsTimerFrame()
	-- Register the timers part.
	local InterfaceOptions = Modules.Config:RegisterInterfaceOptionsFrame("Module: Timers")
	-- Add some header(s).
	InterfaceOptions.AnchorHeader = Modules.Config:CreateHeaderWidget("Timer Anchors", 
		InterfaceOptions, -60)
	InterfaceOptions.AnchorHeader.bg:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 4, -60)
	InterfaceOptions.AnchorHeader.bg:SetPoint("TOPRIGHT", InterfaceOptions, "TOPRIGHT", -4, -60)
	-- Timer anchoring first.
	InterfaceOptions.TimerAnchor = CreateFrame("Frame", "PowerAurasButtons_TimerAnchor", InterfaceOptions, "Lib_UIDropDownMenuTemplate")
	InterfaceOptions.TimerAnchor:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 0, -85)
	-- Menu.
	local menuList = {
		"TOPLEFT",
		"TOP",
		"TOPRIGHT",
		"LEFT",
		"CENTER",
		"RIGHT",
		"BOTTOMLEFT",
		"BOTTOM",
		"BOTTOMRIGHT",
	}
	-- Sort out the menu.
	Lib_UIDropDownMenu_Initialize(InterfaceOptions.TimerAnchor, function(frame, level)
		-- Go over those items.
		for _, v in pairs(menuList) do
			-- Make an item.
			local item = Lib_UIDropDownMenu_CreateInfo()
			item.text = CoreFrame.L[v]
			item.arg1 = v
			item.func = function(self, arg1)
				-- Item clicked, change selection and save.
				Lib_UIDropDownMenu_SetSelectedID(frame, self:GetID())
				-- Store in indexes 1 and 3.
				PowerAurasButtons_SettingsDB["TimerStacks"]["TimerAnchors"][1] = arg1
				PowerAurasButtons_SettingsDB["TimerStacks"]["TimerAnchors"][3] = arg1
				-- Trigger update.
				Modules.TimerStacks:UpdateButtonFrames()
			end
			-- Add to list.
			Lib_UIDropDownMenu_AddButton(item, level)
		end
	end)
	Lib_UIDropDownMenu_SetWidth(InterfaceOptions.TimerAnchor, 150)
	Lib_UIDropDownMenu_SetButtonWidth(InterfaceOptions.TimerAnchor, 165)
	Lib_UIDropDownMenu_SetSelectedValue(InterfaceOptions.TimerAnchor, CoreFrame.L[CoreFrame:GetModuleSetting("TimerStacks", "TimerAnchors")[1]])
	Lib_UIDropDownMenu_JustifyText(InterfaceOptions.TimerAnchor, "LEFT")
	
	-- Now X/Y offsets. Two sliders.
	InterfaceOptions.TimerOffsetX = CreateFrame("Slider", "PowerAurasButtons_TimerOffsetX", InterfaceOptions, "OptionsSliderTemplate")
	InterfaceOptions.TimerOffsetX:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 20, -130)
	InterfaceOptions.TimerOffsetX:SetMinMaxValues(-32, 32)
	InterfaceOptions.TimerOffsetX:SetValue(CoreFrame:GetModuleSetting("TimerStacks", "TimerAnchors")[4])
	InterfaceOptions.TimerOffsetX:SetValueStep(1)
	InterfaceOptions.TimerOffsetX:SetObeyStepOnDrag(true)
	InterfaceOptions.TimerOffsetX:SetWidth(125)
	
	PowerAurasButtons_TimerOffsetXLow:SetText("-32")
	PowerAurasButtons_TimerOffsetXHigh:SetText("32")
	PowerAurasButtons_TimerOffsetXText:SetText(CoreFrame.L["X Offset"] .. " (" .. CoreFrame:GetModuleSetting("TimerStacks", "TimerAnchors")[4] .. ")")
	-- Update on value change.
	InterfaceOptions.TimerOffsetX:SetScript("OnValueChanged", function(self)
		-- Set it.
		PowerAurasButtons_SettingsDB["TimerStacks"]["TimerAnchors"][4] = self:GetValue()	
		-- Update label too.
		PowerAurasButtons_TimerOffsetXText:SetText(CoreFrame.L["X Offset"] .. " (" .. 
			self:GetValue() .. ")")
		-- Trigger update.
		Modules.TimerStacks:UpdateButtonFrames()
	end)
	
	InterfaceOptions.TimerOffsetY = CreateFrame("Slider", "PowerAurasButtons_TimerOffsetY", InterfaceOptions, "OptionsSliderTemplate")
	InterfaceOptions.TimerOffsetY:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 165, -130)
	InterfaceOptions.TimerOffsetY:SetMinMaxValues(-32, 32)
	InterfaceOptions.TimerOffsetY:SetValue(CoreFrame:GetModuleSetting("TimerStacks", "TimerAnchors")[5])
	InterfaceOptions.TimerOffsetY:SetValueStep(1)
	InterfaceOptions.TimerOffsetY:SetObeyStepOnDrag(true)
	InterfaceOptions.TimerOffsetY:SetWidth(125)
	
	PowerAurasButtons_TimerOffsetYLow:SetText("-32")
	PowerAurasButtons_TimerOffsetYHigh:SetText("32")
	PowerAurasButtons_TimerOffsetYText:SetText(CoreFrame.L["Y Offset"] .. " (" .. CoreFrame:GetModuleSetting("TimerStacks", "TimerAnchors")[5] .. ")")
	-- Update on value change.
	InterfaceOptions.TimerOffsetY:SetScript("OnValueChanged", function(self)
		-- Set it.
		PowerAurasButtons_SettingsDB["TimerStacks"]["TimerAnchors"][5] = self:GetValue()	
		-- Update label too.
		PowerAurasButtons_TimerOffsetYText:SetText(CoreFrame.L["Y Offset"] .. " (" .. self:GetValue() .. ")")
		-- Trigger update.
		Modules.TimerStacks:UpdateButtonFrames()
	end)
	-- Add some header(s).
	InterfaceOptions.FontHeader = Modules.Config:CreateHeaderWidget("Timer Font", 
		InterfaceOptions, -165)
	InterfaceOptions.FontHeader.bg:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 4, -165)
	InterfaceOptions.FontHeader.bg:SetPoint("TOPRIGHT", InterfaceOptions, "TOPRIGHT", -4, -165)
	
	-- Font selection.
	InterfaceOptions.TimerFont = CreateFrame("Frame", "PowerAurasButtons_TimerFont", InterfaceOptions, "Lib_UIDropDownMenuTemplate")
	InterfaceOptions.TimerFont:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 0, -200)
	-- Menu.
	local fonts = {
		["Arial Narrow"] = "Fonts\\ARIALN.ttf",
		["Friz Quadrata TT"] = "Fonts\\FRIZQT_.ttf",
		["Morpheus"] = "Fonts\\MORPHEUS.ttf",
		["Skurri"] = "Fonts\\skurri.ttf",
	}
	-- Figure out if we're using default fonts or LSM.
	local LSMFonts
	if(LibStub) then
		-- Try LSM.
		local LSM = LibStub("LibSharedMedia-3.0", true)
		if(LSM) then
			-- Get all fonts.
			LSMFonts = LSM:HashTable(LSM.MediaType.FONT)
		end
	end
	-- Sort out the menu.
	Lib_UIDropDownMenu_Initialize(InterfaceOptions.TimerFont, function(frame, level)
		-- Go over those items.
		for k, v in pairs(LSMFonts or fonts) do
			-- Make an item.
			local item = Lib_UIDropDownMenu_CreateInfo()
			item.text = k
			item.arg1 = v
			item.arg2 = k
			item.func = function(self, arg1, arg2)
				-- Item clicked, change selection and save.
				Lib_UIDropDownMenu_SetSelectedID(frame, self:GetID())
				-- Store in indexes 1 and 3.
				PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][1] = arg1
				PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][4] = arg2
				-- Trigger update.
				Modules.TimerStacks:UpdateButtonFrames()
			end
			-- Add to list.
			Lib_UIDropDownMenu_AddButton(item, level)
		end
	end)
	Lib_UIDropDownMenu_SetWidth(InterfaceOptions.TimerFont, 150)
	Lib_UIDropDownMenu_SetButtonWidth(InterfaceOptions.TimerFont, 165)
	Lib_UIDropDownMenu_SetSelectedValue(InterfaceOptions.TimerFont, PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][4])
	Lib_UIDropDownMenu_JustifyText(InterfaceOptions.TimerFont, "LEFT")
	
	-- Font size slider.
	InterfaceOptions.TimerFontSize = CreateFrame("Slider", "PowerAurasButtons_TimerFontSize", InterfaceOptions, "OptionsSliderTemplate")
	InterfaceOptions.TimerFontSize:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 210, -205)
	InterfaceOptions.TimerFontSize:SetMinMaxValues(1, 24)
	InterfaceOptions.TimerFontSize:SetValue(CoreFrame:GetModuleSetting("TimerStacks", "TimerFont")[2])
	InterfaceOptions.TimerFontSize:SetValueStep(1)
	InterfaceOptions.TimerFontSize:SetObeyStepOnDrag(true)
	InterfaceOptions.TimerFontSize:SetWidth(125)
	PowerAurasButtons_TimerFontSizeLow:SetText("1")
	PowerAurasButtons_TimerFontSizeHigh:SetText("24")
	PowerAurasButtons_TimerFontSizeText:SetText(CoreFrame.L["Font Size"] .. " (" .. CoreFrame:GetModuleSetting("TimerStacks", "TimerFont")[2] .. ")")
	-- Update on value change.
	InterfaceOptions.TimerFontSize:SetScript("OnValueChanged", function(self)
		-- Set it.
		PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][2] = self:GetValue()	
		-- Update label too.
		PowerAurasButtons_TimerFontSizeText:SetText(CoreFrame.L["Font Size"] .. " (" .. self:GetValue() .. ")")
		-- Trigger update.
		Modules.TimerStacks:UpdateButtonFrames()
	end)
	
	-- Outline selector.
	InterfaceOptions.TimerOutline = CreateFrame("Frame", "PowerAurasButtons_TimerOutline", InterfaceOptions, "Lib_UIDropDownMenuTemplate")
	InterfaceOptions.TimerOutline:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 0, -230)
	-- Menu.
	local menuList = {
		"OUTLINE",
		"THICKOUTLINE",
		"MONOCHROME",
		"OUTLINE, MONOCHROME",
		"THICKOUTLINE, MONOCHROME"
	}
	-- Sort out the menu.
	Lib_UIDropDownMenu_Initialize(InterfaceOptions.TimerOutline, function(frame, level)
		-- Go over those items.
		for _, v in pairs(menuList) do
			-- Make an item.
			local item = Lib_UIDropDownMenu_CreateInfo()
			item.text = CoreFrame.L[v]
			item.arg1 = v
			item.func = function(self, arg1, arg2)
				-- Item clicked, change selection and save.
				Lib_UIDropDownMenu_SetSelectedID(frame, self:GetID())
				-- Store in index 3.
				PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][3] = arg1
				-- Trigger update.
				Modules.TimerStacks:UpdateButtonFrames()
			end
			-- Add to list.
			Lib_UIDropDownMenu_AddButton(item, level)
		end
	end)
	Lib_UIDropDownMenu_SetWidth(InterfaceOptions.TimerOutline, 150)
	Lib_UIDropDownMenu_SetButtonWidth(InterfaceOptions.TimerOutline, 165)
	Lib_UIDropDownMenu_SetSelectedValue(InterfaceOptions.TimerOutline, 	PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][3])
	Lib_UIDropDownMenu_JustifyText(InterfaceOptions.TimerOutline, "LEFT")
	
	-- Font color. WE'RE ALMOST DONE.
	InterfaceOptions.TimerColor = Modules.Config:CreateColorWidget(InterfaceOptions)
	InterfaceOptions.TimerColor:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 205, -236)
	InterfaceOptions.TimerColor:SetScript("OnClick", function()
		-- Display the color picker.
		ColorPickerFrame:SetColorRGB(InterfaceOptions.TimerColor.Swatch:GetVertexColor())
		-- Allow transparency.
		ColorPickerFrame.hasOpacity = nil
		ColorPickerFrame.opacity = 1
		ColorPickerFrame.previousValues = InterfaceOptions.TimerColor.Swatch.Backup
		-- Save functions.
		local saveFunc = function(restore)
			-- Locals.
			local r, g, b, a = nil, nil, nil, 1
			-- Get values.
			if(not restore) then
				r, g, b = ColorPickerFrame:GetColorRGB()
			else
				-- Restoring from restore table.
				r, g, b, a = unpack(restore)
			end
			-- Save.
			PowerAurasButtons_SettingsDB["TimerStacks"]["TimerColours"] = { r, g, b, a }
			InterfaceOptions.TimerColor.Swatch:SetVertexColor(r, g, b, a)
			InterfaceOptions.TimerColor.Swatch.Backup = { r, g, b, a }
			-- Trigger update.
			Modules.TimerStacks:UpdateButtonFrames()
		end
		ColorPickerFrame.func, ColorPickerFrame.cancelFunc = saveFunc, saveFunc
		-- Go.
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end)
	-- Final bits.
	InterfaceOptions.TimerColor.Swatch:SetVertexColor(
		unpack(PowerAurasButtons_SettingsDB["TimerStacks"]["TimerColours"]))
	InterfaceOptions.TimerColor.Swatch.Backup = 
		PowerAurasButtons_SettingsDB["TimerStacks"]["TimerColours"]
	
	-- Tooltips.
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.TimerAnchor, {
		title = "Anchor",
		text = "Controls the anchor point of the display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.TimerOffsetX, {
		title = "X Offset",
		text = "Controls the X co-ordinate position of the display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.TimerOffsetY, {
		title = "Y Offset",
		text = "Controls the Y co-ordinate position of the display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.TimerFont, {
		title = "Font",
		text = "Controls the name of the font to display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.TimerFontSize, {
		title = "Font Size",
		text = "Controls the font size."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.TimerOutline, {
		title = "Font Outline",
		text = "Controls the outline of the font."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.TimerColor, {
		title = "Font Color",
		text = "Controls color of the font."
	})
end
--[[
----------------------------------------------------------------------------------------------------
CreateInterfaceOptionsStacksFrame

Creates the stacks configuration editor.

WARNING: This function will drive you insane. I'm not optimizing it, I NEVER WANT TO SEE IT AGAIN.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateInterfaceOptionsStacksFrame()
	-- Register the Stacks part.
	local InterfaceOptions = Modules.Config:RegisterInterfaceOptionsFrame("Module: Stacks")
	-- Add some header(s).
	InterfaceOptions.AnchorHeader = Modules.Config:CreateHeaderWidget("Stacks Anchors", InterfaceOptions, -60)
	InterfaceOptions.AnchorHeader.bg:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 4, -60)
	InterfaceOptions.AnchorHeader.bg:SetPoint("TOPRIGHT", InterfaceOptions, "TOPRIGHT", -4, -60)
	-- Stacks anchoring first.
	InterfaceOptions.StacksAnchor = CreateFrame("Frame", "PowerAurasButtons_StacksAnchor", InterfaceOptions, "Lib_UIDropDownMenuTemplate")
	InterfaceOptions.StacksAnchor:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 0, -85)
	-- Menu.
	local menuList = {
		"TOPLEFT",
		"TOP",
		"TOPRIGHT",
		"LEFT",
		"CENTER",
		"RIGHT",
		"BOTTOMLEFT",
		"BOTTOM",
		"BOTTOMRIGHT",
	}
	-- Sort out the menu.
	Lib_UIDropDownMenu_Initialize(InterfaceOptions.StacksAnchor, function(frame, level)
		-- Go over those items.
		for _, v in pairs(menuList) do
			-- Make an item.
			local item = Lib_UIDropDownMenu_CreateInfo()
			item.text = CoreFrame.L[v]
			item.arg1 = v
			item.func = function(self, arg1)
				-- Item clicked, change selection and save.
				Lib_UIDropDownMenu_SetSelectedID(frame, self:GetID())
				-- Store in indexes 1 and 3.
				PowerAurasButtons_SettingsDB["TimerStacks"]["StacksAnchors"][1] = arg1
				PowerAurasButtons_SettingsDB["TimerStacks"]["StacksAnchors"][3] = arg1
				-- Trigger update.
				Modules.TimerStacks:UpdateButtonFrames()
			end
			-- Add to list.
			Lib_UIDropDownMenu_AddButton(item, level)
		end
	end)
	Lib_UIDropDownMenu_SetWidth(InterfaceOptions.StacksAnchor, 150)
	Lib_UIDropDownMenu_SetButtonWidth(InterfaceOptions.StacksAnchor, 165)
	Lib_UIDropDownMenu_SetSelectedValue(InterfaceOptions.StacksAnchor, CoreFrame.L[CoreFrame:GetModuleSetting("TimerStacks", "StacksAnchors")[1]])
	Lib_UIDropDownMenu_JustifyText(InterfaceOptions.StacksAnchor, "LEFT")
	
	-- Now X/Y offsets. Two sliders.
	InterfaceOptions.StacksOffsetX = CreateFrame("Slider", "PowerAurasButtons_StacksOffsetX", InterfaceOptions, "OptionsSliderTemplate")
	InterfaceOptions.StacksOffsetX:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 20, -130)
	InterfaceOptions.StacksOffsetX:SetMinMaxValues(-32, 32)
	InterfaceOptions.StacksOffsetX:SetValue(CoreFrame:GetModuleSetting("TimerStacks", "StacksAnchors")[4])
	InterfaceOptions.StacksOffsetX:SetValueStep(1)
	InterfaceOptions.StacksOffsetX:SetObeyStepOnDrag(true)
	InterfaceOptions.StacksOffsetX:SetWidth(125)
	
	PowerAurasButtons_StacksOffsetXLow:SetText("-32")
	PowerAurasButtons_StacksOffsetXHigh:SetText("32")
	PowerAurasButtons_StacksOffsetXText:SetText(CoreFrame.L["X Offset"] .. " (" .. CoreFrame:GetModuleSetting("TimerStacks", "StacksAnchors")[4] .. ")")
	-- Update on value change.
	InterfaceOptions.StacksOffsetX:SetScript("OnValueChanged", function(self)
		-- Set it.
		PowerAurasButtons_SettingsDB["TimerStacks"]["StacksAnchors"][4] = self:GetValue()	
		-- Update label too.
		PowerAurasButtons_StacksOffsetXText:SetText(CoreFrame.L["X Offset"] .. " (" .. self:GetValue() .. ")")
		-- Trigger update.
		Modules.TimerStacks:UpdateButtonFrames()
	end)
	
	InterfaceOptions.StacksOffsetY = CreateFrame("Slider", "PowerAurasButtons_StacksOffsetY", InterfaceOptions, "OptionsSliderTemplate")
	InterfaceOptions.StacksOffsetY:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 165, -130)
	InterfaceOptions.StacksOffsetY:SetMinMaxValues(-32, 32)
	InterfaceOptions.StacksOffsetY:SetValue(CoreFrame:GetModuleSetting("TimerStacks", "StacksAnchors")[5])
	InterfaceOptions.StacksOffsetY:SetValueStep(1)
	InterfaceOptions.StacksOffsetY:SetObeyStepOnDrag(true)
	InterfaceOptions.StacksOffsetY:SetWidth(125)
	
	PowerAurasButtons_StacksOffsetYLow:SetText("-32")
	PowerAurasButtons_StacksOffsetYHigh:SetText("32")
	PowerAurasButtons_StacksOffsetYText:SetText(CoreFrame.L["Y Offset"] .. " (" .. CoreFrame:GetModuleSetting("TimerStacks", "StacksAnchors")[5] .. ")")
	-- Update on value change.
	InterfaceOptions.StacksOffsetY:SetScript("OnValueChanged", function(self)
		-- Set it.
		PowerAurasButtons_SettingsDB["TimerStacks"]["StacksAnchors"][5] = self:GetValue()	
		-- Update label too.
		PowerAurasButtons_StacksOffsetYText:SetText(CoreFrame.L["Y Offset"] .. " (" .. self:GetValue() .. ")")
		-- Trigger update.
		Modules.TimerStacks:UpdateButtonFrames()
	end)
	-- Add some header(s).
	InterfaceOptions.FontHeader = Modules.Config:CreateHeaderWidget("Stacks Font", InterfaceOptions, -165)
	InterfaceOptions.FontHeader.bg:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 4, -165)
	InterfaceOptions.FontHeader.bg:SetPoint("TOPRIGHT", InterfaceOptions, "TOPRIGHT", -4, -165)
	
	-- Font selection.
	InterfaceOptions.StacksFont = CreateFrame("Frame", "PowerAurasButtons_StacksFont", InterfaceOptions, "Lib_UIDropDownMenuTemplate")
	InterfaceOptions.StacksFont:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 0, -200)
	-- Menu.
	local fonts = {
		["Arial Narrow"] = "Fonts\\ARIALN.ttf",
		["Friz Quadrata TT"] = "Fonts\\FRIZQT_.ttf",
		["Morpheus"] = "Fonts\\MORPHEUS.ttf",
		["Skurri"] = "Fonts\\skurri.ttf",
	}
	-- Figure out if we're using default fonts or LSM.
	local LSMFonts
	if(LibStub) then
		-- Try LSM.
		local LSM = LibStub("LibSharedMedia-3.0", true)
		if(LSM) then
			-- Get all fonts.
			LSMFonts = LSM:HashTable(LSM.MediaType.FONT)
		end
	end
	-- Sort out the menu.
	Lib_UIDropDownMenu_Initialize(InterfaceOptions.StacksFont, function(frame, level)
		-- Go over those items.
		for k, v in pairs(LSMFonts or fonts) do
			-- Make an item.
			local item = Lib_UIDropDownMenu_CreateInfo()
			item.text = k
			item.arg1 = v
			item.arg2 = k
			item.func = function(self, arg1, arg2)
				-- Item clicked, change selection and save.
				Lib_UIDropDownMenu_SetSelectedID(frame, self:GetID())
				-- Store in indexes 1 and 3.
				PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][1] = arg1
				PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][4] = arg2
				-- Trigger update.
				Modules.TimerStacks:UpdateButtonFrames()
			end
			-- Add to list.
			Lib_UIDropDownMenu_AddButton(item, level)
		end
	end)
	Lib_UIDropDownMenu_SetWidth(InterfaceOptions.StacksFont, 150)
	Lib_UIDropDownMenu_SetButtonWidth(InterfaceOptions.StacksFont, 165)
	Lib_UIDropDownMenu_SetSelectedValue(InterfaceOptions.StacksFont, PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][4])
	Lib_UIDropDownMenu_JustifyText(InterfaceOptions.StacksFont, "LEFT")
	
	-- Font size slider.
	InterfaceOptions.StacksFontSize = CreateFrame("Slider", "PowerAurasButtons_StacksFontSize", InterfaceOptions, "OptionsSliderTemplate")
	InterfaceOptions.StacksFontSize:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 210, -205)
	InterfaceOptions.StacksFontSize:SetMinMaxValues(1, 24)
	InterfaceOptions.StacksFontSize:SetValue(CoreFrame:GetModuleSetting("TimerStacks", "StacksFont")[2])
	InterfaceOptions.StacksFontSize:SetValueStep(1)
	InterfaceOptions.StacksFontSize:SetObeyStepOnDrag(true)
	InterfaceOptions.StacksFontSize:SetWidth(125)
	PowerAurasButtons_StacksFontSizeLow:SetText("1")
	PowerAurasButtons_StacksFontSizeHigh:SetText("24")
	PowerAurasButtons_StacksFontSizeText:SetText(CoreFrame.L["Font Size"] .. " (" .. CoreFrame:GetModuleSetting("TimerStacks", "StacksFont")[2] .. ")")
	-- Update on value change.
	InterfaceOptions.StacksFontSize:SetScript("OnValueChanged", function(self)
		-- Set it.
		PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][2] = self:GetValue()	
		-- Update label too.
		PowerAurasButtons_StacksFontSizeText:SetText(CoreFrame.L["Font Size"] .. " (" .. self:GetValue() .. ")")
		-- Trigger update.
		Modules.TimerStacks:UpdateButtonFrames()
	end)
	
	-- Outline selector.
	InterfaceOptions.StacksOutline = CreateFrame("Frame", "PowerAurasButtons_StacksOutline", InterfaceOptions, "Lib_UIDropDownMenuTemplate")
	InterfaceOptions.StacksOutline:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 0, -230)
	-- Menu.
	local menuList = {
		"OUTLINE",
		"THICKOUTLINE",
		"MONOCHROME",
		"OUTLINE, MONOCHROME",
		"THICKOUTLINE, MONOCHROME"
	}
	-- Sort out the menu.
	Lib_UIDropDownMenu_Initialize(InterfaceOptions.StacksOutline, function(frame, level)
		-- Go over those items.
		for _, v in pairs(menuList) do
			-- Make an item.
			local item = Lib_UIDropDownMenu_CreateInfo()
			item.text = CoreFrame.L[v]
			item.arg1 = v
			item.func = function(self, arg1, arg2)
				-- Item clicked, change selection and save.
				Lib_UIDropDownMenu_SetSelectedID(frame, self:GetID())
				-- Store in index 3.
				PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][3] = arg1
				-- Trigger update.
				Modules.TimerStacks:UpdateButtonFrames()
			end
			-- Add to list.
			Lib_UIDropDownMenu_AddButton(item, level)
		end
	end)
	Lib_UIDropDownMenu_SetWidth(InterfaceOptions.StacksOutline, 150)
	Lib_UIDropDownMenu_SetButtonWidth(InterfaceOptions.StacksOutline, 165)
	Lib_UIDropDownMenu_SetSelectedValue(InterfaceOptions.StacksOutline, PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][3])
	Lib_UIDropDownMenu_JustifyText(InterfaceOptions.StacksOutline, "LEFT")
	
	-- Font color. WE'RE ALMOST DONE.
	InterfaceOptions.StacksColor = Modules.Config:CreateColorWidget(InterfaceOptions)
	InterfaceOptions.StacksColor:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 205, -236)
	InterfaceOptions.StacksColor:SetScript("OnClick", function()
		-- Display the color picker.
		ColorPickerFrame:SetColorRGB(InterfaceOptions.StacksColor.Swatch:GetVertexColor())
		-- Allow transparency.
		ColorPickerFrame.hasOpacity = nil
		ColorPickerFrame.opacity = 1
		ColorPickerFrame.previousValues = InterfaceOptions.StacksColor.Swatch.Backup
		-- Save functions.
		local saveFunc = function(restore)
			-- Locals.
			local r, g, b, a = nil, nil, nil, 1
			-- Get values.
			if(not restore) then
				r, g, b = ColorPickerFrame:GetColorRGB()
			else
				-- Restoring from restore table.
				r, g, b, a = unpack(restore)
			end
			-- Save.
			PowerAurasButtons_SettingsDB["TimerStacks"]["StacksColours"] = { r, g, b, a }
			InterfaceOptions.StacksColor.Swatch:SetVertexColor(r, g, b, a)
			InterfaceOptions.StacksColor.Swatch.Backup = { r, g, b, a }
			-- Trigger update.
			Modules.TimerStacks:UpdateButtonFrames()
		end
		ColorPickerFrame.func, ColorPickerFrame.cancelFunc = saveFunc, saveFunc
		-- Go.
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end)
	-- Final bits.
	InterfaceOptions.StacksColor.Swatch:SetVertexColor(unpack(PowerAurasButtons_SettingsDB["TimerStacks"]["StacksColours"]))
	InterfaceOptions.StacksColor.Swatch.Backup = PowerAurasButtons_SettingsDB["TimerStacks"]["StacksColours"]
	
	-- Tooltips.
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.StacksAnchor, {
		title = "Anchor",
		text = "Controls the anchor point of the display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.StacksOffsetX, {
		title = "X Offset",
		text = "Controls the X co-ordinate position of the display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.StacksOffsetY, {
		title = "Y Offset",
		text = "Controls the Y co-ordinate position of the display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.StacksFont, {
		title = "Font",
		text = "Controls the name of the font to display."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.StacksFontSize, {
		title = "Font Size",
		text = "Controls the font size."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.StacksOutline, {
		title = "Font Outline",
		text = "Controls the outline of the font."
	})
	Modules.Config:RegisterConfigTooltip(InterfaceOptions.StacksColor, {
		title = "Font Color",
		text = "Controls color of the font."
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