-- HUD File
-- By Caesarovich
-- No editing there !


print("[CTime] Client HUD starting...")
local scrw, scrh = ScrW(), ScrH()

--fonts

surface.CreateFont("CTime:BigFont", {
   font = "Arial",
   size = scrh * 0.02
})
surface.CreateFont("CTime:SmallFont", {
   font = "Arial",
   size = scrh * 0.015
})


function CTime.GetPlayerSessionTime(ply)     -- The session time
	return CurTime() - ply:GetNWInt("CTime:ArriveTime") 
end

function CTime.GetPlayerTotalTime(ply)        --The total time
	return ply:GetNWInt("CTime:SQLTime") + CTime.GetPlayerSessionTime(ply)
end

function CTime.ReadableTime(timesec)
   local timesec = math.floor(timesec)
   return math.floor((timesec / 60 / 60 / 24)).."d "..math.floor((timesec / 60 / 60 % 24)).."h "..math.floor((timesec / 60 % 60)).."m "..(timesec % 60).."s"
end


function CTime.HUD()
   local me = LocalPlayer()
   local DimW, DimH = scrw * 0.12, scrh * 0.07
   local PosX, PosY = scrw - DimW - scrw * 0.01, scrh * 0.2

   draw.RoundedBox(6, PosX, PosY, DimW, DimH, CTime.BackgroundColor)
   draw.RoundedBoxEx(6, PosX, PosY, DimW, DimH * 0.3, CTime.TopMenuColor, true, true, false, false)
   draw.SimpleText(CTime.TopText, "CTime:BigFont", PosX + DimW/2 , PosY + DimH * 0.15, Color( 250, 250, 250, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

   draw.SimpleText(CTime.TotalTimeText, "CTime:SmallFont", PosX + 5 , PosY + DimH * 0.37, Color( 250, 250, 250, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
   draw.SimpleText(CTime.SessionTimeText, "CTime:SmallFont", PosX + 5 , PosY + DimH * 0.65, Color( 250, 250, 250, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

   draw.SimpleText(CTime.ReadableTime(CTime.GetPlayerTotalTime(me)), "CTime:SmallFont", PosX + DimW - 5 , PosY + DimH * 0.37, Color( 250, 250, 250, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
   draw.SimpleText(CTime.ReadableTime(CTime.GetPlayerSessionTime(me)), "CTime:SmallFont", PosX + DimW - 5, PosY + DimH * 0.65, Color( 250, 250, 250, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

hook.Add("HUDPaint", "CTime:HUD", CTime.HUD)

print("[CTime] Loaded Client Side !")