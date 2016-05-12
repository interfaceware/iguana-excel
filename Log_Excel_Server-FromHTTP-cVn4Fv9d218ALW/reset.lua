local log = require 'log.analyse'

local Body=[[
<html>
<body>
<p>
Reset the log info database.  It will take some time to rebuild the summary information.
</p>
<p>
Please <a href=".">Return to the main page</a>.
</p>
</body>
</html>
]]

local function Reset()
   log.reset()
   net.http.respond{body=Body}
end

return Reset