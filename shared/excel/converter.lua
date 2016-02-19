local excel = {}

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

local function EscapeValue(V)
   return V:gsub("@", "@A"):gsub(",", "@C"):gsub("\n", "@N")
end


-- Translate into a string for shipping off to Excel - with Escaping
-- See http://www.lua.org/pil/11.6.html
-- For concatenating many strings it's more efficient
-- to insert many little strings into a table and concatenate with table.concat
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

function excel.lookupColumn(T, Name)
   for i = 1, #T[1] do
      if T[1][i] == Name then
         return i
      end
   end
   return -1
end

return excel