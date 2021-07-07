#!/usr/bin/lua

require "lsqlite3"

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

local file = 'blacklist.sql'

if arg[2] ~= nil then
	file = arg[2]
end

local lines = lines_from(file)

local db = sqlite3.open("/etc/lasdb.db")

for k,sql in pairs(lines) do

	if (k==1 and sql ~= "-- Blacklist v.1.10") then
                print ("Can’t import: Invalid import file version") 
		break	
	end

	db:execute(sql)
        print(sql)
end

db:close()

os.execute("/usr/share/transformer/scripts/refresh-blacklist.lp")