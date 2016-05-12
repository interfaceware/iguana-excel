-- This represents the boiler plate for a channel representing an Iguana webservice channel
-- serving data up to Excel

-- We get the general framework
local server = require 'excel.server'
local actionTable = require 'iguana.action'

-- These requires each return a single function which
-- is assigned to a handler in our action table.
local Default        = require 'getdefaultpage'
local GetLogInfo     = require 'getloginfo'
local GetSpreadSheet = require 'getspreadsheet'
local Reset          = require 'reset'
local Report         = require 'report'

local function SetupActions()
   local Dispatcher = actionTable.create()
   local AdminActions = Dispatcher:actions{group='Administrators', priority=1}
   AdminActions[""]           = Default
   AdminActions["sheet.xlsm"] = GetSpreadSheet
   AdminActions["feed"]       = GetLogInfo
   AdminActions["reset"]      = Reset
   AdminActions["report"]     = Report
   trace(AdminActions)
   local UserActions = Dispatcher:actions{group='Users', priority=2} 
   UserActions[""] = GetDefaultUserPage
   return Dispatcher
end

function main(Data)
   local Dispatcher = SetupActions()
   server.serve{data=Data, dispatcher=Dispatcher}   
end

