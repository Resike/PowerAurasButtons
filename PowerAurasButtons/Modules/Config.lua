--[[
	PowerAurasButtons
	
	Module: Config
--]]
-- Create module frames.
local CoreFrame        = PowerAurasButtons;
-- Weird dependencies here, it's to make sure the aura and buttons config frames are placed on
-- top of any others in the action editor.
local ModuleFrame      = CoreFrame:RegisterModule("Config", { "AurasConfig" }, true);
local Modules          = CoreFrame.Modules;
--[[
----------------------------------------------------------------------------------------------------
Variables
	ActionEditor       Stores the action editor setting thing frame.
	ActionEditorBase   Stores the action editor base frame.
	ActionEditorList   Stores the action editor list frame.
	Action             Stores the currently selected action ID.
	ActionData         Stores the currently selected action data.
	Aura               Stores the ID of the current aura.
	EditorFrames       Stores a table of all frames appended to the action editor.
	EditorFramesCount  Stores a count of all added editor frames, because #() is so annoying.
	InterfaceOptions   Stores the main interface options panel.
	L                  Localization table.
	ReindexedAuras     Stores a table of reindex auras. Used to move, copy and delete action sets.
----------------------------------------------------------------------------------------------------
--]]
local ActionEditor      = nil;
local ActionEditorBase  = nil;
local ActionEditorList  = nil;
local Action            = nil;
local ActionData        = nil;
local Aura              = nil;
local EditorFrames      = {};
local EditorFramesCount = 0;
local InterfaceOptions  = nil;
local L                 = CoreFrame.L;
local ReindexedAuras    = {};
--[[
----------------------------------------------------------------------------------------------------
tcopy

Does a somewhat deep table copy.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:tcopy(t)
	local t2 = {};
	for k,v in pairs(t) do
		t2[k] = (type(v) == "table" and ModuleFrame:tcopy(v) or v);
	end
	return t2;
end
--[[
----------------------------------------------------------------------------------------------------
GetCurrentActionData

Returns the current ActionData table.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:GetCurrentActionData()
	return ActionData;
end
--[[
----------------------------------------------------------------------------------------------------
CreateInterfaceOptions

Creates the Interface Options frame.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateInterfaceOptions()
	-- Make a parent frame.
	InterfaceOptions = CreateFrame("Frame", nil, UIParent);
	-- Set name and parent.
	InterfaceOptions.name = "Power Auras Classic: Buttons";
	-- Add the child to the Interface Options panel.
	InterfaceOptions_AddCategory(InterfaceOptions);
	
	-- Make the frame a bit more snazzy with titles and crap.
	InterfaceOptions.Title = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
		"GameFontNormalLarge");
	InterfaceOptions.Title:SetText("Power Auras Classic: Buttons");
	InterfaceOptions.Title:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -15);
	
	-- Subtitle too.
	InterfaceOptions.SubTitle = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
		"GameFontNormalSmall");
	InterfaceOptions.SubTitle:SetHeight(30);
	InterfaceOptions.SubTitle:SetText(GetAddOnMetadata("PowerAurasButtons", "Notes"));
	InterfaceOptions.SubTitle:SetTextColor(1, 1, 1);
	InterfaceOptions.SubTitle:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -40);
	InterfaceOptions.SubTitle:SetPoint("TOPRIGHT", InterfaceOptions, "TOPRIGHT", -10, -40);
	InterfaceOptions.SubTitle:SetJustifyH("LEFT");
	InterfaceOptions.SubTitle:SetJustifyV("TOP");
	
	-- Right, let's add some more metadata strings.
	InterfaceOptions.TitleVersion = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
		"GameFontNormalSmall");
	InterfaceOptions.TitleVersion:SetText(L["Version"] .. ":");
	InterfaceOptions.TitleVersion:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -80);
	InterfaceOptions.TitleVersion:SetWidth(100);
	InterfaceOptions.TitleVersion:SetJustifyH("RIGHT");
	InterfaceOptions.TitleVersion:SetJustifyV("TOP");
	InterfaceOptions.Version = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
		"GameFontNormalSmall");
	InterfaceOptions.Version:SetText(GetAddOnMetadata("PowerAurasButtons", "Version"));
	InterfaceOptions.Version:SetTextColor(1, 1, 1);
	InterfaceOptions.Version:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 115, -80);
	InterfaceOptions.Version:SetJustifyH("LEFT");
	InterfaceOptions.Version:SetJustifyV("TOP");
	
	InterfaceOptions.TitleAuthor = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
		"GameFontNormalSmall");
	InterfaceOptions.TitleAuthor:SetText(L["Author"] .. ":");
	InterfaceOptions.TitleAuthor:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -95);
	InterfaceOptions.TitleAuthor:SetWidth(100);
	InterfaceOptions.TitleAuthor:SetJustifyH("RIGHT");
	InterfaceOptions.TitleAuthor:SetJustifyV("TOP");
	InterfaceOptions.Author = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
		"GameFontNormalSmall");
	InterfaceOptions.Author:SetText(GetAddOnMetadata("PowerAurasButtons", "Author"));
	InterfaceOptions.Author:SetTextColor(1, 1, 1);
	InterfaceOptions.Author:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 115, -95);
	InterfaceOptions.Author:SetJustifyH("LEFT");
	InterfaceOptions.Author:SetJustifyV("TOP");
	
	if(CoreFrame.__debug) then
		InterfaceOptions.TitleDebug = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
			"GameFontNormalSmall");
		InterfaceOptions.TitleDebug:SetText(L["Debug"] .. ":");
		InterfaceOptions.TitleDebug:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 10, -110);
		InterfaceOptions.TitleDebug:SetWidth(100);
		InterfaceOptions.TitleDebug:SetJustifyH("RIGHT");
		InterfaceOptions.TitleDebug:SetJustifyV("TOP");
		InterfaceOptions.Debug = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
			"GameFontNormalSmall");
		InterfaceOptions.Debug:SetText("|cFF00FF00Enabled|r");
		InterfaceOptions.Debug:SetTextColor(1, 1, 1);
		InterfaceOptions.Debug:SetPoint("TOPLEFT", InterfaceOptions, "TOPLEFT", 115, -110);
		InterfaceOptions.Debug:SetJustifyH("LEFT");
		InterfaceOptions.Debug:SetJustifyV("TOP");
	end
	
	-- Now for the module switcher. Make a title...
	InterfaceOptions.ModulesTitle = InterfaceOptions:CreateFontString(nil, "ARTWORK", 
		"GameFontNormal");
	InterfaceOptions.ModulesTitle:SetText(L["Module Manager"]);
	InterfaceOptions.ModulesTitle:SetPoint("TOP", InterfaceOptions, "TOP", 0, -130);
	-- Make a scrolly area.
	InterfaceOptions.Modules = CreateFrame("Frame", nil, InterfaceOptions);
	InterfaceOptions.Modules:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	});
	InterfaceOptions.Modules:SetBackdropColor(0, 0, 0, 0.75);
	InterfaceOptions.Modules:SetBackdropBorderColor(0.4, 0.4, 0.4);
	InterfaceOptions.Modules:SetPoint("TOP", InterfaceOptions, "TOP", 0, -145);
	InterfaceOptions.Modules:SetHeight(200);	
	InterfaceOptions.Modules:SetWidth(375);	
	-- List frame needs a scroll frame.
	InterfaceOptions.Modules.Scroll = CreateFrame("ScrollFrame", 
		"PowerAurasButtons_ModuleScrollFrame", InterfaceOptions.Modules, 
		"UIPanelScrollFrameTemplate");
	InterfaceOptions.Modules.Scroll:SetPoint("TOPLEFT", InterfaceOptions.Modules, "TOPLEFT", 5, -5);
	InterfaceOptions.Modules.Scroll:SetPoint("BOTTOMRIGHT", InterfaceOptions.Modules, 
		"BOTTOMRIGHT", -26, 4);	
	-- Scroll frame needs something to actually scroll.
	InterfaceOptions.Modules.List = CreateFrame("Frame", nil, InterfaceOptions.Modules.Scroll);
	InterfaceOptions.Modules.List:SetPoint("TOPLEFT", InterfaceOptions.Modules.Scroll, "TOPLEFT");
	-- Height needs to be set.
	InterfaceOptions.Modules.List:SetHeight(0);
	-- The height needs to match the content, but the width can be that of the box...
	InterfaceOptions.Modules.List:SetWidth(350);
	-- Add the list frame as a scroll child of our SUPER SCROLL FRAME.
	InterfaceOptions.Modules.Scroll:SetScrollChild(InterfaceOptions.Modules.List);
	-- Store the row frames in this table - we'll reuse them as needed.
	InterfaceOptions.Modules.List.Items = {};
	InterfaceOptions.Modules.List.Rows = {};
	
	-- Make a small function, hook it to OnShow. It'll scan the modules and update the list.
	local scanModules;
	scanModules = function()
		-- Make a table of all modules that can be enabled/disabled.
		wipe(InterfaceOptions.Modules.List.Items);
		for module, frame in pairs(CoreFrame.Modules) do
			if(frame.CanDisable) then tinsert(InterfaceOptions.Modules.List.Items, module); end
		end
		-- Hide existing rows.
		for _, row in pairs(InterfaceOptions.Modules.List.Rows) do
			row:Hide();
		end
		-- Using that, fill in the rows.
		for i, module in pairs(InterfaceOptions.Modules.List.Items) do
			-- Make rows dynamically and reuse existing ones.
			if(not InterfaceOptions.Modules.List.Rows[i]) then
				local row = CreateFrame("Frame", nil, InterfaceOptions.Modules.List);
				-- Add textures.
				row.Texture = row:CreateTexture(nil, "BACKGROUND");
				row.Texture:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
				row.Texture:SetAllPoints(row);
				row.Texture:SetVertexColor(1, 1, 1, 0.15);
				-- Height, anchor.
				row:SetHeight(20);
				row:SetPoint("TOPLEFT", InterfaceOptions.Modules.List, "TOPLEFT", 0, -((i-1)*20));
				row:SetPoint("TOPRIGHT", InterfaceOptions.Modules.List, "TOPRIGHT", 0, -((i-1)*20));
				-- Label.
				row.Label = row:CreateFontString(nil, "ARTWORK", "GameFontNormal");
				row.Label:SetHeight(20);
				row.Label:SetPoint("TOPLEFT", row, "TOPLEFT", 10, 0);
				row.Label:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 10, 0);
				-- And a delete button.
				row.Button = CreateFrame("Button", nil, row);
				row.Button:SetPoint("RIGHT", row, "RIGHT", -2, 0);
				row.Button:SetWidth(16);
				row.Button:SetHeight(16);
				-- Register the row.
				InterfaceOptions.Modules.List.Rows[i] = row;
				-- And when you click, we toggle.
				row.Button:SetScript("OnClick", function()
					local module = row.Label:GetText();
					if(CoreFrame:IsModuleEnabled(module)) then
						-- Disable the module.
						CoreFrame:SetModuleSetting(module, "Enabled", nil);
					else
						-- Enable the module.
						CoreFrame:SetModuleSetting(module, "Enabled", true);
					end
					-- ReloadUI is needed :)
					ModuleFrame:CreateGlowBoxWidget(InterfaceOptions);
					-- Rescan.
					scanModules();
				end);
				-- Tooltip.
				ModuleFrame:RegisterConfigTooltip(row.Button, {
					override = function()
						-- Check module status.
						if(CoreFrame:IsModuleEnabled(module)) then
							GameTooltip:SetText(L["Disable Module"]);
							GameTooltip:AddLine(L["Click to disable this module."], 1, 1, 1, 1);
						else
							GameTooltip:SetText(L["Enable Module"]);
							GameTooltip:AddLine(L["Click to enable this module."], 1, 1, 1, 1);
						end
					end
				});
			end
			-- Get row.
			local row = InterfaceOptions.Modules.List.Rows[i];
			-- Set stuff.
			row.Label:SetText(module);
			-- Is the module enabled?
			if(CoreFrame:IsModuleEnabled(module)) then
				-- Enabled, so show disable stuff and color the background greenish.
				row.Button:SetNormalTexture("Interface\\FriendsFrame\\StatusIcon-DnD");
				row.Button:SetHighlightTexture("Interface\\FriendsFrame\\StatusIcon-DnD", "BLEND");
				row.Button:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5);
				row.Button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
				row.Texture:SetVertexColor(0.3, 0.8, 0.3, 0.6);
			else
				-- Disabled. Show enable stuff and color BG red.
				row.Button:SetNormalTexture("Interface\\FriendsFrame\\StatusIcon-Online");
				row.Button:SetHighlightTexture("Interface\\FriendsFrame\\StatusIcon-Online", 
					"BLEND");
				row.Button:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5);
				row.Button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
				row.Texture:SetVertexColor(1.0, 0.5, 0.5, 1.0);
			end
			-- Add height to the list.
			InterfaceOptions.Modules.List:SetHeight(i*20);
			row:Show();
		end
	end
	-- Set the script.
	InterfaceOptions:SetScript("OnShow", scanModules);
