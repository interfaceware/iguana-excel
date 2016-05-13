-- http://help.interfaceware.com/v6/excel-exporter
-- Example show how we can export data to Excel.

-- Require two framework files
local server = require 'excel.server'
local actionTable = require 'iguana.action'

-- These require statements return single functions
-- and are used to handle specific web requests
local GetSpreadSheet     = require 'getspreadsheet'
local GetDefaultPage     = require 'getdefaultpage'
local Upload             = require 'upload'
local GetDefaultUserPage = require 'getdefaultuserpage'

function SetupActions()
   local Dispatcher = actionTable.create()
   local AdminActions = Dispatcher:actions{group='Administrators', priority=1}
   AdminActions[""] = GetDefaultPage
   AdminActions["sheet.xlsm"] = GetSpreadSheet
   AdminActions["upload"] = Upload
   trace(AdminActions)
  
   local UserActions = Dispatcher:actions{group='Users', priority=2} 
   UserActions[""] = GetDefaultUserPage
   trace(UserActions)
   return Dispatcher
end

function main(Data)
   local Dispatcher = SetupActions()
   server.serve{data=Data, dispatcher=Dispatcher}   
end

