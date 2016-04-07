local store2 = require 'store2'

-- Log analysis code that is shared between the excel adapter and the log watcher channel goes here.

local log = {}

local LogStore = store2.connect('logstore') 

function log.connection()
   return db.connect{api=db.SQLITE, name='loginfo'}
end

function log.pollTime()
   -- We start polling early.
   return LogStore:get("polltime") or '1990/01/01 00:00:00' 
end

function log.setNextPollTime(NextPollTime)
   if not iguana.isTest() then
      LogStore:put("polltime", NextPollTime)
   end
end

function log.MapTime(V)
   local Time = V:S()
   local TimeUTC = os.ts.time{
      year=Time:sub(1,4), 
      month=Time:sub(6,7), 
      day=Time:sub(9,10), 
      hour=Time:sub(12,13),
      minute=Time:sub(15,16),
      second=Time:sub(18,19)}
   return TimeUTC
end

-- See http://help.interfaceware.com/kb/988 for
-- documentation on the log API.
function log.queryLogs(T)
   local User = T.user
   local Password = T.password
   local PollTime = T.polltime
   local WebInfo = iguana.webInfo()
   local URL = 'http'
   if WebInfo.web_config.use_https then
      URL = URL.."s"
   end
   URL = URL..'://localhost:'
      ..iguana.webInfo().web_config.port..'/api_query'
   local X = net.http.get{url=URL,
      parameters={
         limit = 1000,
         username=User,
         password=Password,
         after    =  PollTime:gsub("-", "/"),  -- the query syntax for times is a little different
         reverse = 'false',  -- with newest entries at the top
      },live=true} 
   local Success, R = pcall(xml.parse, {data=X})
   if not Success then
      -- We got unparseable XML.  This shouldn't happen but...
      iguana.logWarning("We have some unparseable log XML")
      iguana.logWarning(X)
      error(R)
   end
   
   if R.export.success:S() == 'false' then
      error(R.export.error.description:S(), 2)
   end
   return R
end

local CreateTable=[[
CREATE TABLE LogInfo (
   MessageId TEXT(255) NOT NULL, 
   Channel TEXT(255),
   TimeStamp INT4,
   LogType TEXT(255),
   EventCode TEXT(255),
   EventName TEXT(255),
   PatientName TEXT(255),
   PRIMARY KEY (MessageId));
]]

function log.reset(T)
   local Connection = log.connection()
   if (#Connection:query{sql="SELECT * FROM sqlite_master WHERE Name = 'LogInfo'"} == 1) then
      Connection:execute{sql='DROP TABLE LogInfo', live=true}
   end
   Connection:execute{sql=CreateTable, live=true} 
   log.setNextPollTime('1990/01/01 00:00:00')
end

-- TODO help

local function InitDB()
   local Connection = log.connection()
   if (#Connection:query{sql="SELECT * FROM sqlite_master WHERE Name = 'LogInfo'"} == 0) then
      Connection:execute{sql=CreateTable}
   end
end

InitDB()

return log