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

function excel.flatwire(T)
   local R = ''
   -- Translate into a string - with Escaping
   for r=1, #T do
      for c=1, #T[1] do
         if (type(T[r][c]) == 'string') then
            R = R..T[r][c]:gsub("@", "@A"):gsub(",", "@C"):gsub("\n", "@N")..','
         elseif (type(T[r][c]) == 'userdata') then
            R = R..T[r][c]:nodeValue():gsub("@", "@A"):gsub(",", "@C"):gsub("\n", "@N")..","               
         else
            R = R..T[r][c]..','
         end
      end
      R = R:sub(1, #R-1).."\n"
   end
   return R
end

return excel