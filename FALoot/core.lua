-- Define addon object
FALoot = {};
local A = FALoot;

--[[ =======================================================
     "Object" Definition
     ======================================================= --]]

--[[
   Define addon events functions
   
   A single unique event may have several methods called when it is triggered. These methods
   cannot be unregistered once registered.
--]]
A.events = {};
local E = A.events;
E.list = {};

E.Register = function(event, func)
  if type(event) ~= "string" then
    error("events.Register passed a non-string value for event");
    return;
  elseif type(func) ~= "function" then
    error("events.Register passed a non-function value for func");
    return;
  end
  if not E.list[event] then
    E.list[event] = {};
  end
  table.insert(E.list[event], func);
  
  -- Return the ID of the newly inserted function
  return #E.list[event];
end

E.Trigger = function(event, ...)
  A.util.debug('Event "'..event..'" triggered.', 2);
  if E.list[event] then
    for i=1,#E.list[event] do
      A.util.debug('Calling "'..event..'" function #'..i..'.', 3);
      E.list[event][i](...);
    end
  end
end

--[[
   Define messages, events subfunction

   Each unique message type may be set to have exactly one methods called when it is triggered.
   A method can be unregistered by calling the Unregister() method on the event.
-]]
A.messages = {};
local M = A.messages;
M.list = {};

M.Register = function(event, func)
  if type(event) ~= "string" then
    error("messages.Register passed a non-string value for event");
    return;
  elseif type(func) ~= "function" then
    error("messages.Register passed a non-function value for func");
    return;
  end
  M.list[event] = func;
end

M.Unregister = function(event)
  M.list[event] = nil;
end

M.Trigger = function(mEvent, channel, sender, ...)
  A.util.debug('Message event "'..mEvent..'" triggered.', 2);
  if M.list[mEvent] then
    M.list[mEvent](channel, sender, ...);
  end
end

--[[
  Trigger is handled by appropriate WoW API chat events.
--]]

-- Define session data
A.sData = {};
local SD = A.sData;

-- Define persistent data
A.pData = {};
local PD = A.pData;

-- Define options
PD.options = {};
local O = PD.options;

-- Define functions
A.functions = {};
local F = A.functions;

-- Define UI
A.UI = {};

-- Define slash commands
A.commands = {};
local C = A.commands;
C.list = {};

-- Define slash command register function
C.Register = function(command, handler, desc)
	if type(command) ~= "string" then
		A.util.debug('commands.Register passed a bad value for parameter "command".');
		return;
	elseif type(handler) ~= "function" then
		A.util.debug('commands.Register passed a bad value for parameter "handler".');
		return;
	end
	
	command = string.lower(command);
	
	C.list[command] = {
		["handler"] = handler,
		["desc"] = desc,
	};
end

-- Create and register slash command handler
SLASH_FALOOT1 = "/faloot";
SLASH_FA1 = "/fa";

local function commandHandler(msg, editbox)
	if msg == "" then
		if A.UI.itemWindow then
			A.UI.itemWindow.frame:Show();
		end
	else
		local command = string.lower(string.match(msg, "^(%S+)"));
		
		if command and C.list[command] then
			-- Prepare params
			local params, t = string.match(msg, "^%S+%s+(.+)"), {};
			
			if params then
				for x in string.gmatch(params, "%S+") do
					table.insert(t, x);
				end
			end
			
			-- Pass params to handler
			C.list[command].handler(unpack(t));
			
			return;
		end
		
		-- No match, construct help
		local s = "Command not recognized. The following commands are allowed:\n";
		for i,v in pairs(C.list) do
			s = s .. "/fa " .. i .. " ";
			if v.desc then
				s = s .. v.desc;
			end
			s = s .. "\n"
		end
		A.util.debug(s);
	end
end

SlashCmdList["FALOOT"] = commandHandler;
SlashCmdList["FA"] = commandHandler;


--[[ ==========================================================================
     Addon Definition & Properties
     ========================================================================== --]]
 
A.NAME = "FALoot";
A.MVERSION = 7; -- Addons only communicate with users of the same major version.
A.REVISION = 1; -- Specific code revision for identification purposes.

A.stub = LibStub("AceAddon-3.0"):NewAddon(A.NAME);
LibStub("AceComm-3.0"):Embed(A.stub);

A.COLOR = "FFF9CC30";
A.CHAT_HEADER  = "|c" .. A.COLOR .. "FA Loot:|r ";
A.MSG_PREFIX = "FALoot";
A.DOWNLOAD_URL = "https://github.com/aggixx/FALoot";

--[[ ==========================================================================
     API Events
     ========================================================================== --]]

local eventFrame, events = CreateFrame("Frame"), {}

-- === PLAYER_LOGIN Event =================================================

function events:PLAYER_LOGIN()
	E.Trigger("PLAYER_LOGIN");
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
  events[event](self, ...) -- call one of the functions above
end)
for k, v in pairs(events) do
  eventFrame:RegisterEvent(k) -- Register all events for which handlers have been defined
end