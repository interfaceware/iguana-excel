local function GetDefaultUserPage(R, Auth)
   net.http.respond{body="You need to have an administrator privilleges to use this web service."}   
end

return GetDefaultUserPage
