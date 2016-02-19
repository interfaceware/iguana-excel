-- Default page

local Body=[[
<html>
<head>
<style>
body {
    font-family: Arial;
    padding: .5em;
    background-color: #E7F9E7;
}
</style>
<head>
<body>
<h1>Log Analysis Excel Feed</h1>
<p>You are logged in as <b>NAME</b> to a log analysis excel feed powered by Iguana.  Let's get started:</p>
<ol>
<li><a href='sheet.xlsm'>Download a spreadsheet</a></li>
<li>Open it in Excel 2011 or above.</li>
<li><b>Enable macros</b> when excel asks you.</li>
<li>When the spreadsheet has opened click on the button in the first "GetData" work sheet</li>
<li>Look for a password dialog in Excel.  Enter the password you used for the username <b>NAME</b> that you logged in with.</li>
<li>After the data is updated click on the button to update the Pivot tables</li>
<li>Then go and investigate the pivot reports.</li>
</ol>
<p>
The spreadsheet has Visual Basic for Applications (VBA) macro code which does the HTTP call to fetch
and parse data from a SQLite database we built off the log data..
</p>
<p>
To clear the database so it can be rebuilt and populated click <a href="reset">reset</a>.
</p>
</body>
</html>
]]

function GetDefaultPage(R, Auth)
   local Result = Body:gsub("NAME", Auth.username)
   net.http.respond{body=Result}
end

function GetUserDefaultPage(R, Auth)
   net.http.respond{body="You need to have an administrator privilleges to use this web service."}   
end