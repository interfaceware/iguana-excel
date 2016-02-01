-- This channel shows how one can implement basic authentication with an Iguana channel.
-- We use the Iguana user database as our source of users.

basicauth = require 'web.basicauth'

function main(Data)
   iguana.logInfo(Data)
   iguana.stopOnError(false)
   local R = net.http.parseRequest{data=Data}
   -- Check for authentication against the users defined in Iguana.
   if not basicauth.isAuthorized(R) then
      basicauth.requireAuthorization()
      iguana.logInfo("Failed authentication.")
      return
   end
   -- Extract the user name and password
   local Auth = basicauth.getCredentials(R)
   trace(Auth.username)
   trace(Auth.password)
   net.http.respond{body="Welcome "..Auth.username.." you have been authenticated."}   
end
