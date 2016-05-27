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
   
<h1>Export From Excel to Iguana</h1>
<p>You are logged in as <b>NAME</b> to a feed that exports data from Microsoft Excel and loads it into Iguana. 
This is a tool which allows you to edit datasets in Excel tables and then upload that data for processing by Iguana.</p>
<p><b>Note:</b>  This example is composed of two channels, <b>Export 1: Export From Excel</b> and <b>Export 2: Process Export Data</b>.</p>

<div class="insetbox">   
<p>Let's get started:</p>
<ol>
<li><a href='ExcelExport.xlsm'>Download a sample spreadsheet</a>.</li>
<li>Open it in Excel 2011 or above.</li>
<li><b>Enable macros</b> when Excel asks you to.</li>
<li>When the spreadsheet has opened click on <b>Push Data to Iguana</b> button in the "GetData" work sheet</li>
<li>Enter the password for your user <b>NAME</b> in the password dialog box.</li>
<li>This will have uploaded the data in the "Accounts" tab of the spread sheet to Iguana.</li>
<li>Our <i>first</i> sample Iguana channel <b>Export 1: Export From Excel</b> receives the data, breaks each row into a friendly JSON object and then shunts it downstream for transactional processing by another Translator channel.</li>
<li>The <i>second</i> channel <b>Export 2: Process Export Data</b> receives the data from the first and can perform whatever processing is needed.</li>
</ol>
</div>
<p>
Having the ability to prepare a dataset in Excel which can then be fed into Iguana and processed has many applications.  It could
allow admin staff to work with an Iguana expert to do bulk updates against a web API of an application.  It could be used to load
mappings from a specification spreadsheet into Iguana where it can be turned into Lua mappings and so on.
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