end
--[[
----------------------------------------------------------------------------------------------------
CreateActionEditor

Creates the action editing frame.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateActionEditor()
	-- Make the editor frame.
	ActionEditorBase = CreateFrame("Frame", nil, PowaBarConfigFrame, "TranslucentFrameTemplate");
	ActionEditorBase:SetPoint("TOPLEFT", PowaBarConfigFrame, "TOPRIGHT", -13, 1);
	ActionEditorBase:SetHeight(462);
	ActionEditorBase:SetWidth(400);
	ActionEditorBase:EnableMouse(true);
	-- Make it look nice. Add a header.
	ActionEditorBase.Header = ActionEditorBase:CreateTexture(nil, "ARTWORK");
	ActionEditorBase.Header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header");
	ActionEditorBase.Header:SetPoint("TOP", ActionEditorBase, "TOP", 0, 13);	
	ActionEditorBase.Header:SetHeight(68);
	ActionEditorBase.Header:SetWidth(300);
	-- Shove a title in that too.
	ActionEditorBase.Title = ActionEditorBase:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	ActionEditorBase.Title:SetText(L["Action Editor"]);
	ActionEditorBase.Title:SetPoint("TOP", ActionEditorBase.Header, "TOP", 0, -16);
	
	-- Create the list frame.
	ActionEditorList = CreateFrame("Frame", nil, ActionEditorBase);
	ActionEditorList:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	});
	ActionEditorList:SetBackdropColor(0, 0, 0, 0.75);
	ActionEditorList:SetBackdropBorderColor(0.4, 0.4, 0.4);
	ActionEditorList:SetPoint("TOP", ActionEditorBase, "TOP", 0, -25);
	ActionEditorList:SetHeight(200);
	ActionEditorList:SetWidth(375);
	
	-- List frame needs a scroll frame.
	ActionEditorList.Scroll = CreateFrame("ScrollFrame", "PowerAurasButtons_ConfigScrollFrame", 
		ActionEditorList, "UIPanelScrollFrameTemplate");
	ActionEditorList.Scroll:SetPoint("TOPLEFT", ActionEditorList, "TOPLEFT", 5, -5);
	ActionEditorList.Scroll:SetPoint("BOTTOMRIGHT", ActionEditorList, "BOTTOMRIGHT", -26, 4);
	
	-- Scroll frame needs something to actually scroll.
	ActionEditorList.List = CreateFrame("Frame", nil, ActionEditorList.Scroll);
	ActionEditorList.List:SetPoint("TOPLEFT", ActionEditorList.Scroll, "TOPLEFT");
	-- Height needs to be set, we do this when an aura is selected.
	ActionEditorList.List:SetHeight(0);
	-- The height needs to match the content, but the width can be that of the box...
	ActionEditorList.List:SetWidth(ActionEditorList.Scroll:GetWidth());
	-- Add the list frame as a scroll child of our SUPER SCROLL FRAME.
	ActionEditorList.Scroll:SetScrollChild(ActionEditorList.List);
	-- Store the row frames in this table - we'll reuse them as needed.
	ActionEditorList.List.Items = {};
	
	-- And finally, the editor frame.
	ActionEditor = CreateFrame("Frame", nil, ActionEditorBase);
	ActionEditor:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	});
	ActionEditor:SetBackdropColor(0, 0, 0, 0.75);
	ActionEditor:SetBackdropBorderColor(0.4, 0.4, 0.4);
	ActionEditor:SetPoint("TOP", ActionEditorList, "BOTTOM", 0, 0);
	ActionEditor:SetHeight(225);
	ActionEditor:SetWidth(375);
	-- Helper functions for hiding/displaying elements.
	ActionEditor.TogglePanel = function(self, show)
		-- Check the show param.
		if(show) then
			-- Show then.
			ActionEditor:Show();
			ActionEditorBase:SetHeight(462);
		else
			-- Hide!
			ActionEditor:Hide();
			ActionEditorBase:SetHeight(237);
		end
	end
	-- Need a scroll here too.
	ActionEditor.Scroll = CreateFrame("ScrollFrame", "PowerAurasButtons_ActionScrollFrame", 
		ActionEditor, "UIPanelScrollFrameTemplate");
	ActionEditor.Scroll:SetPoint("TOPLEFT", ActionEditor, "TOPLEFT", 5, -5);
	ActionEditor.Scroll:SetPoint("BOTTOMRIGHT", ActionEditor, "BOTTOMRIGHT", -26, 4);
	
	-- Scroll frame needs something to actually scroll.
	ActionEditor.List = CreateFrame("Frame", nil, ActionEditor.Scroll);
	ActionEditor.List:SetPoint("TOPLEFT", ActionEditor.Scroll, "TOPLEFT");
	-- Height needs to be set, we do this when an aura is selected.
	ActionEditor.List:SetHeight(0);
	-- The height needs to match the content, but the width can be that of the box...
	ActionEditor.List:SetWidth(ActionEditor.Scroll:GetWidth());
	-- Add the list frame as a scroll child of our SUPER SCROLL FRAME.
	ActionEditor.Scroll:SetScrollChild(ActionEditor.List);
