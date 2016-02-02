-- Code used to handle serving up the excel spreadsheet on the fly.
local function LoadFile(Path)
   local F = io.open(Path, "rb")
   local Content = F:read("*a")
   F:close()
   return Content
end

-- This finds the URLs in the spreadsheet and converts them
-- relative to the URL that the client came in by.
local function AlterHost(X, Host)
   local Url = X.t[1]:S()
   Url = Url:gsub("http://[^:]*:[0-9]*/", 'http://'..Host..'/')
   X.t[1] = Url
end

-- Excel spreadsheets in xlsm format are actually zip archive files which amongst other
-- things contain a lot of XML documents.  We leverage Iguana's ability to unzip
-- a zip archive on the fly into a Lua table.  That allows us to modify the spreadsheet
-- on the fly, put our changes back and zip the file up again to serve to the user.
function FetchSpreadSheet(R, Auth)
   local Path = iguana.project.root()..iguana.project.guid()..'/IguanaFeed.xlsm'
   trace(Path)
   local XContent = LoadFile(Path)
   
   local SpreadSheet = filter.zip.inflate(XContent)
   
   local X = xml.parse{data=SpreadSheet.xl["sharedStrings.xml"]}
   for i=1, X.sst:childCount("si") do 
      local SharedString = X.sst:child("si", i)
      -- Change URLs to address of this Iguana
      if SharedString.t[1]:S():find("http://") ~= nil then
         AlterHost(SharedString, R.headers.Host)
      end
      -- We change the spread sheet user name on the fly 
      if SharedString.t[1]:S() == 'admin' then
         SharedString.t[1] = Auth.username
      end
   end
   SpreadSheet.xl["sharedStrings.xml"] = X:S()
   local SData = filter.zip.deflate(SpreadSheet)
   net.http.respond{body=SData, entity_type='application/xls'}
end