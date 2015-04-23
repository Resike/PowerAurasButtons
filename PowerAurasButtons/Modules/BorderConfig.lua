--[[
	PowerAurasButtons
	
	Module: BorderConfig
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons
local ModuleFrame      = CoreFrame:RegisterModule("BorderConfig", { "Border", "Config" })
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
	ActionEditor:SetHeight(55)
	-- Label.
	ActionEditor.DisplayLabel = Modules.Config:CreateHeaderWidget("Module: Border", ActionEditor, 
		0)
	-- Display borders?
	ActionEditor.DisplayBorder = Modules.Config:CreateButtonWidget(ActionEditor, "Display Border")
	ActionEditor.DisplayBorder:SetPoint("TOPLEFT", ActionEditor, "TOPLEFT", 5, -30)
	ActionEditor.DisplayBorder:SetScript("OnClick", function(self)
		-- Toggle self.
		if(self.Selected) then
			self:Deselect()
			Modules.Config:UpdateActionData("border", nil)
		else
			self:Select()
			Modules.Config:UpdateActionData("border", true)
		end
	end)
	
	-- Color picker.
	ActionEditor.Color = Modules.Config:CreateColorWidget(ActionEditor)
	ActionEditor.Color:SetPoint("TOPLEFT", ActionEditor, "TOPLEFT", 155, -35)
	ActionEditor.Color:SetScript("OnClick", function()
		-- Display the color picker.
		ColorPickerFrame:SetColorRGB(ActionEditor.Color.Swatch:GetVertexColor())
		-- Allow transparency.
		ColorPickerFrame.hasOpacity = nil
		ColorPickerFrame.opacity = 1
		ColorPickerFrame.previousValues = ActionEditor.Color.Swatch.Backup
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
			Modules.Config:UpdateActionData("border_color", { r, g, b, a })
		end
		ColorPickerFrame.func, ColorPickerFrame.cancelFunc = saveFunc, saveFunc
		-- Go.
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end)
		
	-- Border priority slider.
	ActionEditor.Priority = CreateFrame("Slider", "PowerAurasButtons_BorderPrioritySlider", ActionEditor, "OptionsSliderTemplate")
	ActionEditor.Priority:SetPoint("TOPLEFT", ActionEditor, "TOPLEFT", 185, -34)
	ActionEditor.Priority:SetMinMaxValues(1, 50)
	ActionEditor.Priority:SetValue(1)
	ActionEditor.Priority:SetValueStep(1)
	ActionEditor.Priority:SetWidth(150)
	
	PowerAurasButtons_BorderPrioritySliderLow:SetText(0)
	PowerAurasButtons_BorderPrioritySliderHigh:SetText(25)
		
	ActionEditor.Priority:SetScript("OnValueChanged", function()
		Modules.Config:UpdateActionData("border_priority", ceil(ActionEditor.Priority:GetValue()))		
	end)
	
	-- Tooltips (localization handled by the config module)
	Modules.Config:RegisterConfigTooltip(ActionEditor.DisplayBorder, { 
		title = "Display Border |cFFFF0000*BETA*|r", 
		text = "Displays a colored border around the button when the aura is active."
	})
	Modules.Config:RegisterConfigTooltip(ActionEditor.Color, { 
		title = "Border Color", 
		text = "The color of the border."
	})
	Modules.Config:RegisterConfigTooltip(ActionEditor.Priority, { 
		title = "Border Priority", 
		text = "The priority of the border.\n\n" ..
			"If multiple auras attempt to color a border, only the one with the highest " .. 
			"priority will be shown."
	})
	
	-- Add the necessary functions.
	ActionEditor.UpdateAction = function(self, actionData)
		if(actionData["border"]) then
			ActionEditor.DisplayBorder:Select()
		else
			ActionEditor.DisplayBorder:Deselect()
		end
		if(actionData["border_priority"]) then
			ActionEditor.Priority:SetValue(actionData["border_priority"])
			PowerAurasButtons_BorderPrioritySliderText:SetText(actionData["border_priority"])
		else
			ActionEditor.Priority:SetValue(25)
			PowerAurasButtons_BorderPrioritySliderText:SetText(25)
		end
		if(actionData["border_color"]) then
			ActionEditor.Color.Swatch:SetVertexColor(unpack(actionData["border_color"]))
			ActionEditor.Color.Swatch.Backup = actionData["border_color"]
		else
			ActionEditor.Color.Swatch:SetVertexColor(1, 1, 1, 1)
			ActionEditor.Color.Swatch.Backup = { 1, 1, 1, 1 }
		end
	end
	
	-- Done.
	Modules.Config:RegisterActionConfigFrame(ActionEditor)
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
	-- Done.
	return true
end