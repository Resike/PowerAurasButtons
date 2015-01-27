--[[
	PowerAurasButtons
	
	Module: Buttons
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons;
local ModuleFrame      = CoreFrame:RegisterModule("Buttons", { "Auras" });
local Modules          = CoreFrame.Modules;
--[[
----------------------------------------------------------------------------------------------------
Variables
	Buttons            Stores all registered buttons in a table.
	ButtonsBySlot      All button objects by their action/slot ID.
	ButtonData         Stores the switches for each button - whether it should glow, etc.
	ButtonQueue        Stores a queue of buttons to be updated.
	ButtonsQueued      Boolean value set to true when buttons are queued.
	ButtonQueueAll     Updates all buttons next time.
	ThrottleTimer      Stores the current throttle timer for mass updates.
----------------------------------------------------------------------------------------------------
--]]
local Buttons          = {};
local ButtonsBySlot    = {};
local ButtonData       = {};
local ButtonQueue      = {};
local ButtonsQueued    = false;
local ButtonQueueAll   = false;
local ThrottleTimer    = 0;
-- Upvalues.
local unpack, setmetatable, ActionButton_ShowOverlayGlow, ActionButton_HideOverlayGlow, wipe, type, GetActionInfo, 
	GetMacroSpell, GetMacroItem, pairs, IsSpellOVerlayed, hooksecurefunc = unpack, setmetatable, 
	ActionButton_ShowOverlayGlow, ActionButton_HideOverlayGlow, wipe, type, GetActionInfo, GetMacroSpell, GetMacroItem, 
	pairs, IsSpellOVerlayed, hooksecurefunc;
-- Caches.
local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end});
local function GetSpellInfo(a)
    return unpack(spellcache[a]);
end
local itemcache = setmetatable({}, {__index=function(t,v) local a = {GetItemInfo(v)} if GetItemInfo(v) then t[v] = a end return a end});
local function GetItemInfo(a)
    return unpack(spellcache[a]);