end
--[[
----------------------------------------------------------------------------------------------------
CreateButtonWidget

Creates a button widget for the CreateActionEditor function.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateButtonWidget(parent, text, icon, disable)
	-- Make the button.
	local button = CreateFrame("Button", nil, parent);
	-- Style it.
	button:SetHeight(26);
	button:SetWidth(110);
	button:SetBackdrop({
		bgFile = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	});
	button:SetBackdropColor(1, 1, 1, 0.15);
	button:SetBackdropBorderColor(0.4, 0.4, 0.4);
	-- Disabled?
	if(disable) then
		button:SetAlpha(0.5);
	else	
		-- Mouseover stuff.
		button:SetScript("OnEnter", function()
			button:SetBackdropColor(0.196, 0.388, 0.8, 1.0);
		end);
		button:SetScript("OnLeave", function()
			if(not button.Selected) then button:SetBackdropColor(1, 1, 1, 0.15); end
		end);
	end
	
	-- Label.
	button.Label = button:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	button.Label:SetHeight(26);
	button.Label:SetPoint("CENTER", button, "CENTER", 0, 0);
	button.Label:SetText(text);
	
	-- Icon.
	if(icon) then
		button.Icon = button:CreateTexture(nil, "ARTWORK");
		button.Icon:SetPoint("LEFT", button, "LEFT", 5, 0);
		button.Icon:SetWidth(16);
		button.Icon:SetHeight(16);
		button.Icon:SetTexture(icon);
	end
	
	-- And add a couple of helpful functions to the button.
	button.Select = function()
		button.Selected = true;
		button:SetBackdropColor(0.196, 0.388, 0.8, 1.0);
	end;
	button.Deselect = function()
		button.Selected = nil;
		button:SetBackdropColor(1, 1, 1, 0.15);
	end;
	
	-- Deselect by default..
	button:Deselect();
	-- Done.
	return button;
end
--[[
----------------------------------------------------------------------------------------------------
CreateHeaderWidget

Creates a header widget for the CreateActionEditor function.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateHeaderWidget(text, parent, y)
	-- Make the label.
	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	label:SetHeight(20);
	label:SetPoint("TOP", parent, "TOP", 0, y);
	label:SetText(L[text]);
	-- Header background stuff.
	label.bg = parent:CreateTexture(nil, "ARTWORK");
	label.bg:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
	label.bg:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y);
	label.bg:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y);
	label.bg:SetHeight(20);
	label.bg:SetVertexColor(1, 1, 1, 0.15);
	-- Done.
	return label;
end
--[[
----------------------------------------------------------------------------------------------------
CreateColorWidget

Creates a color selection widget.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateColorWidget(parent)
	-- Make.
	frame = CreateFrame("Button", nil, parent);
	frame:SetWidth(16);
	frame:SetHeight(16);
	frame.Swatch = frame:CreateTexture(nil, "OVERLAY");
	frame.Swatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
	frame.Swatch:SetAllPoints(frame);
	frame.SwatchBG = frame:CreateTexture(nil, "BACKGROUND");
	frame.SwatchBG:SetWidth(14);
	frame.SwatchBG:SetHeight(14);
	frame.SwatchBG:SetTexture(1, 1, 1, 1);
	frame.SwatchBG:SetPoint("CENTER", frame.Swatch);
	frame.SwatchTrans = frame:CreateTexture(nil, "BACKGROUND");
	frame.SwatchTrans:SetWidth(12);
	frame.SwatchTrans:SetHeight(12);
	frame.SwatchTrans:SetTexture("Tileset\\Generic\\Checkers");
	frame.SwatchTrans:SetTexCoord(.25, 0, 0.5, .25);
	frame.SwatchTrans:SetDesaturated(true);
	frame.SwatchTrans:SetVertexColor(1, 1, 1, 0.75);
	frame.SwatchTrans:SetPoint("CENTER", frame.Swatch);
	frame.SwatchTrans:Show();
	-- Done.
	return frame;
end
--[[
----------------------------------------------------------------------------------------------------
CreateGlowBoxWidget

Creates a glowbox widget for the given frame. This by default shows a Reload Required message.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:CreateGlowBoxWidget(parent)
	-- Only make if needed.
	if(not parent.GlowBox) then
		-- Sort out the glowbox.
		parent.GlowBox = CreateFrame("Frame", nil, parent, "GlowBoxTemplate");
		parent.GlowBox:SetPoint("BOTTOMRIGHT", InterfaceOptionsFrameOkay, "TOPRIGHT", 0, 25);
		parent.GlowBox:SetWidth(275);
		parent.GlowBox:SetHeight(50);
		parent.GlowBox.Arrow = CreateFrame("Frame", nil, parent.GlowBox, "GlowBoxArrowTemplate");
		parent.GlowBox.Arrow:SetPoint("TOPRIGHT", parent.GlowBox, "BOTTOMRIGHT");
		-- Glowbox titles.
		parent.GlowBox.Title = parent.GlowBox:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		parent.GlowBox.Title:SetText(L["Reload Required"]);
		parent.GlowBox.Title:SetPoint("TOPLEFT", parent.GlowBox, "TOPLEFT", 10, -5);
		parent.GlowBox.Title:SetPoint("TOPRIGHT", parent.GlowBox, "TOPRIGHT", -10, -5);
		parent.GlowBox.Title:SetJustifyH("CENTER");
		parent.GlowBox.Title:SetJustifyV("TOP");
		-- And now text.
		parent.GlowBox.Text = parent.GlowBox:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		parent.GlowBox.Text:SetText(
			L["You have altered settings which require an interface reload to take effect."]);
		parent.GlowBox.Text:SetPoint("TOPLEFT", parent.GlowBox, "TOPLEFT", 10, -20);
		parent.GlowBox.Text:SetPoint("BOTTOMRIGHT", parent.GlowBox, "BOTTOMRIGHT", -10, 5);
		parent.GlowBox.Text:SetJustifyH("LEFT");
		parent.GlowBox.Text:SetJustifyV("TOP");
		parent.GlowBox.Text:SetTextColor(1, 1, 1);
		-- Make the okay function on the parent reload the UI.
		parent.okay = function()
			-- Reload.
			ReloadUI();
		end
	end
	-- Show the glowbox.
	parent.GlowBox:Show();
end
--[[
----------------------------------------------------------------------------------------------------
UpdateSelectedAura

Updates the opened aura in the power auras config frame.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:UpdateSelectedAura(auraID, actionID)
	-- Set aura.
	Aura = auraID;
	-- Get all actions for this aura.
	local actions = Modules.Auras:GetAuraActions(auraID);
	-- Hide all rows.
	for _, row in pairs(ActionEditorList.List.Items) do
		row:Hide();
		row:Deselect();
	end
	-- Do we have actions?
	if(actions and #(actions) > 0) then
		-- It has actions. Go over them.
		for actionID, actionData in pairs(actions) do
			-- Fetch the item row.
			local row = ModuleFrame:FetchActionRow(actionID);
			-- Set the icon and text.
			if(actionData["type"] == "spell" and actionData["id"]) then
				row.Icon:SetTexture("Interface\\GossipFrame\\TrainerGossipIcon");
				row.Label:SetText(GetSpellLink(actionData["id"]), L["Invalid spell ID"]);
			elseif(actionData["type"] == "macro" and actionData["id"]) then
				row.Icon:SetTexture("Interface\\GossipFrame\\BinderGossipIcon");
				row.Label:SetText(GetMacroInfo(actionData["id"]) or L["Invalid macro ID"]);
			elseif(actionData["type"] == "item" and actionData["id"]) then
				row.Icon:SetTexture("Interface\\GossipFrame\\VendorGossipIcon");
				row.Label:SetText(select(2, GetItemInfo(actionData["id"])), L["Invalid item ID"]);
			else
				row.Icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
				row.Label:SetText(L["No action set"]);
			end
			-- Show it.
			row:Show();
		end
	elseif(not actions) then
		-- See if actions is nil - if so, make some.
		Modules.Auras:SetAuraActions(auraID, {});
		actions = {};
	end
	-- Add the "add new item..." row.
	local addRow = ModuleFrame:FetchActionAddRow();
	addRow:SetPoint("TOPLEFT", ActionEditorList.List, "TOPLEFT", 0, -(#(actions)*20));
	addRow:SetPoint("TOPRIGHT", ActionEditorList.List, "TOPRIGHT", 0, -(#(actions)*20));
	-- Update the list frame height.
	ActionEditorList.List:SetHeight((#(actions) + 1)*20);
	-- Show frame.
	ActionEditorBase:Show();
	-- Reset selected action.
	ModuleFrame:UpdateSelectedAction(actionID);
end
--[[
----------------------------------------------------------------------------------------------------
UpdateSelectedAction

Updates the selected action in the action editor frame.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:UpdateSelectedAction(actionID)
	-- Update vars.
	Action = actionID;
	ActionData = actionID and Modules.Auras:GetAuraAction(Aura, actionID);
	-- Make sure no other row is classed as 'selected'.
	for id, row in pairs(ActionEditorList.List.Items) do
		if(actionID and actionID == id) then row:Select(); else row:Deselect(); end
	end
	-- Right, was an action passed?
	if(not actionID) then
		-- Hide the actual editor frame.
		ActionEditor:TogglePanel();
	else
		-- Show editor frame.
		ActionEditor:TogglePanel(true);
		-- Go over the editor frames and trigger an UpdateAction.
		for _, frame in pairs(EditorFrames) do
			frame:UpdateAction(ActionData);
			frame:Show();
		end
	end
end
--[[
----------------------------------------------------------------------------------------------------
UpdateActionData

Updates the action data for the selected action.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:UpdateActionData(index, value)
	-- Set.
	ActionData[index] = value;
	-- Save.
	Modules.Auras:SetAuraAction(Aura, Action, ActionData);
	-- Reload.
	ModuleFrame:UpdateSelectedAura(Aura, Action);
	if(CoreFrame:IsModuleEnabled("Auras")) then Modules.Auras:ResetAuras(); end
end
--[[
----------------------------------------------------------------------------------------------------
FetchActionAddRow

Creates and returns the "Add new item..." row for the action list.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FetchActionAddRow()
	-- Make if not exists.
	if(not ActionEditorList.AddRow) then
		local addRow = CreateFrame("Frame", nil, ActionEditorList.List);
		addRow:EnableMouse(true);
		-- Add textures.
		addRow.Texture = addRow:CreateTexture(nil, "BACKGROUND");
		addRow.Texture:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
		addRow.Texture:SetAllPoints(addRow);
		addRow.Texture:SetVertexColor(1, 1, 1, 0.15);
		-- Add an onenter/onleave script for the highlight toggle.
		addRow:SetScript("OnEnter", function() 
			addRow.Texture:SetVertexColor(0.196, 0.388, 0.8, 1.0);
		end);
		addRow:SetScript("OnLeave", function()
			addRow.Texture:SetVertexColor(1, 1, 1, 0.15);
		end);
		-- Height, anchor.
		addRow:SetHeight(20);
		-- Label.
		addRow.Label = addRow:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		addRow.Label:SetHeight(20);
		addRow.Label:SetPoint("TOPLEFT", addRow, "TOPLEFT", 24, 0);
		addRow.Label:SetPoint("BOTTOMLEFT", addRow, "BOTTOMLEFT", 24, 0);
		addRow.Label:SetText(L["Add new action..."]);
		-- Event handler for clicking the row.
		addRow:SetScript("OnMouseUp", function()
			-- Pass the action creation call to the Auras module and reload.
			ModuleFrame:UpdateSelectedAura(Aura, Modules.Auras:CreateAuraAction(Aura));
		end);
		-- Save.
		ActionEditorList.AddRow = addRow;
	end
	-- Done.
	return ActionEditorList.AddRow;
end
--[[
----------------------------------------------------------------------------------------------------
FetchActionRow

Creates and returns an action editor row for the editor list. Reuses rows if they exist.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FetchActionRow(actionID)
	-- Row exist or not?
	if(not ActionEditorList.List.Items[actionID]) then
		-- Make it.
		local row = CreateFrame("Frame", nil, ActionEditorList.List);
		row:EnableMouse(true);
		-- Add textures.
		row.Texture = row:CreateTexture(nil, "BACKGROUND");
		row.Texture:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
		row.Texture:SetAllPoints(row);
		row.Texture:SetVertexColor(1, 1, 1, 0.15);
		-- Add an onenter/onleave script for the highlight toggle.
		row:SetScript("OnEnter", function() 
			row.Texture:SetVertexColor(0.196, 0.388, 0.8, 1.0);
		end);
		row:SetScript("OnLeave", function()
			if(not row.Selected) then row.Texture:SetVertexColor(1, 1, 1, 0.15); end
		end);
		-- Height, anchor.
		row:SetHeight(20);
		row:SetPoint("TOPLEFT", ActionEditorList.List, "TOPLEFT", 0, -((actionID-1)*20));
		row:SetPoint("TOPRIGHT", ActionEditorList.List, "TOPRIGHT", 0, -((actionID-1)*20));
		-- Add an icon texture and a label.
		row.Icon = row:CreateTexture(nil, "ARTWORK");
		row.Icon:SetPoint("TOPLEFT", row, "TOPLEFT", 2, -2);
		row.Icon:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 2, 2);
		row.Icon:SetWidth(16);
		-- Label.
		row.Label = row:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		row.Label:SetHeight(20);
		row.Label:SetPoint("TOPLEFT", row, "TOPLEFT", 24, 0);
		row.Label:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 24, 0);
		-- And a delete button.
		row.Delete = CreateFrame("Button", nil, row);
		row.Delete:SetNormalTexture("Interface\\FriendsFrame\\ClearBroadcastIcon");
		row.Delete:SetHighlightTexture("Interface\\FriendsFrame\\ClearBroadcastIcon", "BLEND");
		row.Delete:SetPoint("RIGHT", row, "RIGHT", -2, 0);
		row.Delete:SetWidth(16);
		row.Delete:SetHeight(16);
		-- Put a tooltip onto the delete button.
		ModuleFrame:RegisterConfigTooltip(row.Delete, {
			title = "Delete Action",
			text = "Click to delete this action."
		});
		-- Sort out the texture colours.
		row.Delete:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 0.25);
		row.Delete:GetHighlightTexture():SetVertexColor(0.75, 0.0, 0.0, 1.0);
		-- When you click the delete button...Delete.
		row.Delete:SetScript("OnClick", function()
			-- Remove.
			Modules.Auras:RemoveAuraAction(Aura, actionID);
			-- Reload the aura.
			ModuleFrame:UpdateSelectedAura(Aura);
		end);
		-- And when we click, trigger a chosen action update.
		row:SetScript("OnMouseUp", function()
			ModuleFrame:UpdateSelectedAction(actionID);
		end);
		-- And add a couple of helpful functions to the row.
		row.Select = function()
			row.Selected = true;
			row.Texture:SetVertexColor(0.196, 0.388, 0.8, 1.0);
		end;
		row.Deselect = function()
			row.Selected = nil;
			row.Texture:SetVertexColor(1, 1, 1, 0.15);
		end;
		-- Save.
		row:Deselect();
		ActionEditorList.List.Items[actionID] = row;
		-- Make sure it's hidden.
		row:Hide();
	end
	-- Return it.
	return ActionEditorList.List.Items[actionID];
end
--[[
----------------------------------------------------------------------------------------------------
RegisterActionConfigFrame

Appends an additional frame to the action editor window.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:RegisterActionConfigFrame(frame, position)
	-- Was a position set?
	if(position and EditorFramesCount >= position) then
		-- Reparent the frame.
		frame:SetParent(ActionEditor.List);
		-- We're going to need to inject this frame into the position and move things as needed.
		-- Thankfully, each frame is anchored to another so we just need to move the one we're
		-- moving down.
		local oldFrame = EditorFrames[position];
		oldFrame:ClearAllPoints();
		oldFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -5);
		oldFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -5);
		-- And position the new frame...
		frame:SetPoint("TOPLEFT",
			EditorFrames[(position-1)] or ActionEditor.List,
			EditorFrames[(position-1)] and "BOTTOMLEFT" or "TOPLEFT",
			0,
			EditorFrames[(position-1)] and -5 or 0
		);
		frame:SetPoint("TOPRIGHT",
			EditorFrames[(position-1)] or ActionEditor.List,
			EditorFrames[(position-1)] and "BOTTOMRIGHT" or "TOPRIGHT",
			0,
			EditorFrames[(position-1)] and -5 or 0
		);
		-- Inject.
		tinsert(EditorFrames, position, frame);
		EditorFramesCount = EditorFramesCount+1;
	else
		-- Re-parent and re-position the frame as if no position was set.
		frame:SetParent(ActionEditor.List);
		frame:SetPoint("TOPLEFT",
			EditorFrames[EditorFramesCount] or ActionEditor.List,
			EditorFrames[EditorFramesCount] and "BOTTOMLEFT" or "TOPLEFT",
			0,
			EditorFrames[EditorFramesCount] and -5 or 0
		);
		frame:SetPoint("TOPRIGHT",
			EditorFrames[EditorFramesCount] or ActionEditor.List,
			EditorFrames[EditorFramesCount] and "BOTTOMRIGHT" or "TOPRIGHT",
			0,
			EditorFrames[EditorFramesCount] and -5 or 0
		);
		-- Add to the table.
		tinsert(EditorFrames, frame);
		EditorFramesCount = EditorFramesCount+1;
	end
	-- Alter the height of the scroll frame.
	ActionEditor.List:SetHeight(ActionEditor.List:GetHeight() + frame:GetHeight() + 5);
end
--[[
----------------------------------------------------------------------------------------------------
RegisterInterfaceOptionsFrame

Appends an additional frame to the Interface Options panel.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:RegisterInterfaceOptionsFrame(name) 
	-- Make a child frame.
	local childFrame = CreateFrame("Frame", nil, InterfaceOptions);
	-- Set name and parent.
	childFrame.name = name;
	childFrame.parent = "Power Auras Classic: Buttons";
	-- Add the child to the Interface Options panel.
	InterfaceOptions_AddCategory(childFrame);
	-- Make the frame a bit more snazzy with titles and crap.
	childFrame.Title = childFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	childFrame.Title:SetText("Power Auras Classic: Buttons");
	childFrame.Title:SetPoint("TOPLEFT", childFrame, "TOPLEFT", 10, -15);
	-- Subtitle too.
	childFrame.SubTitle = childFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	childFrame.SubTitle:SetText(L[name]);
	childFrame.SubTitle:SetTextColor(1, 1, 1);
	childFrame.SubTitle:SetPoint("TOPLEFT", childFrame, "TOPLEFT", 10, -40);
	childFrame.SubTitle:SetPoint("TOPRIGHT", childFrame, "TOPRIGHT", -10, -40);
	childFrame.SubTitle:SetHeight(30);
	childFrame.SubTitle:SetJustifyH("LEFT");
	childFrame.SubTitle:SetJustifyV("TOP");
	-- And return it.
	return childFrame;
end
--[[
----------------------------------------------------------------------------------------------------
RegisterConfigTooltip

Adds a tooltip to the given frame.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:RegisterConfigTooltip(frame, options)
	-- Fill in anchor/offsets if blank.
	if(not options) then options = {}; end
	if(not options.anchor) then options.anchor = "ANCHOR_RIGHT"; end
	if(not options.offsetX) then options.offsetX = 0; end
	if(not options.offsetY) then options.offsetY = 0; end
	if(not options.title) then options.title = ""; end
	if(not options.text) then options.text = ""; end
	-- Allow a tip refresh.
	frame.RefreshTooltip = function()
		-- Hide tip.
		GameTooltip:Hide();
		-- Reparent.
		GameTooltip:SetOwner(frame, options.anchor, options.offsetX, options.offsetY);
		-- Set back up.
		if(not options.override) then
			-- Go nuts brah.
			GameTooltip:SetText(L[options.title]);
			-- Enable line wrapping. I totally did NOT just find out that existed.
			GameTooltip:AddLine(L[options.text], 1, 1, 1, 1);
		else
			-- Run the override func.
			options.override();
		end
		-- Show tip.
		GameTooltip:Show();
	end
	-- Use the RefreshTooltip function as a display method.
	frame:SetScript("OnEnter", frame.RefreshTooltip);
	-- Hide on leave.
	frame:SetScript("OnLeave", function() GameTooltip:Hide(); end);
end
--[[
----------------------------------------------------------------------------------------------------
OnModuleLoaded

Fired by the module handler, contains the name of the loaded module.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:OnModuleLoaded(module)
	-- Bounce it to our events.
	CoreFrame:FireModuleEvent("OnCreateConfigurationFrame", module);
	CoreFrame:FireModuleEvent("OnCreateInterfaceOptionsFrame", module);
end
--[[
----------------------------------------------------------------------------------------------------
IsEnabled

Checks to see if the module is enabled.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:IsEnabled()
	return CoreFrame:GetModuleSetting("Config", "Enabled");
end
--[[
----------------------------------------------------------------------------------------------------
FixSettings

Fixes all saved variables and migrates older ones across.
----------------------------------------------------------------------------------------------------
--]]
function ModuleFrame:FixSettings(force)
	-- Do the module settings exist?
	if(not CoreFrame:GetSetting("Config") or force) then
		-- We'd best fix that then.
		PowerAurasButtons_SettingsDB["Config"] = {
			["Enabled"] = true
		};
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
	-- Make sure enabled.
	if(not ModuleFrame:IsEnabled()) then
		-- Disabling the config module is...Different. It still counts as a failure, dependency
		-- wise, but it will allow you to still turn modules on and off.
		ModuleFrame:CreateInterfaceOptions();
		-- Done.
		return nil;
	end
	-- Create the action editor frame.
	ModuleFrame:CreateActionEditor();
	-- Create the interface options pane.
	ModuleFrame:CreateInterfaceOptions();
	-- Create some events for modules to hook on to.
	CoreFrame:RegisterModuleEvent("OnCreateConfigurationFrame");
	CoreFrame:RegisterModuleEvent("OnCreateInterfaceOptionsFrame");
	-- Fire those events for already loaded modules (passing nil as the module name).
	CoreFrame:FireModuleEvent("OnCreateConfigurationFrame", nil);
	CoreFrame:FireModuleEvent("OnCreateInterfaceOptionsFrame", nil);	
	-- Listen to the OnModuleLoaded event.
	CoreFrame:RegisterModuleEventListener("OnModuleLoaded", ModuleFrame);
	-- This function runs when the PA options pane opens.
	local script = function()
		-- Update the aura if it's valid and show the config frame if it's not up.
		if(PowaAuras.Auras[PowaAuras.CurrentAuraId] and PowaBarConfigFrame:IsShown()) then
			-- Update aura.
			ModuleFrame:UpdateSelectedAura(PowaAuras.CurrentAuraId);
		else
			-- Hide if it's not valid or not open.
			ActionEditorBase:Hide();

		end
	end
	-- Add needed hooks.
	PowaBarConfigFrame:HookScript("OnShow", script);
	PowaBarConfigFrame:HookScript("OnHide", script);
	hooksecurefunc(PowaAuras, "InitPage", script);
	hooksecurefunc(PowaAuras, "UpdateMainOption", script);
	-- Also hook copying/moving. We can move aura sets like that.
	hooksecurefunc(PowaAuras, "DoCopyEffect", function(_, idFrom, idTo, isMove)
		-- Figure out the config tables for each.
		local oldConfig = PowerAurasButtons_CharacterAurasDB;
		local newConfig = PowerAurasButtons_CharacterAurasDB;
		if(idFrom > 120) then oldConfig = PowerAurasButtons_AurasDB; end
		if(idTo > 120) then newConfig = PowerAurasButtons_AurasDB; end
		-- See if we had any auras in these spots.
		if(oldConfig[idFrom]) then
			-- Right, place these at the new location.
			newConfig[idTo] = ModuleFrame:tcopy(oldConfig[idFrom]);
			-- Was it a move?
			if(isMove) then
				-- Remove the old config.
				wipe(oldConfig[idFrom]);
			end
		end
		-- Button update.
		if(CoreFrame:IsModuleEnabled("Auras")) then Modules.Auras:ResetAuras(); end
	end);
	-- And aura deleting (we would hook DeleteAura but it messes up with moving effects).
	hooksecurefunc(PowaAuras, "OptionDeleteEffect", function(_, auraID)
		-- Determine the config table this one belonged to.
		local config = PowerAurasButtons_CharacterAurasDB;
		if(auraID > 120) then config = PowerAurasButtons_AurasDB; end
		-- Did it exist?
		if(config[auraID] and not tContains(ReindexedAuras, auraID)) then
			-- Remove it.
			wipe(config[auraID]);
		end
		-- Clear the reindex table.
		wipe(ReindexedAuras);
		-- Button update.
		if(CoreFrame:IsModuleEnabled("Auras")) then Modules.Auras:ResetAuras(); end
	end);
	-- If you delete an aura, it'll cause a re-indexing of ones after (delete #1 and #2 moves).
	hooksecurefunc(PowaAuras, "ReindexAura", function(_, idFrom, idTo)
		-- Figure out the config tables for each.
		local oldConfig = PowerAurasButtons_CharacterAurasDB;
		local newConfig = PowerAurasButtons_CharacterAurasDB;
		if(idFrom > 120) then oldConfig = PowerAurasButtons_AurasDB; end
		if(idTo > 120) then newConfig = PowerAurasButtons_AurasDB; end
		-- Move old to new.
		if(oldConfig[idFrom]) then
			-- Right, place these at the new location.
			newConfig[idTo] = ModuleFrame:tcopy(oldConfig[idFrom]);
			-- Reindexing does NOT cause DeleteAura to fire.
			wipe(oldConfig[idFrom]);
			-- Add this to the table of reindexed auras.
			tinsert(ReindexedAuras, idTo);
		end
		-- Button update.
		if(CoreFrame:IsModuleEnabled("Auras")) then Modules.Auras:ResetAuras(); end
	end);
	-- Done.
	return true;
end
