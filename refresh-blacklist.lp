#!/usr/bin/lua

require "lsqlite3"

function trim(s)
  return (s:gsub( "%s$", ""))
end
 
local db = sqlite3.open("/etc/lasdb.db")

local new_sip_rules = io.open("/etc/asterisk/extensions.conf", "w")


new_sip_rules:write("[External]","\n")
new_sip_rules:write("exten => EXTENSION,1,NoOp()","\n")
new_sip_rules:write("same => n,Set(orig=${IF($[$[\"${CALLERID(num):0:2}\" = \"00\"]|$[\"${CALLERID(num):0:1}\" = \"+\"]|$[\"${TOLOWER(${CALLERID(num)})}\" = \"anonymous\"]|$[\"${CALLERID(num)}\" = \"\"]] ?:+39)}${CALLERID(num)})","\n")
new_sip_rules:write("same => n,NoOp(Il numero chiamante e' ${CALLERID(num)})","\n")

new_sip_rules:write(";INIZIO_BLACKLIST", "\n")


local item = 0

for Contact in db:nrows("SELECT * FROM Contacts") do

   item = item + 1

   Id = Contact.Id
   Name = Contact.Name
   Surname = Contact.FirstName
   
   sql="SELECT * FROM ContactNumbers WHERE ContactId='"..Id.."' LIMIT 1"

   for ContactNumber in db:nrows(sql) do

      Number = trim(ContactNumber.Number)

      if Number == "#999" then
         Number = "anonymous"
      end

   end
	
   local new_row = ""

   if string.sub(Surname,1,1) == "#" then
   	new_row = "same => n,GotoIf($[\"${orig:0:"..string.len(Number).."}\" = \""..Number.."\"]?answer)"
   else
   	new_row = "same => n,GotoIf($[\"${orig:0:"..string.len(Number).."}\" = \""..Number.."\"]?hangup)"
   end

   new_sip_rules:write(new_row, "\n")

end

db:close()

new_sip_rules:write(";FINE_BLACKLIST", "\n")
new_sip_rules:write("", "\n")
new_sip_rules:write("same => n,AGI(smooth)", "\n")
new_sip_rules:write("same => n,Goto(ok)", "\n")
new_sip_rules:write("same => n(answer),Answer()", "\n")
new_sip_rules:write("same => n,Playback(/etc/asterisk/music)", "\n")
new_sip_rules:write("same => n(hangup),System(/etc/asterisk/sorter ${orig} ${EXTEN} &)", "\n")
new_sip_rules:write("same => n,Hangup()", "\n")
new_sip_rules:write("same => n(ok),NoOp()", "\n")
new_sip_rules:write("same => n,WaitExten(30)","\n")

new_sip_rules:close()

os.execute("/etc/init.d/asterisk reload")
