--[[
	PowerAurasButtons
	
	Module: AurasConfig
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons
local ModuleFrame      = CoreFrame:RegisterModule("AurasConfig", { "Auras" })
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
	ActionEditor:SetHeight(110)
	-- Add the appropriate elements to the editor frame. Start with type.
	ActionEditor.TypeLabel = Modules.Config:CreateHeaderWidget("Action Type", ActionEditor, 0)
	-- Type changing callback.
	local typechange = function(self)
		-- Go forth.
		if(self == ActionEditor.TypeSpell) then
			-- Enable the spell button.
			ActionEditor.TypeSpell:Select()
			ActionEditor.TypeItem:Deselect()
			ActionEditor.TypeMacro:Deselect()
			Modules.Config:UpdateActionData("type", "spell")
		elseif(self == ActionEditor.TypeItem) then
			-- Item button.
			ActionEditor.TypeItem:Select()
			ActionEditor.TypeSpell:Deselect()
			ActionEditor.TypeMacro:Deselect()
			Modules.Config:UpdateActionData("type", "item")
		elseif(self == ActionEditor.TypeMacro) then
			-- Macro button.
			ActionEditor.TypeMacro:Select()
			ActionEditor.TypeSpell:Deselect()
			ActionEditor.TypeItem:Deselect()
			Modules.Config:UpdateActionData("type", "macro")
		end
	end
	-- Button #1: Spell.
	ActionEditor.TypeSpell = Modules.Config:CreateButtonWidget(ActionEditor, "Spell", 
		"Interface\\GossipFrame\\TrainerGossipIcon")
	ActionEditor.TypeSpell:SetPoint("TOP", ActionEditor, "TOP", -115, -25)
	ActionEditor.TypeSpell:SetScript("OnClick", typechange)
	-- Button #2: Item
	ActionEditor.TypeItem = Modules.Config:CreateButtonWidget(ActionEditor, "Item", 
		"Interface\\GossipFrame\\VendorGossipIcon")
	ActionEditor.TypeItem:SetPoint("TOP", ActionEditor, "TOP", 0, -25)
	ActionEditor.TypeItem:SetScript("OnClick", typechange)
	-- Button #3: Macro
	ActionEditor.TypeMacro = Modules.Config:CreateButtonWidget(ActionEditor, "Macro", 
		"Interface\\GossipFrame\\BinderGossipIcon")
	ActionEditor.TypeMacro:SetPoint("TOP", ActionEditor, "TOP", 115, -25)
	ActionEditor.TypeMacro:SetScript("OnClick", typechange)
	
	-- Action Name/ID.
	ActionEditor.IDLabel = Modules.Config:CreateHeaderWidget("Action Name/ID", ActionEditor, -56)
	-- Add in the amazing editbox.
	ActionEditor.IDEditbox = CreateFrame("EditBox", nil, ActionEditor, "InputBoxTemplate")
	ActionEditor.IDEditbox:SetPoint("TOP", ActionEditor, "TOP", 0, -81)
	ActionEditor.IDEditbox:SetHeight(24)
	ActionEditor.IDEditbox:SetWidth(225)
	ActionEditor.IDEditbox:SetAutoFocus(false)
	ActionEditor.IDEditbox:SetMultiLine(false)
	-- Create a save script.
	ActionEditor.IDEditbox.Save = function()
		-- See if the contents are text or number.
		local contents = tonumber(ActionEditor.IDEditbox:GetText(), 10)
		if(not contents) then
			-- Reset contents var.
			contents = ActionEditor.IDEditbox:GetText()
			-- Convert the text to an ID.
			if(Modules.Config:GetCurrentActionData()["type"] == "spell") then
				-- Easy.
				contents = select(2, GetSpellBookItemInfo(contents))	
			elseif(Modules.Config:GetCurrentActionData()["type"] == "item") then
				-- Not so easy.
				local link = select(2, GetItemInfo(contents))
				if(link) then
					contents = tonumber(select(5, string.find(link, 
						"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?"..
						"(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")), 10)
				end
			elseif(Modules.Config:GetCurrentActionData()["type"] == "macro") then
				-- Easy.
				contents = select(1, GetMacroIndexByName(contents))
			end
		end
		-- Save.
		if(type(contents) == "number") then
			Modules.Config:UpdateActionData("id", contents)
		else
			CoreFrame:Print("Could not convert '%s' to an ID.", ActionEditor.IDEditbox:GetText())
			Modules.Config:UpdateActionData("id", nil)
		end
		-- Clear focus.
		ActionEditor.IDEditbox:ClearFocus()
	end
	-- Register scripts.
	ActionEditor.IDEditbox:SetScript("OnEnterPressed", ActionEditor.IDEditbox.Save)
	ActionEditor.IDEditbox:SetScript("OnEscapePressed", ActionEditor.IDEditbox.Save)
	
	-- Tooltips (localization handled by the config module)
	Modules.Config:RegisterConfigTooltip(ActionEditor.TypeSpell, { 
		title = "Type: Spell", 
		text = "Select this to make this action affect the display of a spell button."
	})
	Modules.Config:RegisterConfigTooltip(ActionEditor.TypeItem, { 
		title = "Type: Item", 
		text = "Select this to make this action affect the display of an item button."
	})
	Modules.Config:RegisterConfigTooltip(ActionEditor.TypeMacro, { 
		title = "Type: Macro", 
		text = "Select this to make this action affect the display of a macro button."
	})
	Modules.Config:RegisterConfigTooltip(ActionEditor.IDEditbox, { 
		title = "Action Name/ID", 
		text = "The name or ID or the spell, item or macro to alter the display of."
	})
	
	-- Add the necessary functions.
	ActionEditor.UpdateAction = function(self, actionData)
		-- Update the type buttons.
		if(actionData["type"] and actionData["type"] == "spell") then
			-- Enable the spell button.
			ActionEditor.TypeSpell:Select()
			ActionEditor.TypeItem:Deselect()
			ActionEditor.TypeMacro:Deselect()
		elseif(actionData["type"] and actionData["type"] == "item") then
			-- Enable the item button.
			ActionEditor.TypeItem:Select()
			ActionEditor.TypeSpell:Deselect()
			ActionEditor.TypeMacro:Deselect()
		elseif(actionData["type"] and actionData["type"] == "macro") then
			-- Enable the macro button.
			ActionEditor.TypeMacro:Select()
			ActionEditor.TypeSpell:Deselect()
			ActionEditor.TypeItem:Deselect()
		else
			-- Enable no buttons.
			ActionEditor.TypeSpell:Deselect()
			ActionEditor.TypeItem:Deselect()
			ActionEditor.TypeMacro:Deselect()
		end
		-- Update the editboxes.
		if(actionData["id"] and actionData["type"] and actionData["type"] == "spell") then
			-- Update the editbox.
			ActionEditor.IDEditbox:SetText(GetSpellInfo(actionData["id"]) or actionData["id"])
			-- Update the editbox.
		elseif(actionData["id"] and actionData["type"] and actionData["type"] == "item") then
			ActionEditor.IDEditbox:SetText(GetItemInfo(actionData["id"]) or actionData["id"])
			-- Update the editbox.
		elseif(actionData["id"] and actionData["type"] and actionData["type"] == "macro") then
			-- Update the editbox.
			ActionEditor.IDEditbox:SetText(GetMacroInfo(actionData["id"]) or actionData["id"])
		elseif(actionData["id"]) then
			-- Just use the ID/Text.
			ActionEditor.IDEditbox:SetText(actionData["id"])
		else
			-- Clear the editbox.
			ActionEditor.IDEditbox:SetText("")			
		end	
	end
	
	-- Done.
	Modules.Config:RegisterActionConfigFrame(ActionEditor, 1)
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