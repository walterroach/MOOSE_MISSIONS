---
-- Name: CAZ-000 - Capture Zone
-- Author: FlightControl
-- Date Created: 20 Mar 2017
--
-- This demonstration mission explains how to use the ZONE_CAPTURE_COALITION functionality.

do -- Setup the Command Centers
  
  RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
  US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )

end

do -- Missions
  
  US_Mission_EchoBay = MISSION:New( US_CC, "Echo Bay", "Primary",
    "Welcome trainee. The airport Groom Lake in Echo Bay needs to be captured.\n" ..
    "There are five random capture zones located at the airbase.\n" ..
    "Move to one of the capture zones, destroy the fuel tanks in the capture zone, " ..
    "and occupy each capture zone with a platoon.\n " .. 
    "Your orders are to hold position until all capture zones are taken.\n" ..
    "Use the map (F10) for a clear indication of the location of each capture zone.\n" ..
    "Note that heavy resistance can be expected at the airbase!\n" ..
    "Mission 'Echo Bay' is complete when all five capture zones are taken, and held for at least 5 minutes!"
    , coalition.side.RED)
    
  US_Mission_EchoBay:Start()

end



do 
  CaptureZone = ZONE:New( "CaptureZone" )
  
  ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.RED ) 
  
  
  --- @param Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
    if From ~= To then
      local Coalition = self:GetCoalition()
      self:E( { Coalition = Coalition } )
      if Coalition == coalition.side.BLUE then
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
        US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      else
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
        RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      end
    end
  end
  
  --- @param Functional.Protect#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterEmpty()
    ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
    US_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
  end
  
  
  --- @param Functional.Protect#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterAttacked()
    ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
    local Coalition = self:GetCoalition()
    self:E({Coalition = Coalition})
    if Coalition == coalition.side.BLUE then
      US_CC:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      RU_CC:MessageTypeToCoalition( string.format( "%s is under attack by the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end
  end
  
  --- @param Functional.Protect#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterCaptured()
    local Coalition = self:GetCoalition()
    self:E({Coalition = Coalition})
    if Coalition == coalition.side.BLUE then
      RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      US_CC:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end

    -- The zone was captured, now restart the Guarding process for the other coalition.    
    self:__Guard( 30 )
  end
  
  -- Start the zone monitoring process, within 5 seconds and repeat every 30 seconds.
  ZoneCaptureCoalition:Start( 5, 30 )
end  


