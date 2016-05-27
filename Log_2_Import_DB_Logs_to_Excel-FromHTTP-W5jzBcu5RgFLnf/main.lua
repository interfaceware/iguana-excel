-- A two channel example showing how to export log data from Iguana 
-- into a database and then import it into Excel using a web service

-- This channel imports Iguana log data from a SQLite database populated
-- by another channel, in this case "Log 1: Export Logs to DB"

-- http://help.interfaceware.com/v6/excel-import

-- We get the general framework
local server = {}
server.serve = require 'excel.server'
local actionTable = require 'iguana.action'

-- These requires each return a single function which
-- is assigned to a handler in our action table.
local Default        = require 'getdefaultpage'
local GetLogInfo     = require 'getloginfo'
local GetSpreadSheet = require 'getspreadsheet'
local Reset          = require 'reset'

local function SetupActions()
   local Dispatcher = actionTable.create()
   local AdminActions = Dispatcher:actions{group='Administrators', priority=1}
   AdminActions[""]                 = Default
   AdminActions["LogAnalysis.xlsm"] = GetSpreadSheet
   AdminActions["feed"]             = GetLogInfo
   AdminActions["reset"]            = Reset
   trace(AdminActions)
   local UserActions = Dispatcher:actions{group='Users', priority=2} 
   UserActions[""] = GetDefaultUserPage
   return Dispatcher
end

function main(Data)
   local Dispatcher = SetupActions()
   server.serve{data=Data, dispatcher=Dispatcher}   
end

