-- Server File
-- Made by Caesarovich :p

--Put MySQL credentials here
CTime.DBHost = "0.0.0.0"
CTime.DBName = "db"
CTime.DBUser = "user"
CTime.DBPassword = "AwEsOmE"
CTime.DBPort = 3306

// DO NOT EDIT BELOW THIS LINE \\
// DO NOT EDIT BELOW THIS LINE \\
// DO NOT EDIT BELOW THIS LINE \\


require("mysqloo")
print("[CTime] Startup...")



-- SQL


function CTime.connectToDatabase()   --Connect to the DB
	CTime.DB = mysqloo.connect(CTime.DBHost, CTime.DBUser, CTime.DBPassword, CTime.DBName, CTime.DBPort)
	CTime.DB.onConnected = function() 
		print("[CTime] Database linked!") 
		CTime.MakeSQLTable() 
	end
	CTime.DB.onConnectionFailed = function() print("[CTime] Failed to connect to the database.") end
	CTime.DB:connect()

end
CTime.connectToDatabase()



function CTime.MakeSQLTable()   --init the tables
   local MakeTable = CTime.DB:query([=[CREATE TABLE IF NOT EXISTS CTime(
		user64       VARCHAR(26)    NOT NULL,
		totaltime    BIGINT(64)     NOT NULL,
			
		CONSTRAINT id PRIMARY KEY (user64)
	);]=])
   MakeTable.onSuccess = function(q)  print("[CTime] SQL Table successfuly found !") end
	MakeTable.onError = function(q, e) print("[CTime] Error on SQL Tables : ", MakeTable:error())   end
	MakeTable:start()
end


function CTime.InsertNewUser(user64)   --Check if user exists
   local InsertRow = CTime.DB:query("INSERT IGNORE INTO CTime (`user64`, `totaltime`) VALUES ("..sql.SQLStr(user64)..", 0);")
   InsertRow.onSuccess = function(q)  end
	InsertRow.onError = function(q, e) print("[CTime] Error on SQL Insert : ", InsertRow:error())   end
	InsertRow:start()
end


function CTime.GetUserSQlTime(user64, Func)   --Used to get a user totaltime in the db
   local SelectRow = CTime.DB:query("SELECT * FROM CTime WHERE user64 = "..sql.SQLStr(user64))
   if Func then
      SelectRow.onSuccess = function(q, data)
			Func(data)
		end
   end
	SelectRow.onError = function(q, e) print("[CTime] Error on SQL Select : ", SelectRow:error())   end
	SelectRow:start()
end

function CTime.UpdateUser(user64)   --Update User Row
	local time = sql.SQLStr(CTime.GetPlayerTotalTime(player.GetBySteamID64(user64)))

	local Update = CTime.DB:query("UPDATE CTime SET totaltime = "..time.." WHERE user64 = "..sql.SQLStr(user64))
	Update.onError = function(q, e) print("[CTime] Error on SQL Update : ", Update:error())   end
	Update:start()

end
-- Functions

function CTime.SetUserSQLTime(ply)
   CTime.GetUserSQlTime(ply:SteamID64(), function( data)
		local time = data[1].totaltime
      ply:SetNWInt("CTime:SQLTime", time)
   end)
end

function CTime.GetPlayerSessionTime(ply)     -- The session time
	return CurTime() - ply:GetNWInt("CTime:ArriveTime") 
end

function CTime.GetPlayerTotalTime(ply)        --The total time
	return ply:GetNWInt("CTime:SQLTime") + CTime.GetPlayerSessionTime(ply)
end

-- HOOKS

hook.Add("PlayerInitialSpawn", "CTime:Init", function(ply)  --Init player on join
   CTime.InsertNewUser(ply:SteamID64())
   ply:SetNWInt("CTime:ArriveTime", CurTime())
   CTime.SetUserSQLTime(ply)
end)

hook.Add("PlayerDisconnected", "CTime:Update", function(ply)   --Save player time on disconnect
	CTime.UpdateUser(ply:SteamID64())
end)

hook.Add("ShutDown", "CTime:Update", function()   --Save all player on server Crash/restart
	print("[CTime] Emergency saving ! ")
	for k, ply in pairs(player.GetAll()) do
		CTime.UpdateUser(ply:SteamID64())
	end
end)

