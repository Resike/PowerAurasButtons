--[[
	PowerAurasButtons
	
	Module: Timer/Stacks
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons
local ModuleFrame      = CoreFrame:RegisterModule("TimerStacks", { "Buttons" }, true)
local Modules          = CoreFrame.Modules
--[[
----------------------------------------------------------------------------------------------------
Variables
	ButtonAuras        Stores a table of all buttons and auras which have timers or stack displays.
	IsUpdating         Set to true when the OnUpdate script is activated, nil otherwise.
	StackFrames        Stores a list of all stack frames on buttons.
	ThrottleTimer      Stores the current throttle progression.
	TimerFrames        Stores a list of all timer frames on buttons.
----------------------------------------------------------------------------------------------------
--]]
local ButtonAuras      = {}
local IsUpdating       = nil
local StackFrames      = {}
local ThrottleTimer    = 0
local TimerFrames      = {}
--[[
----------------------------------------------------------------------------------------------------
GetAuraTimer

Returns the timer values for an aura.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetAuraTimer(aura)
	-- Get the timer frame. Make sure aura exists too :)
	if(not aura or not aura.Timer) then return end
	local timer = aura.Timer
	-- Most of this is copy paste to determine the timer.
	if(timer.enabled==false and timer.InvertAuraBelow==0) then return end
	local newvalue = 0
	--- Determine the value to display in the timer
	if (PowaAurasOptions.ModTest) then
		newvalue = random(0, 99) + (random(0, 99) / 100)		
	elseif (timer.ShowActivation and timer.Start~=nil) then
		newvalue = math.max(GetTime() - timer.Start, 0)	
	elseif (aura.timerduration > 0) then--- if a user defined timer is active for the aura override.
		if (((aura.target or aura.targetfriend) and (PowaAurasOptions.ResetTargetTimers == true)) 
		or not timer.CustomDuration) then
			timer.CustomDuration = aura.timerduration
		end
		-- Was causing the timers to be cut in half.
		-- else
			-- timer.CustomDuration = math.max(timer.CustomDuration - elapsed, 0)
		-- end	
		newvalue = timer.CustomDuration
	elseif (timer.DurationInfo and timer.DurationInfo > 0) then
		newvalue = math.max(timer.DurationInfo - GetTime(), 0)
	end
	-- Righto, moving on. Record it.
	return newvalue
end
--[[
----------------------------------------------------------------------------------------------------
GetAuraStacks

Returns the stacks display on an aura.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetAuraStacks(aura)
	-- Make sure aura exists.
	if(not aura or not aura.Stacks or not aura.Stacks.enabled) then return end
	-- Right then, record it.
	return aura.Stacks.UpdateValueTo or aura.Stacks.lastShownValue
end
--[[
----------------------------------------------------------------------------------------------------
OnAuraShow

Adds the newly shown aura to the list of active timers.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnAuraShow(auraID)
	-- Make sure the update script hasn't fallen off.
	if(not IsUpdating) then
		ModuleFrame:SetScript("OnUpdate", ModuleFrame.OnUpdate)
		IsUpdating = true
	end
end
--[[
----------------------------------------------------------------------------------------------------
OnAuraHide

Removes the now hidden aura from any of the timer or stack frames.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnAuraHide(auraID)
	-- Make sure the update script hasn't fallen off.
	if(not IsUpdating) then
		ModuleFrame:SetScript("OnUpdate", ModuleFrame.OnUpdate)
		IsUpdating = true
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
	if(ButtonAuras[buttonID]) then wipe(ButtonAuras[buttonID]) end
	-- Make sure the update script hasn't fallen off.
	if(not IsUpdating) then
		ModuleFrame:SetScript("OnUpdate", ModuleFrame.OnUpdate)
		IsUpdating = true
	end
end
--[[
----------------------------------------------------------------------------------------------------
OnButtonDisplayAura

Adds the displayed aura to the list of active auras for the given button.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnButtonDisplayAura(buttonID, auraID, actionData, actionID)
	-- Add this aura if we need to.
	if(not actionData["timer"] and not actionData["stacks"]) then return end
	if(not ButtonAuras[buttonID]) then ButtonAuras[buttonID] = {} end
	-- Store the action ID.
	ButtonAuras[buttonID][auraID] = actionID
	-- Make sure the update script hasn't fallen off.
	if(not IsUpdating) then
		ModuleFrame:SetScript("OnUpdate", ModuleFrame.OnUpdate)
		IsUpdating = true
	end
end
--[[
----------------------------------------------------------------------------------------------------
GetCountdownText

Converts time remaining to a nice value to display.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetCountdownText(timeLeft)
	-- 5 types, depending on the time (seconds).
	if(timeLeft >= 3600) then
		-- Hour.
		return format("%dh", floor(timeLeft/3600))
	elseif(timeLeft >= 600) then
		-- 10 minutes.
		return format("%dm", floor(timeLeft/60))
	elseif(timeLeft >= 60) then
		-- 1 minute.
		return format("%d:%02d", floor(timeLeft/60), floor(timeLeft%60))
	elseif(timeLeft >= 10) then
		-- Displays pure seconds while over the threshold (or 10).
		return floor(timeLeft)
	elseif(timeLeft >= 0) then
		-- Displays milliseconds too.
		return format("%.1f", floor(timeLeft*10)/10)
	else
		-- If something odd happened, do a 0.
		return 0
	end
end
--[[
----------------------------------------------------------------------------------------------------
FetchTimerFrame

Fetches/creates the timer frame for the button.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FetchTimerFrame(button, key)
	-- Get the settings.
	local settings = CoreFrame:GetSetting("TimerStacks")
	-- So, does it need one?
	if(not TimerFrames[key]) then
		-- Overlay frame check.
		local overlay = ModuleFrame:FetchOverlayFrame(button)
		-- Make it.
		TimerFrames[key] = overlay:CreateFontString(nil, "OVERLAY")
		-- Extract anchor data, replace parent.
		local to, parent, from, x, y = unpack(settings.TimerAnchors)
		parent = overlay
		-- Anchor.
		TimerFrames[key]:SetPoint(to, parent, from, x, y)
		-- Prettify it.
		TimerFrames[key]:SetTextColor(unpack(settings.TimerColours))
		local isValid = TimerFrames[key]:SetFont(unpack(settings.TimerFont))
		if(not isValid) then
			-- Font not valid, replace with default.
			PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][1] = "Fonts\\FRIZQT__.TTF"
			PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][4] = "Friz Quadrata TT"
			frame:SetFont(unpack(PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"]))
		end
	end
	-- Done.
	return TimerFrames[key]
end
--[[
----------------------------------------------------------------------------------------------------
FetchStacksFrame

Fetches/creates the stacks frame for the button.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FetchStacksFrame(button, key)
	-- Get the settings.
	local settings = CoreFrame:GetSetting("TimerStacks")
	-- So, does it need one?
	if(not StackFrames[key]) then
		-- Overlay frame check.
		local overlay = ModuleFrame:FetchOverlayFrame(button)
		-- Make it.
		StackFrames[key] = overlay:CreateFontString(nil, "OVERLAY")
		-- Extract anchor data, replace parent.
		local to, parent, from, x, y = unpack(settings.StacksAnchors)
		parent = overlay
		-- Anchor.
		StackFrames[key]:SetPoint(to, parent, from, x, y)
		-- Prettify it.
		StackFrames[key]:SetTextColor(unpack(settings.StacksColours))
		local isValid = StackFrames[key]:SetFont(unpack(settings.StacksFont))
		if(not isValid) then
			-- Font not valid, replace with default.
			PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][1] = "Fonts\\FRIZQT__.TTF"
			PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][4] = "Friz Quadrata TT"
			frame:SetFont(unpack(PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"]))
		end
	end
	-- Done.
	return StackFrames[key]
end
--[[
----------------------------------------------------------------------------------------------------
UpdateButtonFrames

Updates all of the timer and stack frames when the configuration changes.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:UpdateButtonFrames()
	-- Get the settings.
	local settings = CoreFrame:GetSetting("TimerStacks")
	-- Loop timers first.
	for key, frame in pairs(TimerFrames) do
		-- Extract anchor data, replace parent.
		local to, parent, from, x, y = unpack(settings.TimerAnchors)
		parent = frame:GetParent()
		-- Anchor.
		frame:ClearAllPoints()
		frame:SetPoint(to, parent, from, x, y)
		-- Prettify it.
		frame:SetTextColor(unpack(settings.TimerColours))
		local isValid = frame:SetFont(unpack(settings.TimerFont))
		if(not isValid) then
			-- Font not valid, replace with default.
			PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][1] = "Fonts\\FRIZQT__.TTF"
			PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"][4] = "Friz Quadrata TT"
			frame:SetFont(unpack(PowerAurasButtons_SettingsDB["TimerStacks"]["TimerFont"]))
		end
	end
	-- Now loop stacks.
	for key, frame in pairs(StackFrames) do
		-- Extract anchor data, replace parent.
		local to, parent, from, x, y = unpack(settings.StacksAnchors)
		parent = frame:GetParent()
		-- Anchor.
		frame:ClearAllPoints()
		frame:SetPoint(to, parent, from, x, y)
		-- Prettify it.
		frame:SetTextColor(unpack(settings.StacksColours))
		local isValid = frame:SetFont(unpack(settings.StacksFont))
		if(not isValid) then
			-- Font not valid, replace with default.
			PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][1] = "Fonts\\FRIZQT__.TTF"
			PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"][4] = "Friz Quadrata TT"
			frame:SetFont(unpack(PowerAurasButtons_SettingsDB["TimerStacks"]["StacksFont"]))
		end
	end
end
--[[
----------------------------------------------------------------------------------------------------
FetchOverlayFrame

Creates a small frame on top of a button, so the text for stacks/timers correctly overlays glows.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FetchOverlayFrame(button)
	-- Get the button ID.
	local buttonID = button:GetName()
	if(not _G[buttonID .. "_PowerAurasOverlay"]) then
		local frame = CreateFrame("Frame", buttonID .. "_PowerAurasOverlay", button)
		frame:SetAllPoints(button)
		frame:SetFrameStrata("HIGH")
		frame:Show()
	end
	-- Return it.
	return _G[buttonID .. "_PowerAurasOverlay"]
end
--[[
----------------------------------------------------------------------------------------------------
OnUpdate

Update loop. Updates the contents of the text displays on the buttons. Will detatch itself if
there's no updates being performed. Throttled to 0.1s.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnUpdate(elapsed)
	-- It's updating.
	IsUpdating = true
	-- Throttle check.
	ThrottleTimer = ThrottleTimer + elapsed
	-- Fix any huge and odd throttle jumps.
	if(ThrottleTimer > 0.5) then ThrottleTimer = 0.1 end
	-- Cap is moving depending on our requirements.
	if(ThrottleTimer < 0.1) then return end
	-- Track total updates done.	
	local hasUpdated = nil
	-- Iterate over buttons.
	for buttonID, auras in pairs(ButtonAuras) do
		-- Figure out if this button is displaying stacks and timers.
		local timersDisplay = Modules.Buttons:GetButtonData(buttonID)["timer"]
		local stacksDisplay = Modules.Buttons:GetButtonData(buttonID)["stacks"]
		-- Calculate the longest of the auras for each.
		local timerDuration, stackCount, timerText = 0, 0, ""
		-- Get the appropriate frames.
		local timerFrame, stackFrame
		timerFrame = ModuleFrame:FetchTimerFrame(_G[buttonID], buttonID)
		stackFrame = ModuleFrame:FetchStacksFrame(_G[buttonID], buttonID)
		-- Only calculate for updates if we are going to update.
		if(timersDisplay or stacksDisplay) then
			-- Iterate over auras.
			for auraID, actionID in pairs(auras) do
				-- Update the timers and stacks for this aura.
				local timer = ModuleFrame:GetAuraTimer(PowaAurasOptions.Auras[auraID])
				local stacks = ModuleFrame:GetAuraStacks(PowaAurasOptions.Auras[auraID])
				local auraDisplays = Modules.Auras:GetAuraAction(auraID, actionID)
				if(auraDisplays) then
					-- Calculate the longest.
					if(auraDisplays["timer"] and timerDuration < (timer or 0)) then
						timerDuration = timer
					end
					if(auraDisplays["stacks"] and stackCount < (stacks or 0)) then
						stackCount = stacks
					end
				end
			end
			-- If timer/stacks are nil, no update performed.
			if(timerDuration > 0 and timersDisplay) then
				-- Update done.
				hasUpdated = true
				-- Make frames if needed, update text. Done.
				timerText = ModuleFrame:GetCountdownText(timerDuration)
				-- Save update calls.
				if(timerFrame:GetText() ~= timerText) then
					timerFrame:SetText(timerText)
				end
				-- Show.
				if(not timerFrame:IsShown()) then
					timerFrame:Show()
				end
			end
			if(stackCount > 0 and stacksDisplay) then
				-- Update done.
				hasUpdated = true
				-- Make frames if needed, update text. Done.
				if(tonumber(stackFrame:GetText(), 10) ~= stackCount) then
					stackFrame:SetText(stackCount)
				end
				-- Show.
				if(not stackFrame:IsShown()) then
					stackFrame:Show()
				end
			end
		end
		-- Hide unused timer frames.
		if((timerDuration == 0 or not timersDisplay) and timerFrame:IsShown()) then
			timerFrame:Hide()
		end
		-- Hide unused stack frames.
		if((stackCount == 0 or not stacksDisplay) and stackFrame:IsShown()) then
			stackFrame:Hide()
		end
	end
	-- Did we update at all?
	if(not hasUpdated) then
		-- No updates, so skip further ones.
		ModuleFrame:SetScript("OnUpdate", nil)
		IsUpdating = nil
	end
	-- Reset throttle.
	while(ThrottleTimer > 0.1) do
		ThrottleTimer = ThrottleTimer - 0.1
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
	actionData["timer"] = nil
	actionData["stacks"] = nil
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
	return CoreFrame:GetModuleSetting("TimerStacks", "Enabled")
end
--[[
----------------------------------------------------------------------------------------------------
FixSettings

Fixes all saved variables and migrates older ones across.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FixSettings(force)
	-- Do the module settings exist?
	if(not CoreFrame:GetSetting("TimerStacks") or force) then
		-- We'd best fix that then.
		PowerAurasButtons_SettingsDB["TimerStacks"] = {
			["Enabled"] = true,
			["TimerAnchors"] = { "BOTTOMLEFT", nil, "BOTTOMLEFT", 7, 5 },
			["TimerColours"] = { 1, 1, 1, 1 },
			["TimerFont"] = { "Fonts\\FRIZQT__.TTF", 11, "OUTLINE", "Friz Quadrata TT" },
			["StacksAnchors"] = { "TOPRIGHT", nil, "TOPRIGHT", -7, -5 },
			["StacksColours"] = { 1, 1, 1, 1 },
			["StacksFont"] = { "Fonts\\FRIZQT__.TTF", 11, "OUTLINE", "Friz Quadrata TT" }
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
	-- This module will not load if disabled.
	if(not ModuleFrame:IsEnabled()) then
		-- Count as an unsuccessful module load.
		return nil
	end
	-- Register module events for aura showing/hiding and button updates.
	CoreFrame:RegisterModuleEventListener("OnButtonProcess", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnButtonDisplayAura", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnAuraShow", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnAuraHide", ModuleFrame)
	CoreFrame:RegisterModuleEventListener("OnActionCreate", ModuleFrame)
	-- Done.
	return true
end