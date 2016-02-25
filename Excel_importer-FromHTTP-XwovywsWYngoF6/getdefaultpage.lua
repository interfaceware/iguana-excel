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
<h1>Excel Uploading Tool</h1>
<p>You are logged in as <b>NAME</b> to a Microsoft Excel loading feed powered by Iguana.</p>
<p>This is a tool which allows you to edit datasets in Excel tables and upload that data for processing by Iguana.</p>
<p>Let's get started:</p>
<ol>
<li><a href='sheet.xlsm'>Download a spreadsheet</a></li>
<li>Open it in Excel 2011 or above.</li>
<li><b>Enable macros</b> when excel asks you.</li>
<li>When the spreadsheet has opened click on Push Data button in the first "GetData" work sheet</li>
<li>Look for a password dialog in Excel.  Enter the password you used for the username <b>NAME</b> that you logged in with.</li>
<li>This will have uploaded the data in the "Accounts" tab of the excel spread sheet.</li>
<li>The channel will receive the data, break each row into a friendly JSON object and shunt it downstream for transactional processing by another translator channel in Iguana.</li>
</ol>
<p>
Why do this?
</p>
<p>
Often organizations are faced with the need to do bulk updates to data that exists in applications or multiple applications.
</p>
<p>
Many applications don't make this easy but if the application has say a web API that Iguana can use to talk to then it's become
easy to use Iguana to do these kinds of updates.  Iguana is a wonderfully convenient environment to script out interactions with
web services.
</p>
<p>
Excel on the other hand is a very accessible tool in which to edit and manipulate tabular data. So it becames
easy to help non technical staff achieve these mass updates by serving the data up in excel and then feeding
back the edits into Iguana.  
</p>
<p>
Best of both worlds!  Get more done and create more value.  Enjoy!
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