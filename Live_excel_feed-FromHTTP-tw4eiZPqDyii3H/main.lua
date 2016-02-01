excel = require 'excel.converter'

-- This channel is an example of how Iguana can be used as a tool to provide live feeds into Microsoft excel spreadsheets.
-- Microsoft Excel is a bit lacking in support for modern web standards like JSON so we try to reduce the effort on the spreadsheet
-- side by serving up a type of comma delimited text data with commas , between the columns.  Nothing is quoted.  We escape
-- commas with the sequeuence @C and new lines as @N and the @ character is escaped as @A

-- The channel has the spreadsheet as a binary attachment.  This channel serves it up on the fly.  Read the getspreadsheet module
-- for more information

-- When you run the channel and open up the link in your browser it will be necessary to enter a valid Iguana username and password
-- for this Iguana instance.

require 'getlogdata'
require 'getspreadsheet'
require 'getexampledata'
require 'getdefaultpage'
basicauth = require 'web.basicauth'

-- We get the name of the request we are serving up
function ExtractRequest(R)
   local X = xml.parse{data=iguana.channelConfig{name=iguana.channelName()}}
   local BaseLocation = X.channel.from_http.mapper_url_path:S()
   return R.location:sub(#BaseLocation+2)
end

-- We have a look up table of web handlers.  
-- path --> function
-- The function receives the HTTP request and Authentication information
local RequestLookup={}
-- i.e. /smalldata/sheet.xlsm is handled by the FetchSpreadSheet call
RequestLookup["sheet.xlsm"] = FetchSpreadSheet
RequestLookup["example"]  = GetExampleData
RequestLookup["logdata"] = GetLogData
RequestLookup[""] = GetDefaultPage

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
   
   trace(R.location)
   local Request = ExtractRequest(R)
   -- See if we have a function handling the request
   if RequestLookup[Request] then
      -- If we do then serve it up.
      RequestLookup[Request](R, basicauth.getCredentials(R))
      return
   else
      net.http.respond{body="Unknown request", code=401}
   end   
end
