require "lsqlite3"
 
local db = sqlite3.open("/etc/lasdb.db")

local file = "blacklist.sql"

if arg[2] ~= nil then
	file = arg[2]
end

local sql_export = io.open(file, "w")


sql_export:write("-- Blacklist v.1.10", "\n")
sql_export:write("BEGIN TRANSACTION;","\n")
sql_export:write("DELETE FROM `Contacts`;","\n")
sql_export:write("DELETE FROM `ContactNumbers`;","\n")


for Contact in db:nrows("SELECT * FROM Contacts") do

   Id = Contact.Id
   Name = Contact.Name
   MiddleName = Contact.MiddleName
   FirstName = Contact.FirstName
   Number = Contact.Number
   NumberAtt_Default = Contact.NumberAtt_Default
   AssociatedMelody = Contact.AssociatedMelody
   LineId = Contact.LineId
   LineIdSub = Contact.LineIdSub
   NumberReferenceList = Contact.NumberReferenceList
   UUID = Contact.UUID:gsub("[\r\n]", "")
   
   sql = "INSERT INTO `Contacts` VALUES ("..Id..",'"..Name.."',NULL,'"..FirstName.."','"..Number.."',NULL,NULL,NULL,NULL,'"..NumberReferenceList.."','"..UUID.."');"

   sql_export:write(sql,"\n")

end

   for ContactNumber in db:nrows("SELECT * FROM ContactNumbers") do

      Id = ContactNumber.Id
      ContactId =ContactNumber.ContactId
      Number = ContactNumber.Number
      TypeId = ContactNumber.TypeId

   sql = "INSERT INTO `ContactNumbers` VALUES ("..Id..","..ContactId..",'"..Number.."',"..TypeId..");"

   sql_export:write(sql,"\n")

end

db:close()

sql_export:write("COMMIT;", "\n")

sql_export:close()
