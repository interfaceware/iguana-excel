
local function MakeHl7FieldsBlank(Row)
   Row.Code = "None"
   Row.Event = "None" 
   Row.Patient = "None"
end

local function ParseHL7(Row, Data)
   -- The analyze vmd has simple flat structure to make it easy to pull
   -- out the PID segment if present and MSH segments
   local Success, Msg = pcall(hl7.parse, {vmd='analyze.vmd', data=Data})
   if Success then
      Row.Code = Msg.MSH[9][1]
      Row.Event = Msg.MSH[9][2]
      if #Msg.PID > 0 then
         Row.Patient = Msg.PID[1][5][1][2].." "..Msg.PID[1][5][1][1][1]
      end
   else
      MakeHl7FieldsBlank(Row)
   end
end

function GetLogData(R, Auth)
   -- For infomation on the HTTP log api
   -- http://help.interfaceware.com/kb/988 
   local X = net.http.get{url='http://localhost:'
      ..iguana.webInfo().web_config.port..'/api_query',
      parameters={
         limit = R.params.limit or 1000,
         username=Auth.username,
         password=Auth.password,
         source  = R.params.channel,  
         reverse = 'true',  -- with newest entries at the top
      },live=true}  
    
   local Result = {}
   X = xml.parse{data=X}
   for i=1, X.export:childCount("message") do
      local Entry = X.export:child("message", i)
      Result[i] = {}
      local Row = Result[i]
      
      Row.Time = Entry.time_stamp:S():sub(1,19)
      Row.Milliseconds = Entry.time_stamp:S():sub(21,23)
      Row.LogType = Entry.type
      Row.Body = Entry.data
      Row.Channel = Entry.source_name 
      if Entry.type:S() == 'Message' then
         ParseHL7(Row, Entry.data:nodeValue())
      else
         MakeHl7FieldsBlank(Row)
      end
   end
   
   net.http.respond{body=excel.flatwire(excel.transpose(Result))}
end
