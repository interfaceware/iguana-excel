-- Basic boiler code for excel adapter server

-- See the Iguana Excel category documentation:
-- http://help.interfaceware.com/category/building-interfaces/repositories/builtin-iguana-excel

local basicauth = require 'web.basicauth'

local function serve(T)
   local Data = T.data
   local Dispatcher = T.dispatcher
   
   iguana.logInfo(Data)
   local R = net.http.parseRequest{data=Data}
   -- Check for authentication against the users defined in Iguana.
   if not basicauth.isAuthorized(R) then
      basicauth.requireAuthorization("Please enter your Iguana username and password")
      iguana.logInfo("Failed authentication.")
      return
   end
   
   trace(R.location)
   local Auth = basicauth.getCredentials(R)
   local Action = Dispatcher:dispatch{path=R.location, user=Auth.username}
   
   if (Action) then
      -- we will catch exceptions here
      if iguana.isTest() then 
         Action(R, Auth)    
      else
         local Success, ErrorMessage = pcall(Action, R,Auth)
         if not Success then
            iguana.logInfo("Error: "..ErrorMessage)
            net.http.respond{body=ErrorMessage, code=500} 
         end        
      end
   else
      net.http.respond{body="Request refused.", code=401}
   end
end

local Help = {
   Title="server.serve",
   Usage="server.serve{data=&lt;value&gt;, dispatcher=&lt;value&gt;}",
   ParameterTable=true,
   Parameters={
      {data={Desc="HTTP GET/POST dependent on the specified dispatcher action <u>string</u>."}},
      {dispatcher={Desc="Action table containing required setup action <u>table</u>."}},
   },

   Returns={},
   Examples={[[-- Import data from an Excel table (when dispatcher specifies import)
server.serve{data=Data, dispatcher=Dispatcher}]],
[[-- Export data to an Excel table (when dispatcher specifies export)
server.serve{data=Data, dispatcher=Dispatcher}]]},
   Desc="Serve data to/from a table in an Excel spreadsheet, depending on the action specified in the dispatcher.",
   SeeAlso={
      {
         Title="Export from Excel to Iguana",
         Link="http://help.interfaceware.com/v6/excel-export"
      },
      {
         Title="Source code for the excel.converter.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/excel/converter.lua"
      },
      {
         Title="Source code for the excel.server.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/excel/server.lua"
      },
      {
         Title="Source code for the excel.sheet.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/excel/sheet.lua"
      },
   },
}

help.set{input_function=serve, help_data=Help}

return serve