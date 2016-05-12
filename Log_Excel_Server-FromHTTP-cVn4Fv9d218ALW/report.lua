local excel = require 'excel.converter'

local function Report(R,A)
   local Table =  {}
   for i=1,10 do
      local Row = {}
      Table[#Table+1] = Row
      Row.item = "Item "..i
      Row.data = i
   end
   trace(Table)
   local Prepped = excel.transpose(Table)
   local Body = excel.flatwire(Prepped)
   net.http.respond{body=Body}
end

return Report