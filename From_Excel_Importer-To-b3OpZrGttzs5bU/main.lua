-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
function main(Data)
   local O = json.parse{data=Data}
   
   -- This is the starting point to do something useful with the data.
   trace(O.Name)
   trace(O.Id)
   trace(O.Manager)
end