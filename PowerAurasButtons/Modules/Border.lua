--[[
	PowerAurasButtons
	
	Module: Border
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons
local ModuleFrame      = CoreFrame:RegisterModule("Border", { "Buttons" }, true)
local Modules          = CoreFrame.Modules
--[[
----------------------------------------------------------------------------------------------------
Variables
	ButtonBorders      Stores a table of buttons and their border data.
	EnabledButtons     Stores a table of all buttons with active borders - we use this to hide them
	                   when the button goes inactive/no longer needs a border.
----------------------------------------------------------------------------------------------------
--]]
local ButtonBorders    = {}
local EnabledButtons   = {}
--[[
----------------------------------------------------------------------------------------------------
OnButtonUpdate

Fired when a button is updated. Used to draw the border.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnButtonUpdate(buttonID)
	-- Get the button and border object.
	local button = _G[buttonID]
	local border = button:GetCheckedTexture()
	-- Only color if it's a button we're supposed to process.
	if(ButtonBorders[buttonID] and ButtonBorders[buttonID][1]) then
		-- Set the color.
		button:SetChecked(true)
		-- Set the new color.
		border:SetVertexColor(unpack(ButtonBorders[buttonID][2]))
		border:Show()
	elseif(EnabledButtons[buttonID]) then
		-- Disable this button.
		border:SetVertexColor(1, 1, 1, 1)
		button:SetChecked(false)
		EnabledButtons[buttonID] = nil
	end
end
--[[
----------------------------------------------------------------------------------------------------
OnButtonProcess

Resets the displayed auras for a specific button.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnButtonProcess(buttonID)
	-- Wipe.
	if(ButtonBorders[buttonID]) then
		wipe(ButtonBorders[buttonID])
	end
end
--[[
----------------------------------------------------------------------------------------------------
OnButtonDisplayAura

Adds the displayed aura to the list of active auras for the given button.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnButtonDisplayAura(buttonID, auraID, actionData)
	-- Add this aura if we need to.
	if(not actionData["border"]) then return end
	if(not ButtonBorders[buttonID]) then ButtonBorders[buttonID] = {} end
	-- Calculate.
	if(not ButtonBorders[buttonID][1] or   
	(actionData["border_priority"] or 25) > (ButtonBorders[buttonID][1] or 25)) then
		-- Make sure it's enabled.
		EnabledButtons[buttonID] = true
		-- It's a higher priority than the currently recorded one.
		ButtonBorders[buttonID][1] = actionData["border_priority"] or 25
		ButtonBorders[buttonID][2] = actionData["border_color"] or { 1, 1, 1, 1 }
	end
end
--[[
----------------------------------------------------------------------------------------------------
OnActionCreate

Fired when an action is created. Used to set defaults in the newly made action ID.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnActionCreate(auraID, actionID)
	-- Get action.
	local actionData = Modules.Auras:GetAuraAction(auraID, actionID)
	-- Write.
	actionData["border"] = nil
	actionData["border_priority"] = 25
	actionData["border_color"] = { 1, 1, 1, 1 }
	-- Save.
	Modules.Auras:SetAuraAction(auraID, actionID, actionData)
end
--[[
----------------------------------------------------------------------------------------------------
IsEnabled

Checks to see if the module is enabled.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:IsEnabled()
	return CoreFrame:GetModuleSetting("Border", "Enabled")
end
--[[
----------------------------------------------------------------------------------------------------
FixSettings

Fixes all saved variables and migrates older ones across.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FixSettings(force)
	-- Do the module settings exist?
	if(not CoreFrame:GetSetting("Border") or force) then
		-- We'd best fix that then.
		PowerAurasButtons_SettingsDB["Border"] = {
			["Enabled"] = true
		}
	end
end
--[[
----------------------------------------------------------------------------------------------------
OnInitialize

Fired by the module handler. Put all the loading code into here.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnInitialize()
	-- Fix settings first.
	ModuleFrame:FixSettings()
	-- Make sure enabled.
	if(not ModuleFrame:IsEnabled()) then
		-- Count as an unsuccessful module load.
		return nil
	end
	-- Register Blizzard button/LAB stuff.
	if(LibStub) then
		local LAB = LibStub("LibActionButton-1.0", true)
		if(LAB) then
			-- Add a button update hook.
			LAB:RegisterCallback("OnButtonState", function(_, button)
				ModuleFrame:OnButtonUpdate(button:GetName())
			end)
		end
	end
	-- Aaand the Blizzard hook.
	hooksecurefunc("ActionButton_UpdateState", function(button)
		ModuleFrame:OnButtonUpdate(button:GetName())
	end)
	-- Register module events for aura showing/hiding and button updates.
	CoreFrame:RegisterModuleEventListener("OnButtonProcess", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnButtonDisplayAura", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnButtonUpdate", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnActionCreate", ModuleFrame)
	-- Done.
	return true
end