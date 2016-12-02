﻿--[[
Title: BigMod
Author(s):  Big
Date: 2016/12/1
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/big/main.lua");
local big = commonlib.gettable("Mod.big");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/big/BigCommand.lua");
NPL.load("(gl)Mod/big/BigItem.lua");
NPL.load("(gl)Mod/big/BigGUI.lua");
NPL.load("(gl)Mod/big/BigEntity.lua");
NPL.load("(gl)Mod/big/BigSceneContext.lua");
NPL.load("(gl)Mod/big/Login.lua");
NPL.load("(gl)Mod/big/ShowLogin.lua");

local BigSceneContext = commonlib.gettable("Mod.big.BigSceneContext");

local GameLogic       = commonlib.gettable("MyCompany.Aries.Game.GameLogic");

local BigItem		  = commonlib.gettable("Mod.big.BigItem");
local BigGUI          = commonlib.gettable("Mod.big.BigGUI");
local BigEntity		  = commonlib.gettable("Mod.big.BigEntity");
local BigCommand	  = commonlib.gettable("Mod.big.BigCommand");
local Login			  = commonlib.gettable("Mod.big.Login");

local Big = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.big"));

LOG.SetLogLevel("DEBUG");

function Big:ctor()

end

-- virtual function get mod name
function Big:GetName()
	return "big"
end

-- virtual function get mod description 
function Big:GetDesc()
	return "big is a plugin in paracraft"
end

function Big:init()
	BigItem:init();
	BigGUI:init();
	BigEntity:init();
	BigCommand:init();

	BigSceneContext:ApplyToDefaultContext();

	local page = "Mod/big/ShowLogin.html";
	GameLogic.GetFilters():add_filter("LoginPage",function ()
		return page;
	end);

end

function Big:OnInitDesktop()
	LOG.std(nil,"debug","big","OnInitDesktop");
	return true;
end

function Big:OnLogin()
end

-- called when a new world is loaded. 
function Big:OnWorldLoad()
	LOG.std(nil,"info","big","Mod big on world loaded");

	BigGUI:OnWorldLoad();
	--BigItem:OnWorldLoad();
end

function Big:handleKeyEvent(event)
	return BigGUI:handleKeyEvent(event);
end

function Big:OnActivateDesktop(mode)
	local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");

	if(Desktop.mode) then
		-- GameLogic.ADDBBS("test",L"Big进入编辑模式",4000,"0 255 0");
	else
		-- GameLogic.AddBBS("test",L"Big进入游戏模式",4000,"255 255 0");
	end

	return;
end

-- called when a world is unloaded. 
function Big:OnLeaveWorld()
	LOG.std(nil,"info","big","Mod big on leave world");
	BigGUI:OnLeaveWorld();
end

function Big:OnDestroy()
end

function Big:OnClickExitApp()
	--_guihelper.MessageBox("wanna exit?" , function()
		--ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
		--ParaGlobal.ExitApp();
	--end)
	ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
	ParaGlobal.ExitApp();
	return true;
end
