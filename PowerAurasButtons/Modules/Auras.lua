--[[
	PowerAurasButtons
	
	Module: Auras
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons;
local ModuleFrame      = CoreFrame:RegisterModule("Auras");
local Modules          = CoreFrame.Modules;
--[[
----------------------------------------------------------------------------------------------------
Variables
	ActiveAuras        Stores a list of auras alongside their associated action data tables.
	BlizzAuras         Stores a list of active spell overlays fired by Blizzard's spell events.
----------------------------------------------------------------------------------------------------
--]]
local ActiveAuras      = {};
local BlizzAuras       = {};
--[[
----------------------------------------------------------------------------------------------------
OnAuraShow

Triggered when an aura shows. Adds the aura to the active list and triggers a button update.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnAuraShow(auraID)
	-- Only continue if we have an aura ID.
	if(not auraID or (PowaAuras.Auras[auraID] and PowaAuras.Auras[auraID].off)) then return; end
	-- In addition, if this aura is already active then don't reshow it.
	if(ModuleFrame:IsAuraShown(auraID)) then return; end
	-- It needs actions to be shown.
	local actions = ModuleFrame:GetAuraActions(auraID);
	if(not actions or #(actions) == 0) then
		return;
	end
	-- Register as active.
	ActiveAuras[auraID] = true;
	-- Right, fire events.
	CoreFrame:FireModuleEvent("OnAuraShow", auraID);
end
--[[
----------------------------------------------------------------------------------------------------
OnAuraHide

Triggered when an aura hides. Removes the aura from the list and triggers a button update.
The secondary aura argument is ignored.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnAuraHide(aura)
	-- Continue if there is a valid aura passed.
	if(not aura) then return; end
	-- In addition, if this aura is already NOT active then don't bother updating.
	if(not ModuleFrame:IsAuraShown(aura.id)) then return; end
	-- Register as active.
	ActiveAuras[aura.id] = nil;
	-- Right, fire events.
	CoreFrame:FireModuleEvent("OnAuraHide", aura.id);
end
--[[
----------------------------------------------------------------------------------------------------
SPELL_ACTIVATION_OVERLAY_GLOW_SHOW

Triggered when a blizzard aura shows. Adds the aura to the active list and triggers a button update.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(auraID)
	-- No need to register twice.
	if(BlizzAuras[auraID]) then return; end
	-- Register as active. if the settings tell us to.
	BlizzAuras[auraID] = true;
	-- Right, fire events.
	CoreFrame:FireModuleEvent("OnAuraShow", auraID);
end
--[[
----------------------------------------------------------------------------------------------------
SPELL_ACTIVATION_OVERLAY_GLOW_HIDE

Triggered when a blizzard aura hides. Removes the aura from the list and triggers a button update.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(auraID)
	-- Only unregister if needed.
	if(not BlizzAuras[auraID]) then return; end
	-- Register as inactive.
	BlizzAuras[auraID] = nil;
	-- Right, fire events.
	CoreFrame:FireModuleEvent("OnAuraHide", auraID);
end
--[[
----------------------------------------------------------------------------------------------------
GetActionTable

Returns the listing from the ActionTable table which has the given key, or nil.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetActionTable(key)
	return (key and ActionTable[key]) or (not key and ActionTable) or nil;
end
--[[
----------------------------------------------------------------------------------------------------
GetAuras

Retrieves all of active auras.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetAuras()
	return ActiveAuras, BlizzAuras;
end
--[[
----------------------------------------------------------------------------------------------------
ResetAuras

Resets the active aura table and rescans currently active auras.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:ResetAuras()
	-- Reset.
	ActiveAuras = {};
	-- Scan.
	for i=1,360 do
		if(PowaAuras.Auras[i] and PowaAuras.Auras[i].Showing) then
			 ModuleFrame:OnAuraShow(i);
		end
	end
end
--[[
----------------------------------------------------------------------------------------------------
IsAuraShown

Sees if a given aura ID is registered as being active.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:IsAuraShown(auraID)
	-- Check it.
	if(ActiveAuras[auraID]) then
		return true;
	else
		return nil;
	end
end
--[[
----------------------------------------------------------------------------------------------------
GetAuraActions

Retrieves all of the actions assigned to a specific aura ID.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetAuraActions(auraID)
	-- Get the correct configuration table.
	if(auraID > 120) then
		-- Global config.
		return PowerAurasButtons_AurasDB[auraID-120] or {};
	else
		-- Per-char config.
		return PowerAurasButtons_CharacterAurasDB[auraID] or {};
	end
end
--[[
----------------------------------------------------------------------------------------------------
SetAuraActions

Sets a table of actions to the given aura ID.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:SetAuraActions(auraID, actions)
	-- Get the correct configuration table.
	if(auraID > 120) then
		-- Global config.
		PowerAurasButtons_AurasDB[auraID-120] = actions;
	else
		-- Per-char config.
		PowerAurasButtons_CharacterAurasDB[auraID] = actions;
	end
	-- Done.
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
GetAuraAction

Retrieves a single aura action.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetAuraAction(auraID, actionID)
	-- Get the actions table and retrieve the index.
	return ModuleFrame:GetAuraActions(auraID)[actionID];
end
--[[
----------------------------------------------------------------------------------------------------
SetAuraAction

Updates a single aura action.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:SetAuraAction(auraID, actionID, actionData)
	-- Get the actions table.
	local actions = ModuleFrame:GetAuraActions(auraID);
	-- Write.
	actions[actionID] = actionData;
	-- Save.
	ModuleFrame:SetAuraActions(auraID, actions);
end
--[[
----------------------------------------------------------------------------------------------------
MergeAuraAction

Merges two action data tables, toggling off switches to on.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:MergeAuraAction(actionTable, actionData)
	-- Go over the data table.
	if(not actionData) then return actionTable; end
	for key, value in pairs(actionData) do
		-- If the key is any of ours (type/id), ignore.
		if(key ~= "type" and key ~= "id") then
			-- Write.
			actionTable[key] = actionTable[key] or actionData[key];
		end
	end
	-- Done.
	return actionTable;
end
--[[

----------------------------------------------------------------------------------------------------
CreateAuraAction

Adds a new action to the given aura ID.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateAuraAction(auraID)
	-- Make sure it has actions.
	local actions = ModuleFrame:GetAuraActions(auraID);
	if(not actions) then actions = {}; end
	-- Add the action.
	tinsert(actions, { ["type"] = "spell", ["id"] = 0 });
	-- Save.
	ModuleFrame:SetAuraActions(auraID, actions);
	-- Fire OnActionCreate.
	CoreFrame:FireModuleEvent("OnActionCreate", auraID, #(actions));
	-- Return the count of the actions.
	return #(actions);
end
--[[
----------------------------------------------------------------------------------------------------
RemoveAuraAction

Removes an action from the given aura ID.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:RemoveAuraAction(auraID, actionID)
	-- Get the actions.
	local actions = ModuleFrame:GetAuraActions(auraID);
	if(not actions) then actions = {}; end
	-- Remove if possible.
	tremove(actions, actionID);
	-- Save.
	ModuleFrame:SetAuraActions(auraID, actions);
end
--[[
----------------------------------------------------------------------------------------------------
IsEnabled

Checks to see if the module is enabled.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:IsEnabled()
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
OnInitialize

Fired by the module handler. Put all the loading code into here.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnInitialize()
	-- Hook Power Auras' aura hide/display mechanisms. Create events for them.
	hooksecurefunc(PowaAuras, "DisplayAura", ModuleFrame.OnAuraShow);
	hooksecurefunc(PowaAuras, "SetAuraHideRequest", ModuleFrame.OnAuraHide);
	-- Register Blizzard aura events.
	CoreFrame:RegisterBlizzEventListener("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", ModuleFrame);
	CoreFrame:RegisterBlizzEventListener("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", ModuleFrame);
	-- Make events.
	CoreFrame:RegisterModuleEvent("OnActionCreate");
	CoreFrame:RegisterModuleEvent("OnAuraShow");
	CoreFrame:RegisterModuleEvent("OnAuraHide");
	-- Done.
	return true;
end
