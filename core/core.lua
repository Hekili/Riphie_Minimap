local addon, ns = ...
local cfg = ns.cfg

local backdrop_table = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

-- Minimap
Minimap:ClearAllPoints()
Minimap:SetPoint(cfg.pos.a1, cfg.pos.af, cfg.pos.a2, cfg.pos.x, cfg.pos.y)
Minimap:SetScale(cfg.scale)
Minimap:SetSize(cfg.width, cfg.height)
Minimap:SetBackdrop(backdrop_table)
Minimap:SetBackdropColor(0, 0, 0, 1)
Minimap:SetBackdropBorderColor(0, 0, 0, 1)
Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")

-- Minimap buttons
MinimapBorder:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapBorderTop:Hide()
MiniMapVoiceChatFrame:Hide()
MinimapNorthTag:SetTexture(nil)
MinimapZoneTextButton:Hide()
MiniMapWorldMapButton:Hide()
GameTimeFrame:Hide()

-- Instance difficulty
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetScale(0.7)
MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 3, -3)

if not IsAddOnLoaded("Blizzard_TimeManager") then
  LoadAddOn("Blizzard_TimeManager")
end

-- Clock
local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
clockFrame:Hide()
clockTime:SetFont("Interface\\AddOns\\Riphie_Minimap\\media\\font.ttf", 11, "THINOUTLINE")
clockTime:SetTextColor(1, 1, 1)
clockTime:SetShadowOffset(0, 0)
clockTime:SetShadowColor(0, 0, 0, 0)
clockTime:Show()
TimeManagerClockButton:SetPoint("CENTER", Minimap, "BOTTOM", 0, 12)

-- Mail
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 1, -5)
MiniMapMailFrame:SetFrameStrata("LOW")
MiniMapMailIcon:SetTexture("Interface\\AddOns\\Riphie_Minimap\\media\\mail")
MiniMapMailBorder:Hide()

-- LFG
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, -2)
QueueStatusMinimapButtonBorder:Hide()

for i = 1, QueueStatusFrame:GetNumRegions() do
  local region = select(i, QueueStatusFrame:GetRegions())

  if region:GetObjectType() == "Texture" then
    region:SetTexture(nil)
  end
end

QueueStatusFrame:SetBackdrop(backdrop_table)
QueueStatusFrame:SetBackdropColor(0, 0, 0, 0.5)
QueueStatusFrame:SetBackdropBorderColor(0, 0, 0, 1)

-- Tracking
MiniMapTrackingBackground:SetAlpha(0)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPRIGHT", Minimap, 1, 1)
MiniMapTrackingButtonBorder:Hide()
MiniMapTrackingButton:SetBackdropBorderColor(0, 0, 0)
MiniMapTracking:SetAlpha(0)

-- Coords
local CoordFrame = CreateFrame("Button", "MinimapCoords", Minimap)
CoordFrame:SetPoint("TOP", Minimap, "TOP", 0, -5)
CoordFrame:RegisterForClicks("AnyDown")

local mapCoord = CoordFrame:CreateFontString("MinimapCoords", "OVERLAY")
mapCoord:SetFont("Interface\\AddOns\\Riphie_Minimap\\media\\font.ttf", 11, "THINOUTLINE")
mapCoord:SetJustifyH("RIGHT")
mapCoord:SetTextColor(1, 1, 1)
mapCoord:SetShadowOffset(0, 0)
mapCoord:SetShadowColor(0, 0, 0, 0)
mapCoord:SetAlpha(0)
mapCoord:Show()
mapCoord:SetPoint("TOP", Minimap, "TOP", 0, -5)

local CoordTimer = 0
Minimap:SetScript("OnUpdate", function(self, elapsed)
  CoordTimer = CoordTimer - elapsed

  if CoordTimer < 0 then
    local x, y = GetPlayerMapPosition("player")
    mapCoord:SetText( ( x ~= 0 and y ~= 0 ) and string.format("%.1f, %.1f", x * 100, y * 100) or ' ' )
	CoordFrame:SetSize( mapCoord:GetSize() )
    CoordTimer = 0.2
  end
end)

local CoordStick = false
CoordFrame:SetScript("OnMouseDown", function(self, ...)
	if not mapCoord:IsMouseOver() then return end
	
	CoordStick = not CoordStick
	
	if CoordStick then
		mapCoord:SetTextColor( 1, 0.82, 0 )
	else
		mapCoord:SetTextColor( 1, 1, 1 )
	end
	
	return 
end )

local OnLeave = function()
  if not Minimap:IsMouseOver()
      and not TimeManagerClockButton:IsMouseOver()
      and not MiniMapTrackingButton:IsMouseOver()
      and not QueueStatusMinimapButton:IsMouseOver()
      and not MiniMapMailFrame:IsMouseOver() then
    MiniMapTracking:SetAlpha(0)
    if not CoordStick then mapCoord:SetAlpha(0) end
  end
end

Minimap:HookScript("OnEnter", function()
  MiniMapTracking:SetAlpha(1)
  mapCoord:SetAlpha(1)
end)

Minimap:HookScript("OnLeave", OnLeave)
TimeManagerClockButton:HookScript("OnLeave", OnLeave)
MiniMapTrackingButton:HookScript("OnLeave", OnLeave)
QueueStatusMinimapButton:HookScript("OnLeave", OnLeave)
MiniMapMailFrame:HookScript("OnLeave", OnLeave)

-- Zoom in/out
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
  if delta > 0 then
    MinimapZoomIn:Click()
  elseif delta < 0 then
    MinimapZoomOut:Click()
  end
end)
