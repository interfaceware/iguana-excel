local sheet = require 'excel.sheet'

local function GetSpreadSheet(R, Auth)
   sheet.serve{user=Auth.username, sheet='IguanaFeed.xlsm', host=R.headers.Host}
end

return GetSpreadSheet