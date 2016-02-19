local server = require 'excel.server'
local actionTable = require 'iguana.action'

require 'getspreadsheet'
require 'getdefaultpage'
require 'getloginfo'
require 'reset'

basicauth = require 'web.basicauth'

function SetupActions()
   local Dispatcher = actionTable.create()
   local AdminActions = Dispatcher:actions{group='Administrators', priority=1}
   AdminActions[""] = GetDefaultPage
   AdminActions["sheet.xlsm"] = FetchSpreadSheet
   AdminActions["feed"] = GetLogInfo
   AdminActions["reset"] = Reset
   
   local UserActions = Dispatcher:actions{group='Users', priority=2} 
   UserActions[""] = GetDefaultUserPage
   return Dispatcher
end

function main(Data)
   local Dispatcher = SetupActions()
   server.serve{data=Data, dispatcher=Dispatcher}   
end

