-- A two channel example showing how to export data from Excel and import 
-- it into Iguana using a web service

-- This channel uses a From Channel source to receive data from another channel
-- for further processing, in this case "Export 1: Export From Excel"

-- http://help.interfaceware.com/v6/excel-export

function main(Data)
   local O = json.parse{data=Data}
   
   -- This is the starting point to do something useful with the data.
   trace(O.Name)
   trace(O.Id)
   trace(O.Manager)   
   
   -- Add required processing here for example:
      -- map messages
      -- send (bulk) updates to a web API
      -- etc.
end