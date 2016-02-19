-- This channel will index up to a 1000 messages at time from the logs of an Iguana instance
-- It puts the data into a SQLite database which can then be used to report into Excel.
local log = require 'log.analyse'

local Username = 'admin'
local Password = 'password'

function main()
   iguana.stopOnError(false)
   local PollTime = log.pollTime()
   local X = log.queryLogs{user=Username, password=Password, polltime=PollTime}
   
   local T = db.tables{vmd='LogInfo.vmd', name='LogMessage'}
   for i=1, X.export:childCount("message") do
      local Entry = X.export:child("message", i)
      -- Don't index logs for this channel.  It becomes a perpetual motion machine... :-)
      if Entry.source_name:S() ~= iguana.channelName() then
         local Row = T.LogInfo[#T.LogInfo+1]
         MapLogInfo(Row, Entry)
      end
   end
   trace(T)
   local Connection = log.connection()
   Connection:merge{data=T} 
   local NextPollTime = X.export:child("message", X.export:childCount("message")).time_stamp:S()
   log.setNextPollTime(NextPollTime)
   local Status = "Indexed "..#T.LogInfo.." log messages. Next poll time "..NextPollTime
   trace(Status)
   iguana.setChannelStatus{text=Status, color='green'}
end

function MapLogInfo(T, E)
   T.MessageId = E.message_id
   T.LogType = E.type
   T.Channel = E.source_name
   T.TimeStamp = log.MapTime(E.time_stamp)
   if E.type:S() == 'Message' then
      MapHl7Info(T, E.data:nodeValue())
   end
   return T
end

function MapHl7Info(T, Data)
   local Success, M = pcall(hl7.parse,{vmd='analyze.vmd', data=Data})
   if not Success then
      -- It probably was not an HL7 message
      return 
   end
   T.EventCode = M.MSH[9][1]
   T.EventName = M.MSH[9][2]
   T.PatientName = M.PID[1][5][1][2]..' '..M.PID[1][5][1][1][1]
   return T
end
