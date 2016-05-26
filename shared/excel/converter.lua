-- http://help.interfaceware.com/v6/excel-adapter
-- Helpers for excel adapter

local excel = {}

-- This function takes in a table containing an array of rows which
-- have regular name=value pairs and then outputs a table with one 
-- header row and the values without their names in the subsequent rows
-- This is very close to the format we want to send over the wire to
-- Microsoft Excel
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
-- As it's input this is taking in the table from excel.transpose - i.e. first row
-- gives the column names, subsequent rows contain the values delimited by commas
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

-- This function takes the comma delimited format - which has most likely
-- come from excel and parses it into a Lua Table.  The first row in the table
-- will have the column names and the subsequent rows will have the data.  The
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

-- This takes a table with the first row containing the column names, and
-- the rows containing data.  One row given by RowIndex is selected and new
-- table is produced with name=value pairs where the names are the column names
-- and the values are the values in the row given by RowIndex.  We use this to
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

-- This takes a node tree result set as typically produced by db:query{} and
-- converts it into a table where the first row has the names of the columns
-- and the subsequent rows just contain the data for each row in the result set.
-- After this the resulting table can then be given to excel.flatwire to make 
-- a comma delimited rendering of the data which can be send to excel.
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

-- This is a helpful utility function to look up the index of a given
-- column name.  It assumes that the table given is in a format that
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

return excel
