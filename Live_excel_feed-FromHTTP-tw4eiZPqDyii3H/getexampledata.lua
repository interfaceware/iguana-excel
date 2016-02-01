-- This example just serves up some random data.
function makeData(R, Auth)
   local Example = {}
   for i =1, 4500 do
      Example[i] = {}
      Example[i].Message = "Some data "..i
      Example[i].Amount = math.random(1000)
   end
   
   local Result = excel.transpose(Example)
   local Body = excel.flatwire(Result)
   
   return Body
end

function GetExampleData(R, Auth)
   net.http.respond{body=makeData()}      
end