end
--[[
----------------------------------------------------------------------------------------------------
GetButtons

Returns all the buttons!
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetButtons()
	return Buttons;
end
--[[
----------------------------------------------------------------------------------------------------
OnButtonUpdate

Event handler for button updates. Updates glows depending on assigned auras, etc.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnButtonUpdate(button)
	-- Only bother updating if we can see it.
	if(not button or not button:IsShown()) then return; end
	-- Test the button for glowability.
	ModuleFrame:ProcessButtonActions(button);
	-- Fire button update event.
	CoreFrame:FireModuleEvent("OnButtonUpdate", button:GetName());
	-- So, does the glow need showing or hiding?
	if(ModuleFrame:GetButtonData(button:GetName())["glow"]) then
		-- Show the glow.
		ActionButton_ShowOverlayGlow(button);
	else
		-- Hide the glow.
		ActionButton_HideOverlayGlow(button);
	end
end
--[[
----------------------------------------------------------------------------------------------------
GetButtonData

Retrieves the button data table for the given button ID. Returns nil on failure.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetButtonData(buttonID)
	-- Go.
	return ButtonData[buttonID] or nil;
end
--[[
----------------------------------------------------------------------------------------------------
ProcessButtonActions

Processes all of the assigned actions on a button. This will determine whether a button should
be glowing, showing displays, etc.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:ProcessButtonActions(button)
	-- Few locals.
	local buttonID = button:GetName();
	-- Get the button data table if it exists. Otherwise, make a new one. We recycle the old one
	-- so the memory size won't fluctuate.
	local buttonData = ButtonData[buttonID] or {};
	-- Wipe the data.
	wipe(buttonData);
	-- Fire button processing event.
	CoreFrame:FireModuleEvent("OnButtonProcess", buttonID);
	-- Get the non blizzard auras.
	local CustomAuras, BlizzAuras = Modules.Auras:GetAuras();
	-- More locals.
	local buttonAction, buttonActionType, buttonActionID, buttonMacro, displayCount;
	-- Get the button action ID.
	buttonAction = button._state_action or button.action;
	-- Action needs to be integer.
	if(not buttonAction or type(buttonAction) ~= "number") then
		-- Action isn't valid.
		ButtonData[buttonID] = buttonData;
		return;
	end
	-- Make sure button is cached by slot.
	ButtonsBySlot[buttonAction] = button;
	-- Get the button action data.
	buttonActionType, buttonActionID = GetActionInfo(buttonAction);
	-- Get macro names if needed.
	if(buttonActionType == "macro") then
		buttonMacro = GetMacroSpell(buttonActionID) or GetMacroItem(buttonActionID);
	end
	-- Right, first off we need to go over all the auras see if they're linked to this one.
	for auraID, _ in pairs(CustomAuras) do
		-- Aura needs to be active.
		if(Modules.Auras:IsAuraShown(auraID)) then
			-- And go over the actions.
			for auraActionID, auraActionData in pairs(Modules.Auras:GetAuraActions(auraID)) do
				-- Action needs to be a valid ID (> 0)
				if(auraActionData["id"] and auraActionData["id"] > 0) then
					-- If the type/data keys match, or this is a macro/spell combo then continue.
					if(buttonActionType == auraActionData["type"] 
					or (buttonActionType == "macro" and auraActionData["type"] == "spell")
					or (buttonActionType == "macro" and auraActionData["type"] == "item")) then
						-- Compare ID's. If they match, we're golden. If they don't, do macro
						-- comparisons.
						if((buttonActionID == auraActionData["id"] 
						and buttonActionType == auraActionData["type"])
						or buttonMacro and (auraActionData["type"] == "spell" 
						and GetSpellInfo(auraActionData["id"]) == buttonMacro
						or auraActionData["type"] == "item" 
						and GetItemInfo(auraActionData["id"]) == buttonMacro)) then
							-- Enable glows if the action says so.
							Modules.Auras:MergeAuraAction(buttonData, auraActionData);
							-- Fire the OnAuraDisplay event.
							CoreFrame:FireModuleEvent("OnButtonDisplayAura", buttonID, auraID, 
								auraActionData, auraActionID);
						end
					end
				end
			end
		end
	end
	-- Blizzard auras need checking if glow isn't on, and if enabled.
	if(CoreFrame:GetModuleSetting("Buttons", "ShowBlizzardGlows")) then
		if(not buttonData["glow"] and buttonActionType == "spell" 
		and IsSpellOverlayed(buttonActionID)) then
			-- It needs to glow.
			buttonData["glow"] = true;
		elseif(not buttonData["glow"] and buttonActionType == "macro") then
			-- Macros should glow too.
			buttonMacro = GetMacroSpell(buttonActionID) or GetMacroItem(buttonActionID);
			-- Loop over active Blizzard auras.
			for blizzAuraID, _ in pairs(BlizzAuras) do
				-- Check ID.
				if(not buttonData["glow"] and buttonMacro
				and (buttonMacro == GetSpellInfo(blizzAuraID)
				or GetItemInfo(blizzAuraID) == buttonMacro)) then
					-- Yeah, it's a match. Timers/Stacks aren't on for blizz ones.
					buttonData["glow"] = true;
					break; -- Break early, it doesn't matter if any others are glowing or not.
				end
			end
		end
	end
	-- Update.
	ButtonData[buttonID] = buttonData;
end
--[[
----------------------------------------------------------------------------------------------------
UpdateAllButtons

Fired when OnAuraShow/OnAuraHide are called. Performs a mass button update.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:UpdateAllButtons()
	-- Queue all buttons for an update.
	ButtonQueueAll = true;
	ButtonsQueued = true;
end
--[[
----------------------------------------------------------------------------------------------------
UpdateButton

Registers a single button for an update.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:UpdateButton(button)
	-- Register button for update.
	if(not ButtonQueueAll and Buttons[button:GetName()]) then
		ButtonQueue[button:GetName()] = button;
	end
	-- Flag queue.
	ButtonsQueued = true;
end
--[[
----------------------------------------------------------------------------------------------------
OnUpdate

Acts as our function for throttling update requests. It's called OnUpdate but is only present 
while we're throttling - we unregister it after.
----------------------------------------------------------------------------------------------------
--]]
do
local throttle = 0;

function ModuleFrame:OnUpdate(elapsed)
	throttle = throttle+elapsed;
	if(throttle >= 1) then
		
		throttle = throttle-1;
	end
	-- Update time elapsed.
	ThrottleTimer = ThrottleTimer + (ButtonsQueued and elapsed or 0);
	-- Time up?
	if(ThrottleTimer < CoreFrame:GetModuleSetting("Buttons", "Throttle")) then return; end
	-- Process queue.
	for buttonID, state in pairs((ButtonQueueAll and Buttons or ButtonQueue)) do
		-- Increment counter.
		if(state) then
			-- Remove from queue...
			ButtonQueue[buttonID] = false;
			-- This one is weird, since the ButtonQueue stores a state boolean but ButtonQueueAll iterates over the 
			-- Buttons table directly.
			local button = (ButtonQueueAll and state or Buttons[buttonID]);
			-- If button is true, resolve it to an actual button.
			if(button == true) then
				Buttons[buttonID] = _G[buttonID] or true;
				button = Buttons[buttonID];
			end
			-- Does button exist now?
			if(button and button ~= true) then
				ModuleFrame:OnButtonUpdate(button);
			end
		end
	end
	-- Clear booleans.
	ButtonsQueued = false;
	ButtonQueueAll = false;
	-- Reset throttle.
	ThrottleTimer = ThrottleTimer - CoreFrame:GetModuleSetting("Buttons", "Throttle");
end

end
--[[
----------------------------------------------------------------------------------------------------
RegisterButtons

Registers buttons into our button array for glow activation purposes.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:RegisterButtons(key, count)
	-- Register, nils included (it's a Dominos thing)
	local button = nil;
	for i=1,(count or 12) do
		-- Register it.
		if(not CoreFrame:GetModuleSetting("Buttons", "IgnoredButtons")[key .. i]) then
			Buttons[key .. i] = _G[key .. i] or true;
		end
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
	local actionData = Modules.Auras:GetAuraAction(auraID, actionID);
	-- Write.
	actionData["glow"] = true;
	-- Save.
	Modules.Auras:SetAuraAction(auraID, actionID, actionData);
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
FixSettings

Fixes all saved variables and migrates older ones across.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FixSettings(force)
	-- Do the module settings exist?
	if(not CoreFrame:GetSetting("Buttons") or force) then
		-- We'd best fix that then.
		PowerAurasButtons_SettingsDB["Buttons"] = {
			["Throttle"] = 0.05,
			["RegisterBlizzardButtons"] = true,
			["ShowBlizzardGlows"] = true,
			["IgnoredButtons"] = {},
		};
	end
	-- Compatibility.
	if(PowerAurasButtons_SettingsDB["Buttons"]["IgnoredButtons"] == nil) then
		PowerAurasButtons_SettingsDB["Buttons"]["IgnoredButtons"] = {};
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
	ModuleFrame:FixSettings();
	-- Register the needed buttons.
	if(Dominos) then
		-- Dominos reuses the Blizzard AB's and creates 60 of its own.
		CoreFrame:Debug("Dominos detected");
		ModuleFrame:RegisterButtons("DominosActionButton", 60);
	elseif(RazerNaga) then
		-- Register additional buttons. Dominos style.
		ModuleFrame:RegisterButtons("RazerNagaActionButton", 60);
	elseif(LibStub) then
		-- Bartender4 is a tad more tricky. It uses LAB which makes buttons as needed.
		-- So we need to check for LAB (and LibStub), then scan all loaded buttons and make
		-- sure future ones are added.
		local LAB = LibStub("LibActionButton-1.0", true);
		if(LAB) then
			CoreFrame:Debug("Bartender4/LibActionButton detected");
			-- LibActionButton found. Go over all of the buttons.
			for button in pairs(LAB:GetAllButtons()) do
				Buttons[button:GetName()] = button;
				-- Store by slot too.
				if(button._state_action) then
					ButtonsBySlot[button._state_action] = button;
				end
			end
			-- In addition, make sure this applies to future buttons.
			LAB:RegisterCallback("OnButtonCreated", function(_, button)
				Buttons[button:GetName()] = button;
				-- Store by slot too.
				if(button._state_action) then
					ButtonsBySlot[button._state_action] = button;
				end
			end);
--			-- Add a button update hook.
--			LAB:RegisterCallback("OnButtonUpdate", function(_, button)
--				if(not button:IsShown()) then return; end
--				ModuleFrame:UpdateButton(button);
--			end);
		end
	end
	-- Odds are you're using the default buttons if you're not using Dominos/BT.
	-- Register them if not told otherwise.
	if(CoreFrame:GetModuleSetting("Buttons", "RegisterBlizzardButtons") or Dominos or RazerNaga) then
		CoreFrame:Debug("Registering Blizzard buttons");
		ModuleFrame:RegisterButtons("ActionButton");
		ModuleFrame:RegisterButtons("BonusActionButton");
		ModuleFrame:RegisterButtons("MultiBarRightButton");
		ModuleFrame:RegisterButtons("MultiBarLeftButton");
		ModuleFrame:RegisterButtons("MultiBarBottomRightButton");
		ModuleFrame:RegisterButtons("MultiBarBottomLeftButton");
	end
--	-- If you use Dominos or have the Blizzard buttons on, you need this.
--	if(Dominos or RazerNaga or CoreFrame:GetModuleSetting("Buttons", "RegisterBlizzardButtons")) then
--		-- Hook for button updates.
--		hooksecurefunc("ActionButton_Update", function(button)
--			if(not button:IsShown()) then return; end
--			ModuleFrame:UpdateButton(button);
--		end);
--	end
	-- Update only if slot data changes.
	CoreFrame:RegisterBlizzEventListener("ACTIONBAR_SLOT_CHANGED", ModuleFrame, function(self, id)
		if(id == 0 or not ButtonsBySlot[id]) then
			ModuleFrame:UpdateAllButtons();
		else
			ModuleFrame:UpdateButton(ButtonsBySlot[id]);
		end
	end);
	-- Create some events for modules to hook on to.
	CoreFrame:RegisterModuleEvent("OnButtonUpdate");
	CoreFrame:RegisterModuleEvent("OnButtonProcess");
	CoreFrame:RegisterModuleEvent("OnButtonDisplayAura");
	-- Register OnAuraShow/OnAuraHide.
	CoreFrame:RegisterModuleEventListener("OnAuraShow", ModuleFrame, ModuleFrame.UpdateAllButtons);
	CoreFrame:RegisterModuleEventListener("OnAuraHide", ModuleFrame, ModuleFrame.UpdateAllButtons);
	CoreFrame:RegisterModuleEventListener("OnActionCreate", ModuleFrame);
	-- Updates are throttled and processed in an update loop.
	ModuleFrame:SetScript("OnUpdate", ModuleFrame.OnUpdate);
	-- Done.
	return true;
end
