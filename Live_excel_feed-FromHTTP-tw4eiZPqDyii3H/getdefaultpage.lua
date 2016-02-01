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
<h1>Iguana Excel Server</h1>
<p>You are logged in as <b>NAME</b> to an example of an Iguana excel spreadsheet feeding channel.  Let's get started:</p>
<ol>
<li><a href='sheet.xlsm'>Download a spreadsheet</a></li>
<li>Open it in Excel 2011 or above.</li>
<li><b>Enable macros</b> when excel asks you.</li>
<li>When the spreadsheet has opened click on the button in the first "GetData" work sheet</li>
<li>Look for a password dialog in Excel.  Enter the password you used for this <b>NAME</b> Iguana user.</li>
</ol>
<p>
The spreadsheet has Visual Basic for Applications (VBA) macro code which does the HTTP call to fetch
and parse data from Iguana. You are welcome to inspect the VBA code and the code of this channel to
understand how it works.
</p>
<p>
This project should be a useful starting point for being able to build live dashboards of your corporate
data since you can leverage all the reporting capabilities of Excel with Pivot tables
and charting.
</p>
<p>
Of course we don't have real data - so we serve up some dummy data and log queries with
this example.  But feel free to take this as a starting point.
</p>
<p>
There is this <a href="http://help.interfaceware.com/forums/topic/serving-live-data-into-excel">forum about</a>
this channel which is a good place to look for more information.
</p>
</body>
</html>
]]

function GetDefaultPage(R, Auth)
   local Result = Body:gsub("NAME", Auth.username)
   net.http.respond{body=Result}
end