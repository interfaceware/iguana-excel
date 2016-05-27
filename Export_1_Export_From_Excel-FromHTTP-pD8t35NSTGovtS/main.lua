-- A two channel example showing how to export data from Excel and import 
-- it into Iguana using a web service

-- This channel uses a To Channel destination to pass data downline for further
-- processing by another channel, in this case "Export 2: Process Export Data"

-- http://help.interfaceware.com/v6/excel-export

-- Require two framework files
local server = {}
server.serve = require 'excel.server'
local actionTable = require 'iguana.action'

-- These require statements return single functions
-- and are used to handle specific web requests
local GetSpreadSheet     = require 'getspreadsheet'
local GetDefaultPage     = require 'getdefaultpage'
local Upload             = require 'upload'
local GetDefaultUserPage = require 'getdefaultuserpage'

local function SetupActions()
   local Dispatcher = actionTable.create()
   local AdminActions = Dispatcher:actions{group='Administrators', priority=1}
   AdminActions[""]                 = GetDefaultPage
   AdminActions["ExcelExport.xlsm"] = GetSpreadSheet
   AdminActions["upload"]           = Upload
   trace(AdminActions)
  
   local UserActions = Dispatcher:actions{group='Users', priority=2} 
   UserActions[""] = GetDefaultUserPage
   trace(UserActions)
   return Dispatcher
end

function main(Data)
   local Dispatcher = SetupActions()
   server.serve{data=Data, dispatcher=Dispatcher}
   local sheet = {}
   
   user = require 'iguana.user'
   userinfo = user.open()
   userinfo:user{user='dgrady'}
   userinfo:userInGroup{user='admin',group='Administrators'}
end
