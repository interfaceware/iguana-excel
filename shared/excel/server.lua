local basicauth = require 'web.basicauth'

local server = {}

function server.serve(T)
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

-- TODO help information

return server