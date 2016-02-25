local excel = require 'excel.converter'

function Upload(R,A)
   local T = excel.parse(R.body)
   for i = 2, #T do
      queue.push{data=json.serialize{data=excel.package(T, i)}}
   end
   net.http.respond{body="Thanks for your data"}
end