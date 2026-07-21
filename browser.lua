Browser = CreateFrame("Frame", "EmporiumBrowser", UIParent)
-- Browser:Hide()
Browser:SetWidth(640)
Browser:SetHeight(480)
Browser:SetPoint("CENTER", 0, 0)
Browser:SetFrameStrata("FULLSCREEN_DIALOG")
Browser:SetMovable(true)
Browser:EnableMouse(true)
Browser:RegisterForDrag("LeftButton")
Browser:SetScript("OnDragStart", function() this:StartMoving() end)
Browser:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
Browser:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
Browser:SetBackdropColor(0, 0, 0, 0.85)
Browser:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

-- Title
local title = Browser:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", Browser, "TOP", 0, -10)
title:SetText("Emporium")
title:SetTextColor(1.0, 0.82, 0)

-- Close button
local closeBtn = CreateFrame("Button", nil, Browser)
closeBtn:SetWidth(18)
closeBtn:SetHeight(18)
closeBtn:SetPoint("TOPRIGHT", Browser, "TOPRIGHT", -2, -2)
closeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
closeBtn:SetBackdropColor(0, 0, 0, 1)
closeBtn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
local xStr = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
xStr:SetAllPoints(closeBtn)
xStr:SetJustifyH("CENTER")
xStr:SetJustifyV("MIDDLE")
xStr:SetText("X")
xStr:SetTextColor(0.7, 0.2, 0.2)
closeBtn:SetScript("OnClick", function() Browser:Hide() end)
closeBtn:SetScript("OnEnter", function() this:SetBackdropBorderColor(1, 0.2, 0.2, 1) end)
closeBtn:SetScript("OnLeave", function() this:SetBackdropBorderColor(0.2, 0.2, 0.2, 1) end)
