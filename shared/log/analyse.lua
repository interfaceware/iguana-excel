-- Miscellaneous log helper functions used by the Excel adapter

-- See the Iguana Excel category documentation:
-- http://help.interfaceware.com/category/building-interfaces/repositories/builtin-iguana-excel

local store2 = require 'store2'

-- Log analysis code that is shared between the excel adapter and the log watcher channel goes here.

local log = {}

local LogStore = store2.connect('logstore') 

function log.connection()
   return db.connect{api=db.SQLITE, name='loginfo'}
end

local Help = {
   Title="log.connection",
   Usage="log.connection()",
   ParameterTable=false,
   Parameters={},
   Returns={
      {Desc="Connection to the log database <u>db_connection object</u>."}
   },
   Examples={[[-- Connect to the log database
   local C = log.connection()]]},
   Desc=[[Connects to the logs SQLite database "loginfo".]],
   SeeAlso={
      {
         Title="Import Logs into Excel from Iguana",
         Link="http://help.interfaceware.com/v6/excel-import"
      },
      {
         Title="Source code for the log.analyse.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/log/analyse.lua"
      },
   },
}

help.set{input_function=log.connection, help_data=Help}


function log.pollTime()
   -- We start polling early.
   return LogStore:get("polltime") or '1990/01/01 00:00:00' 
end

local Help = {
   Title="log.pollTime",
   Usage="log.pollTime()",
   ParameterTable=false,
   Parameters={},
   Returns={
      {Desc="The polltime <u>date</u>."}
   },
   Examples={[[-- Get the polltime
local pTime = log.pollTime()]]},
   Desc=[[Gets the polltime. Reads the "polltime" entry from the store, and returns a default
('1990/01/01 00:00:00') if there is no "polltime" entry.]],
   SeeAlso={
      {
         Title="Import Logs into Excel from Iguana",
         Link="http://help.interfaceware.com/v6/excel-import"
      },
      {
         Title="Source code for the log.analyse.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/log/analyse.lua"
      },
   },
}

help.set{input_function=log.pollTime, help_data=Help}


function log.setNextPollTime(NextPollTime)
--   if not iguana.isTest() then
      LogStore:put("polltime", NextPollTime)
--   end
end

local Help = {
   Title="log.setNextPollTime",
   Usage="log.setNextPollTime()",
   ParameterTable=true,
   Parameters={
      {name={Desc="Name of the column to add <u>string</u>."}},
   },
   Returns={},
   Examples={[[-- set the next polltime
log.setNextPollTime('2016/01/01 00:00:00')]]},
   Desc=[[Sets the polltime. Saves the specified "polltime" entry to the store.]],
   SeeAlso={
      {
         Title="Import Logs into Excel from Iguana",
         Link="http://help.interfaceware.com/v6/excel-import"
      },
      {
         Title="Source code for the log.analyse.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/log/analyse.lua"
      },
   },
}

help.set{input_function=log.setNextPollTime, help_data=Help}

function log.MapTime(V)
   local Time = tostring(V)
--   local Time = V:S()
   local TimeUTC = os.ts.time{
      year=Time:sub(1,4), 
      month=Time:sub(6,7), 
      day=Time:sub(9,10), 
      hour=Time:sub(12,13),
      minute=Time:sub(15,16),
      second=Time:sub(18,19)}
   return TimeUTC
end



local Help = {
   Title="log.MapTime",
   Usage="log.MapTime()",
   ParameterTable=false,
   Parameters={
      {time={Desc="Time userdata object or equivalent string <u>userdata or string</u>."}},
   },
   Returns={
      {Desc="Unix Epoch Time formatted time <u>string</u>."}
   },
   Examples={[[-- create an empty schema
local Schema = NewSchema()]]},
   Desc=[[Converts a userdata time as returned by os.time() (or a string time in format: 
"yyyy%mm%dd%HH%MM%SS" where % = any character) to a Unix Epoch Time format.]],
   SeeAlso={
      {
         Title="Import Logs into Excel from Iguana",
         Link="http://help.interfaceware.com/v6/excel-import"
      },
      {
         Title="Source code for the log.analyse.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/log/analyse.lua"
      },
   },
}


help.set{input_function=log.MapTime, help_data=Help}

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
         after   =  PollTime:gsub("-", "/"),  -- the query syntax for times is a little different
         reverse = 'false',  -- with newest entries at the top
      },live=true} 
   local Success, R = pcall(xml.parse, {data=X})
   if not Success then
      -- We got unparseable XML. This shouldn't happen but...
      iguana.logWarning("We have some unparseable log XML")
      iguana.logWarning(X)
      error(R)
   end
   
   if R.export.success:S() == 'false' then
      error(R.export.error.description:S(), 2)
   end
   return R
end

local Help = {
   Title="log.queryLogs",
   Usage="log.queryLogs{user=",
   ParameterTable=true,
   Parameters={
      {user={Desc="Iguana User <u>string</u>."}},
      {password={Desc="Password for the User <u>string</u>."}},
      {polltime={Desc="String formatted as Time <u>string</u>."}},
   },
   Returns={
      {Desc=[[List of Log Messages after the specified "polltime" time <u>XML node tree</u>.]]}
   },
   Examples={[[-- query the logs (using two equivalent time formats)
log.queryLogs{user='<myuser>',password='<secret>',polltime='2016/05/27 16:20:00'}
log.queryLogs{user='<myuser>',password='<secret>',polltime='2016-05-27 16:20:00'}
]]},
   Desc=[[Get all the Log Messages after the date specified by the "polltime" parameter.
The "polltime" must be a string formatted as time like "yyyy/mm/dd HH:MM:SS" or 
"yyyy-mm-dd HH:MM:SS"(e.g., '2016/05/27 16:20:00' or '2016-05-27 16:20:00']],
   SeeAlso={
      {
         Title="Import Logs into Excel from Iguana",
         Link="http://help.interfaceware.com/v6/excel-import"
      },
      {
         Title="Source code for the log.analyse.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/log/analyse.lua"
      },
   },
}

help.set{input_function=log.queryLogs, help_data=Help}

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

local Help = {
   Title="log.reset",
   Usage="log.reset(db_connection)",
   ParameterTable=false,
   Parameters={
      {db_connection={Desc="Database connection object <u>db_connection object</u>."}},
   },
   Returns={},
   Examples={[[-- resest the log database using the "Conn" connection
log.reset(Conn)]]},
   Desc=[[Reset the log database, by emptying the "loginfo" table used to store the log records.
Note: This is done by deleting and recreati]],
   SeeAlso={
      {
         Title="Import Logs into Excel from Iguana",
         Link="http://help.interfaceware.com/v6/excel-import"
      },
      {
         Title="Source code for the log.analyse.lua module on github",
         Link="https://github.com/interfaceware/iguana-excel/blob/master/shared/log/analyse.lua"
      },
   },
}

help.set{input_function=log.reset, help_data=Help}


local function InitDB()
   local Connection = log.connection()
   if (#Connection:query{sql="SELECT * FROM sqlite_master WHERE Name = 'LogInfo'"} == 0) then
      Connection:execute{sql=CreateTable}
   end
end

InitDB()

return log