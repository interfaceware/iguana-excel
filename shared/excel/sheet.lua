local sheet = {}

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
   local Url = X.t:nodeText()
   local WebInfo = iguana.webInfo()
   local BaseUrl
   if WebInfo.https_channel_server.use_https then
      BaseUrl = "https://"
   else
      BaseUrl = "http://"
   end
   BaseUrl = BaseUrl..Host..'/'
   trace(BaseUrl)
   Url = Url:gsub("https?://[^:]*:[0-9]*/", BaseUrl)
   X.t[1] = Url
end

--Updating VBA code across excel spreadsheets is a burden
--A technique I use here is to keep the core engine code in excel/core
--and pull the VBA code which is a binary lump from it.
local function LatestVbaCode()
   local Path = iguana.project.root()..'other/excel/core.xlsm'
   local XContent = LoadFile(Path)
   local SpreadSheet = filter.zip.inflate(XContent)
   trace(SpreadSheet)
   return SpreadSheet.xl["vbaProject.bin"]
end

-- Excel spreadsheets in xlsm format are actually zip archive files which amongst other
-- things contain a lot of XML documents.  We leverage Iguana's ability to unzip
-- a zip archive on the fly into a Lua table.  That allows us to modify the spreadsheet
-- on the fly, put our changes back and zip the file up again to serve to the user.
function sheet.serve(T)
   local User = T.user
   local Sheet = T.sheet
   local Host = T.host
   
   local Path = iguana.project.root()..iguana.project.guid()..'/'..Sheet
   trace(Path)
   local XContent = LoadFile(Path)
   
   local SpreadSheet = filter.zip.inflate(XContent)
   
   local X = xml.parse{data=SpreadSheet.xl["sharedStrings.xml"]}
   for i=1, X.sst:childCount("si") do 
      local SharedString = X.sst:child("si", i)
      -- Change URLs to address of this Iguana
      if SharedString.t and (SharedString.t:nodeText():find("^http://") or SharedString.t:nodeText():find("^https://") ~= nil) then
         AlterHost(SharedString, Host)
      end
      -- We change the spread sheet user name on the fly 
      if SharedString:nodeText() == 'admin' then
         SharedString.t[1] = User
      end
   end
   SpreadSheet.xl["sharedStrings.xml"] = X:S()
   -- Give the spreadsheet the latest VBA brains from the core excel file
   SpreadSheet.xl["vbaProject.bin"] = LatestVbaCode()
   local SData = filter.zip.deflate(SpreadSheet)
   net.http.respond{body=SData, entity_type='application/xls'}
end

-- TODO help for sheet.serve(T)

return sheet