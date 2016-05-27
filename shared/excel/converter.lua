-- Miscellaneous helper functions for Excel adapter

-- See the Iguana Excel category documentation:
-- http://help.interfaceware.com/category/building-interfaces/repositories/builtin-iguana-excel

local excel = {}

-- This function takes in a table containing an array of rows which
-- mimic the structure of a database table by using data that
-- has regular name=value pairs and then outputs a table that mimics 
-- the structure of a CSV file by having one header row containing 
-- the field names and the the values without their names in the 
-- subsequent rows - this is very close to the format we want to send 
-- over the wire to Microsoft Excel
function excel.transpose(T)
   -- Get the columns
   local Result = {}
   Result[1] = {}
   local HeaderRow = Result[1]
   local Row = T[1]
   for K,V in pairs(Row) do
      HeaderRow[#HeaderRow+1] = K
   end
   for i=1, #T do
      Result[i+1] = {}
      for j=1, #HeaderRow do
         Result[i+1][j] = (T[i][HeaderRow[j]])
      end
   end
   return Result
end

local Help = {
   Title="excel.transpose",
   Usage="excel.transpose{db_table=&lt;value&gt;}",
   ParameterTable=true,
   Parameters={
      {db_table={Desc=[["DB style" table of name=value pairs <u>table</u>.]]}},
   },
   Returns={{Desc=[["CSV style" table with field names in header row <u>table</u>.]]}},
   Examples={[[-- Import data from an Excel table (when dispatcher specifies import)
server.serve{data=Data, dispatcher=Dispatcher}]],
[[-- First step: Convert to "CSV table" structure
local Prepped = excel.transpose(Table)<br><br>
-- Second step: Convert to a CSV text format
local Body = excel.flatwire(Prepped)
]]},
   Desc=[[Convert a "DB style" table of name=value pairs into a "CSV style" table with field names in header row.
This is used as a intermediate step for converting data from a table format to "CSV format" before sending it to 
an Excel spreadsheet.]],
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

help.set{input_function=excel.transpose, help_data=Help}


-- This escapes values so that we get these transformations
-- @ --> @A
-- , --> @C
-- \n --> @N
-- This means content in the data will not be mistaken for the delimiters
-- we use in our comma delimited format - i.e. \n and , characters - @ is 
-- the escape character so we have to escape that also.
local function EscapeValue(V)
   return V:gsub("@", "@A"):gsub(",", "@C"):gsub("\n", "@N")
end


-- Translate into a string for shipping off to Excel - with Escaping
-- See http://www.lua.org/pil/11.6.html
-- For concatenating many strings it's more efficient
-- to insert many little strings into a table and concatenate with table.concat
-- As it's input this is taking in the table from excel.transpose that mimics 
-- the structure of a CSV file - i.e. first row gives the column names, 
-- subsequent rows contain the values delimited by commas
function excel.flatwire(T)
   os.ts.time()
   local RT = {}
   for r=1, #T do
      local Row = {}
      for c=1, #T[1] do 
         if (type(T[r][c]) == 'string') then
            Row[#Row+1] = EscapeValue(T[r][c])
         elseif (type(T[r][c]) == 'userdata') then
            Row[#Row+1] = EscapeValue(T[r][c]:nodeValue())
         else
            Row[#Row+1] = T[r][c]
         end
      end
      trace(Row)
      RT[#RT+1] = table.concat(Row, ",")
   end
   RT[#RT+1] = ''
   R = table.concat(RT, "\n")
   os.ts.time()
   return R
end

local Help = {
   Title="excel.flatwire",
   Usage="excel.flatwire{csv_table=&lt;value&gt;}",
   ParameterTable=true,
   Parameters={
      {csv_table={Desc=[["CSV style" table with field names in header row <u>table</u>.]]}},
   },
   Returns={{Desc=[[CSV formatted string with field names in header row <u>string</u>.]]}},
   Examples={[[-- Import data from an Excel table (when dispatcher specifies import)
server.serve{data=Data, dispatcher=Dispatcher}]],
[[-- Export data to an Excel table (when dispatcher specifies export)
server.serve{data=Data, dispatcher=Dispatcher}]]},
   Desc=[[Convert a "CSV style" table with field names in header row into a CSV formatted string 
with field names in header row. This is used as a intermediate step for converting data from a 
table format to "CSV format" before sending it to an Excel spreadsheet.]],
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

help.set{input_function=excel.flatwire, help_data=Help}


-- This function takes the comma delimited format (CSV) - which has most likely
-- come from excel and parses it into a Lua Table. The first row in the table
-- will have the column names and the subsequent rows will have the data. The
-- routine takes care of unescaping the embedded escaped characters like , \n and
-- the @ escape character.
function excel.parse(Data)
   local Rows = Data:split("\n")
   for i=1, #Rows do
      Rows[i] = Rows[i]:split(",")
      for j=1, #Rows[i] do
         Rows[i][j] = Rows[i][j]:gsub("@N", "\n"):gsub("@C", ","):gsub("@A", "@") 
      end
   end
   Rows[#Rows] = nil
   return Rows
end

local Help = {
   Title="excel.parse",
   Usage="excel.parse{Data=&lt;value&gt;}",
   ParameterTable=true,
   Parameters={
      {Data={Desc="CSV formatted string with field names in the header row <u>string</u>."}},
   },
   Returns={{Desc=[["CSV style" table with field names in header row <u>table</u>.]]}},  
   Examples={[[-- Parse a string in CSV format into a "CSV style" table
local T = excel.parse(CSV_string)]]},
   Desc=[[Convert a string in CSV format into a "CSV style" table with field names 
in the header row. This is used as a intermediate step for converting CSV data from 
Excel into table format that is suitable for use in Iguana.]],
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

help.set{input_function=excel.parse, help_data=Help}


-- This takes a table that mimics the structure of a CSV file with the first row
-- containing the column names, and the subsequebnt rows containing data. 
-- One row specified by RowIndex is selected and a new table is produced with 
-- name=value pairs where the names are the column names
-- and the values are the values in the row given by RowIndex. We use this to
-- take the data from excel in the importer and produce one JSON object per row
-- of data and queue each object.
function excel.package(T, RowIndex)
   local R = {}
   local Headers = T[1]
   local Row = T[RowIndex]
   for i=1, #Headers do
      R[Headers[i]] = Row[i]
   end
   return R
end

local Help = {
   Title="excel.package",
   Usage="excel.package(db_table, RowIndex)",
   ParameterTable=false,
   Parameters={
      {db_table={Desc=[["DB style" table of name=value pairs <u>table</u>.]]}},
      {RowIndex={Desc="An integer specifying the row to read from the table <u>integer</u>."}},
   },

   Returns={{Desc=[[A table of name=value pairs from the specifed row from the table <u>table</u>.]]}},  
   Examples={[[-- retrieve the data for a specified row in a table
local row_data=excel.package(T, RowId)]],
[[-- use a for loop to retrieve the individual data for each row in a table
local Table = excel.parse(Body)
for i = 2, #Table do
   queue.push{data=json.serialize{data=excel.package(Table, i)}}
end]],
   },
   Desc=[[Retrieve the data for a specified row in a "DB Style" table of name=value pairs.]],
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

help.set{input_function=excel.package, help_data=Help}


-- This takes a node tree result set as typically produced by db:query{} and
-- converts it into a table where the first row has the names of the columns
-- and the subsequent rows just contain the data for each row in the result set.
-- After this the resulting table can then be given to excel.flatwire to make 
-- a comma delimited rendering of the data which can be send to Excel.
function excel.convertResultSet(T)
   local Result = {}
   Result[1] = {}
   local HeaderRow = Result[1]
   -- get the header fields
   for i = 1, #T[1] do
      HeaderRow[i] = T[1][i]:nodeName()
   end
   local ColumnCount = #T[1]
   trace(ColumnCount)
   for j = 1, #T do
      local Row = {}
      Result[j+1] = Row
      for i=1, ColumnCount do
         Row[i] = T[j][i]:S()
      end
   end
   
   return Result
end

local Help = {
   Title="excel.convertResultSet",
   Usage="server.convertResultSet(data)",
   ParameterTable=false,
   Parameters={
      {data={Desc="Database node tree query result set <u>result_set node tree</u>."}},
   },
   Returns={{Desc=[["CSV style" table with field names in header row <u>table</u>.]]}},
   Examples={[[-- Convert a DB node tree "Results" into a table
local T = excel.convertResultSet(Results)]],
[[-- Same conversion - but showing a sample DB query as well
local Results = C:query{sql='SELECT * FROM LogInfo WHERE Channel = \'all\' LIMIT 5000', live=true}
trace(#Results) -- count no of rows returned
local T = excel.convertResultSet(Results)]]},
   Desc=[[Convert a Database Node Tree query result set into a "CSV style" table with field
names in the header row. This is used as a intermediate step for converting database query
results into CSV data suitable for sending to Excel. Next step is to use excel.flatwire{} 
to convert the table to CSV format.]],
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

help.set{input_function=excel.convertResultSet, help_data=Help}


-- This is a helpful utility function to look up the index of a given
-- column name. It assumes that the table given is in a format that
-- the first row contains the column names and subsequent rows contain
-- the data.
function excel.lookupColumn(T, Name)
   for i = 1, #T[1] do
      if T[1][i] == Name then
         return i
      end
   end
   return -1
end

local Help = {
   Title="server.lookupColumn",
   Usage="server.lookupColumn(Table, Name)",
   ParameterTable=false,
   Parameters={
      {Table={Desc=[["CSV style" table with field names in header row <u>table</u>.]]}},
      {Name={Desc="Name of the column to find <u>string</u>."}},
   },

   Returns={{Desc=[["Index number for the field, or -1 if the field is not found <u>integer</u>.]]}},
   Examples={[[-- Lookup field index for "Timestamp" in table "T"
local TimeStampI = excel.lookupColumn(T, 'TimeStamp')
]],
[[-- Same lookup - but showing a sample DB query and conversion as well
local Results = C:query{sql='SELECT * FROM LogInfo WHERE Channel = \'all\' LIMIT 5000', live=true}
trace(#Results) -- count no of rows returned
local T = excel.convertResultSet(Results)
local TimeStampI = excel.lookupColumn(T, 'TimeStamp')]]},
   Desc=[[Look up the index of a given column name. It assumes that the table given is a 
"CSV style" table with field names in the header row.]],
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

help.set{input_function=excel.lookupColumn, help_data=Help}


return excel