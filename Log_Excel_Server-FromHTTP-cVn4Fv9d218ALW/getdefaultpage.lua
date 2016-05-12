-- Default page

local Body=[[
<html>
<head>
<style>
body {
   display: table;
   height: 100%;
   width: 100%;
   background: rgba(0, 0, 0, 0) linear-gradient(135deg, #4caf50 35%, #8bc34a 100%) repeat scroll 0 0;
   font-family: "Open Sans",sans-serif;
   color: #414042;
   padding: 50px 0px;
}
   
a {
   color: #006DB6;
}
   
div.container {
   display: table-cell;
   vertical-align: middle;
}
   
div.contents {
   margin-left: auto;
   margin-right: auto;
   width: 70%;
   background: #FFFFFF;
   border-radius: 4px;
   box-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
   padding: 40px;
}
   
h1 {
   font-weight: 300;
   color: #357D57;
   margin: 0px 0px 10px 0px;
   padding-bottom: 20px;
   border-bottom: 1px solid #98C21F;
}
   
p {
   margin: 25px 0px;
   line-height: 1.5em;
   }
   
div.insetbox {
   box-shadow: inset 0px 1px 2px 0px rgba(0,0,0,0.5);
   background: #f5f5f5;
   border-radius: 3px;
   padding: 10px 20px;
   overflow: auto;
}

ol li {
   padding: 0.25em 0px;
}
   
</style>
<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700' rel='stylesheet' type='text/css'>
</head>
<body>

<div class="container">
<div class="contents">
   
<h1>Log Analysis Excel Feed</h1>
<p>You are logged in as <b>NAME</b> to a log analysis excel feed powered by Iguana.  Let's get started:</p>
<div class="insetbox">
<ol>
<li><a href='sheet.xlsm'>Download a spreadsheet</a></li>
<li>Open it in Excel 2011 or above.</li>
<li><b>Enable macros</b> when excel asks you.</li>
<li>When the spreadsheet has opened click on the button in the first "GetData" work sheet</li>
<li>Look for a password dialog in Excel.  Enter the password you used for the username <b>NAME</b> that you logged in with.</li>
<li>After the data is updated click on the button to update the Pivot tables</li>
<li>Then go and investigate the pivot reports.</li>
</ol>
</div>
<p>
The spreadsheet has Visual Basic for Applications (VBA) macro code which does the HTTP call to fetch
and parse data from a SQLite database we built off the log data..
</p>
<p>
To clear the database so it can be rebuilt and populated click <a href="reset">reset</a>.
</p>

</div><!-- End .container -->
</div><!-- End .contents -->
   
</body>
</html>
]]
local function GetDefaultPage(R, Auth)
   local Result = Body:gsub("NAME", Auth.username)
   net.http.respond{body=Result}
end

return GetDefaultPage