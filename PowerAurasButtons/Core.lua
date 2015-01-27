--[[
	PowerAurasButtons
	
	Module: Core
--]]
-- Make a frame for the core module.
local CoreFrame        = CreateFrame("Frame", "PowerAurasButtons", UIParent);
--[[
----------------------------------------------------------------------------------------------------
Variables
	__debug            Debugging flag. Set to true while debugging.
	L                  Localization table.
----------------------------------------------------------------------------------------------------
--]]
local __debug          = nil;
local L                = setmetatable({}, {__index=function(t,i) return i end});
--[[
----------------------------------------------------------------------------------------------------
Module Properties
	BlizzEvents        Table of all registered Blizzard events, except ADDON_LOADED.
	Events             Table of all registered module events and their listeners.
	__debug            Debugging flag. Set to true while debugging. Accessible to all modules.
	Modules            Table of all registered modules.
	L                  Localization table. Accessible to all modules.
----------------------------------------------------------------------------------------------------
--]]
CoreFrame.BlizzEvents  = {};
CoreFrame.Events       = {};
CoreFrame.__debug      = __debug;
CoreFrame.Modules      = {};
CoreFrame.L            = L;
--[[
----------------------------------------------------------------------------------------------------
Debug

Passes a call to Print if debugging is enabled.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:Debug(...)
	-- Check debug flag.
	if(__debug) then CoreFrame:Print(...); end
end
--[[
----------------------------------------------------------------------------------------------------
Print

Writes a line. Simple.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:Print(str, ...)
	if(...) then
		print(format("|cFF527FCCPower Auras Classic Buttons: |r" .. L[str], ...));
	else
		print("|cFF527FCCPower Auras Classic Buttons: |r" .. L[str]);	
	end
end
--[[
----------------------------------------------------------------------------------------------------
InitModule

Initializes a module, effectively used to load it.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:InitModule(module)
	CoreFrame:Debug("Initializing module: %s", module);
	-- See if a frame with this modules name is attached.
	if(not CoreFrame.Modules[module]) then
		-- Module not found.
		CoreFrame:Debug("|cFFC41F3BModule not found: |c%s", module);
		return;
	end
	-- Make sure it hasn't already been loaded.
	if(CoreFrame.Modules[module].Loaded) then return true; end
	if(CoreFrame.Modules[module].Failed) then return; end
	-- Load any dependencies.
	if(not CoreFrame:InitModuleDeps(module)) then
		-- Dependency failure..
		CoreFrame:Debug("|cFFC41F3BDependencies failure for module: |c%s", module);
		return;	
	end
	-- Initialize it.
	if(CoreFrame.Modules[module]:OnInitialize()) then
		-- Toggle the loaded field to true.
		CoreFrame.Modules[module].Loaded = true;
		CoreFrame:FireModuleEvent("OnModuleLoaded", module);
		CoreFrame:Debug("Initialized module: %s", module);
		return true;
	else
		CoreFrame.Modules[module].Failed = true;
		CoreFrame:Debug("|cFFC41F3BFailed to initialize module: |c%s", module);
		return;
	end
end
--[[
----------------------------------------------------------------------------------------------------
InitModuleDeps

Initializes any dependencies for the module. Returns nil if a dependency failed to load.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:InitModuleDeps(module)
	-- Get the dependencies.
	local deps = CoreFrame.Modules[module].Deps;
	CoreFrame:Debug("Initializing module dependencies for: %s (%s dependencies)", module, #(deps));
	-- If there's none, return already.
	if(#(deps) == 0) then return true; end
	-- Attempt to load the dependencies.
	for _, dep in pairs(deps) do
		-- If one fails to load, it's the end.
		if(not CoreFrame:InitModule(dep)) then return; end
	end
	-- Loaded.
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
InitAllModules

Initializes all unloaded registered modules.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:InitAllModules()
	-- Go forth.
	for module, _ in pairs(CoreFrame.Modules) do
		-- Initialize.
		CoreFrame:InitModule(module);
	end
end
--[[
----------------------------------------------------------------------------------------------------
RegisterModule

Registers a module - called so that InitModule knows what frames to initialize.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:RegisterModule(name, deps, canDisable)
	CoreFrame:Debug("Registering module: %s", name);
	-- Don't re-register modules.
	if(CoreFrame.Modules[name]) then
		-- Module already registered.
		CoreFrame:Debug("|cFFC41F3BModule already registered: |c%s", name);
		return;
	end
	-- Create.
	local module = CreateFrame("Frame", nil, CoreFrame);
	-- local module = {};
	-- Sort out fields/properties.
	module.Name = name;
	module.Loaded = nil;
	module.Failed = nil;
	module.CanDisable = canDisable or nil;
	module.Deps = deps or {};
	-- Register and return.
	CoreFrame.Modules[name] = module;
	return module;
end
--[[
----------------------------------------------------------------------------------------------------
IsModuleEnabled

Checks if a module is enabled.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:IsModuleEnabled(name)
	-- Is it?
	if(CoreFrame.Modules[name]) then
		-- Enabled.
		return CoreFrame.Modules[name]:IsEnabled();
	else
		-- Nope...
		return nil;
	end
end
--[[
----------------------------------------------------------------------------------------------------
IsModuleLoaded

Checks if a module is loaded.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:IsModuleLoaded(name)
	-- Is it?
	if(CoreFrame.Modules[name]) then
		-- Enabled.
		return CoreFrame.Modules[name].Loaded;
	else
		-- Nope...
		return nil;
	end
end
--[[
----------------------------------------------------------------------------------------------------
RegisterModuleEvent

Registers a module event. Any module can call these events, by default.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:RegisterModuleEvent(event)
	CoreFrame:Debug("Registering module event: %s", event);
	-- Attach.
	CoreFrame.Events[event] = CoreFrame.Events[event] or {};
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
RegisterModuleEventListener

Adds an event listener to a given event name.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:RegisterModuleEventListener(event, frame, func)
	CoreFrame:Debug("Registering module event listener for event: %s", event);
	-- Event needs to exist.
	if(not CoreFrame.Events[event]) then
		CoreFrame.Events[event] = {};
	end
	-- Attach.
	tinsert(CoreFrame.Events[event], func or frame[event]);
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
RegisterBlizzEventListener

Adds an event listener to a given event name.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:RegisterBlizzEventListener(event, frame, func)
	CoreFrame:Debug("Registering blizzard event listener for event: %s", event);
	-- Event needs to exist.
	if(not CoreFrame.BlizzEvents[event]) then
		CoreFrame:RegisterEvent(event);
		CoreFrame.BlizzEvents[event] = {};
	end
	-- Attach.
	tinsert(CoreFrame.BlizzEvents[event], func or frame[event]);
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
FireModuleEvent

Fires a module event.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:FireModuleEvent(event, ...)
	-- Event needs to exist.
	if(not CoreFrame.Events[event]) then
		-- Event not found.
		CoreFrame:Debug("|cFFC41F3BEvent not found: |c%s", event);
		return;
	end
	-- Fire.
	for k,func in pairs(CoreFrame.Events[event]) do
		func(self, ...);
	end
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
FireBlizzEvent

Fires a blizzard event.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:FireBlizzEvent(event, ...)
	CoreFrame:Debug("Firing blizzard event: %s", event);
	-- Event needs to exist.
	if(not CoreFrame.BlizzEvents[event]) then
		-- Event not found.
		CoreFrame:Debug("Blizzard event not found: %s", event);
		return;
	end
	-- Fire.
	for k,func in pairs(CoreFrame.BlizzEvents[event]) do
		func(self, ...);
	end
	return true;
end
--[[
----------------------------------------------------------------------------------------------------
GetSetting

Retrieves a setting from the database.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:GetSetting(setting)
	-- Go forth.
	return PowerAurasButtons_SettingsDB[setting];
end
--[[
----------------------------------------------------------------------------------------------------
SetSetting

Sets a setting into the database.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:SetSetting(setting, value)
	-- Go forth.
	PowerAurasButtons_SettingsDB[setting] = value;
end
--[[
----------------------------------------------------------------------------------------------------
GetModuleSetting

Retrieves a setting from the database for a specific module.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:GetModuleSetting(module, setting)
	-- Go forth.
	return PowerAurasButtons_SettingsDB[module][setting];
end
--[[
----------------------------------------------------------------------------------------------------
SetModuleSetting

----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:SetModuleSetting(module, setting, value)
	-- Go forth.
	PowerAurasButtons_SettingsDB[module][setting] = value;
end
--[[
----------------------------------------------------------------------------------------------------
FixSettings

Fixes all saved variables and migrates older ones across.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:FixSettings()
	-- Make sure they're all set. In the case of SettingsDB, add defaults (hence why it's a func).
	if(not PowerAurasButtons_AurasDB) then PowerAurasButtons_AurasDB = {}; end
	if(not PowerAurasButtons_CharacterAurasDB) then PowerAurasButtons_CharacterAurasDB = {}; end
	-- Table for defaults.
	if(not PowerAurasButtons_SettingsDB) then
		-- Modules store their own config in here.
		PowerAurasButtons_SettingsDB = {};
		-- Fix module settings too.
		for module, frame in pairs(CoreFrame.Modules) do
			if(frame.FixSettings) then
				frame:FixSettings(true);
			end
		end
	end
end
--[[
----------------------------------------------------------------------------------------------------
Events

Required Events:
	ADDON_LOADED
----------------------------------------------------------------------------------------------------
--]]
CoreFrame:RegisterEvent("ADDON_LOADED");
--[[
----------------------------------------------------------------------------------------------------
Event Handler

Handles the aforementioned events.
----------------------------------------------------------------------------------------------------
--]]
function CoreFrame:OnEvent(event, ...)
	-- Check events (DAMN YOU NEW FEATURES!)
	if(event == "ADDON_LOADED") then
		-- Make sure we're the loaded one.
		if(... == "PowerAurasButtons") then
			-- Fix config first.
			CoreFrame:FixSettings();
			-- Create an epic event.
			CoreFrame:RegisterModuleEvent("OnModuleLoaded");
			-- Debugging message.
			CoreFrame:Debug("Initializing modules");
			-- Initialize core modules.
			CoreFrame:InitAllModules();
			CoreFrame:Debug("Modules initialized");
		end
	elseif(CoreFrame.BlizzEvents[event]) then
		-- Fire all handlers.
		CoreFrame:FireBlizzEvent(event, ...);
	end
end
-- Register.
CoreFrame:SetScript("OnEvent", CoreFrame.OnEvent);