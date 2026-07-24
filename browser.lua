local backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local BROWSER_WIDTH = 780

CreateScrollFrame = --[[pfUI.api.CreateScrollFrame or]] function(name, parent)
    local f = CreateFrame("ScrollFrame", name, parent)
    -- create slider
    f.slider = CreateFrame("Slider", nil, f)
    f.slider:SetOrientation('VERTICAL')
    f.slider:SetPoint("TOPLEFT", f, "TOPRIGHT", -7, 0)
    f.slider:SetPoint("BOTTOMRIGHT", 0, 0)
    f.slider:SetThumbTexture("Interface\\BUTTONS\\WHITE8X8")
    f.slider.thumb = f.slider:GetThumbTexture()
    f.slider.thumb:SetHeight(50)
    f.slider.thumb:SetTexture(.3, 1, .8, .5)

    local selfevent = false
    f.slider:SetScript("OnValueChanged", function()
        if selfevent then return end
        selfevent = true
        f:SetVerticalScroll(this:GetValue())
        f.UpdateScrollState()
        selfevent = false
    end)

    f.UpdateScrollState = function()
        f.slider:SetMinMaxValues(0, f:GetVerticalScrollRange())
        f.slider:SetValue(f:GetVerticalScroll())

        local m = f:GetHeight() + f:GetVerticalScrollRange()
        local v = f:GetHeight()
        local ratio = v / m

        if ratio < 1 then
            local size = math.floor(v * ratio)
            f.slider.thumb:SetHeight(size)
            f.slider:Show()
        else
            f.slider:Hide()
        end
    end

    f.Scroll = function(self, step)
        local step = step or 0

        local current = f:GetVerticalScroll()
        local max = f:GetVerticalScrollRange()
        local new = current - step

        if new >= max then
            f:SetVerticalScroll(max)
        elseif new <= 0 then
            f:SetVerticalScroll(0)
        else
            f:SetVerticalScroll(new)
        end

        f:UpdateScrollState()
    end

    f:EnableMouseWheel(1)
    f:SetScript("OnMouseWheel", function()
        this:Scroll(arg1 * 10)
    end)

    return f
end

CreateScrollChild = --[[pfUI.api.CreateScrollChild or]] function(name, parent)
    local f = CreateFrame("Frame", name, parent)

    -- dummy values required
    f:SetWidth(1)
    f:SetHeight(1)
    f:SetAllPoints(parent)

    parent:SetScrollChild(f)

    f:SetScript("OnUpdate", function()
        this:GetParent():UpdateScrollState()
    end)

    return f
end

local button_height = 40
local button_margin = 5
local BROWSER_OFFER_LIST_WIDTH = BROWSER_WIDTH - 40
local OFFER_FRAME_WIDTH = BROWSER_OFFER_LIST_WIDTH - 2 * button_margin

function CreateWTSFrame(i, parent)
    local f = CreateFrame("Frame", nil, parent)

    f.id = i + 1 -- Tabe indices start at 1 (facepalm)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", button_margin, -i * (button_height + button_margin) - button_margin)
    f:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", button_margin, -(i + 1) * (button_height + button_margin))
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local xLeft = 0
    local xRight = OFFER_FRAME_WIDTH * 0.1
    local halfPadding = 2

    f.levelRangeFrame = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.levelRangeFrame:SetPoint("TOPLEFT", f, "TOPLEFT", xLeft + halfPadding, 0)
    f.levelRangeFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", xRight - halfPadding, 0)
    f.levelRangeFrame:SetJustifyH("LEFT")
    f.levelRangeFrame:SetJustifyV("CENTER")
    f.levelRangeFrame:SetTextColor(1, 1, 1)

    xLeft = xRight
    xRight = xRight + OFFER_FRAME_WIDTH * 0.66

    f.itemNameFrame = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.itemNameFrame:SetPoint("TOPLEFT", f, "TOPLEFT", xLeft + halfPadding, 0)
    f.itemNameFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", xRight - halfPadding, 0)
    f.itemNameFrame:SetJustifyH("LEFT")
    f.itemNameFrame:SetJustifyV("MIDDLE")
    f.itemNameFrame:SetTextColor(1, 1, 1)

    xLeft = xRight
    xRight = xRight + OFFER_FRAME_WIDTH * 0.08

    f.whipserButton = CreateFrame("Button", nil, f)
    f.whipserButton:SetHeight(20)
    f.whipserButton:SetPoint("LEFT", f, "LEFT", xLeft + halfPadding, 0)
    f.whipserButton:SetPoint("RIGHT", f, "LEFT", xRight - halfPadding, 0)
    f.whipserButton:SetBackdrop(backdrop)
    f.whipserButton:SetBackdropColor(0, 0, 0, 1)
    f.whipserButton:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    local label = f.whipserButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetAllPoints(f.whipserButton)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetText("Whisper")
    label:SetTextColor(1, 0.2, 1)
    f.whipserButton:SetScript("OnClick",
        function() ChatFrame_OpenChat("/w " .. f.offer.username .. " ", DEFAULT_CHAT_FRAME) end)
    f.whipserButton:SetScript("OnEnter", function() this:SetBackdropBorderColor(1, 0.2, 1, 1) end)
    f.whipserButton:SetScript("OnLeave", function() this:SetBackdropBorderColor(0.2, 0.2, 0.2, 1) end)


    xLeft = xRight
    xRight = xRight + OFFER_FRAME_WIDTH * 0.14

    f.sellerFrame = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.sellerFrame:SetPoint("TOPLEFT", f, "TOPLEFT", xLeft + halfPadding, 0)
    f.sellerFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", xRight - halfPadding, 0)
    f.sellerFrame:SetJustifyH("CENTER")
    f.sellerFrame:SetJustifyV("MIDDLE")
    f.sellerFrame:SetTextColor(1, 1, 1)

    xLeft = xRight
    xRight = xRight + 20

    f.clearOffer = CreateFrame("Button", nil, f)
    f.clearOffer:SetHeight(20)
    f.clearOffer:SetPoint("LEFT", f, "LEFT", xLeft + halfPadding, 0)
    f.clearOffer:SetPoint("RIGHT", f, "LEFT", xRight - halfPadding, 0)
    f.clearOffer:SetBackdrop(backdrop)
    f.clearOffer:SetBackdropColor(0, 0, 0, 1)
    f.clearOffer:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    local xStr = f.clearOffer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xStr:SetAllPoints(f.clearOffer)
    xStr:SetJustifyH("CENTER")
    xStr:SetJustifyV("MIDDLE")
    xStr:SetText("X")
    xStr:SetTextColor(0.7, 0.2, 0.2)
    f.clearOffer:SetScript("OnClick", function() 
        table.remove(Market, f.id)
        RefreshBrowser()
    end)
    f.clearOffer:SetScript("OnEnter", function() this:SetBackdropBorderColor(1, 0.2, 0.2, 1) end)
    f.clearOffer:SetScript("OnLeave", function() this:SetBackdropBorderColor(0.2, 0.2, 0.2, 1) end)


    f.SetOffer = function(offer)
        f.offer = offer
        f.RefreshFrame()
    end
    f.RefreshFrame = function()
        f.levelRangeFrame:SetText("[" .. f.offer.levelMin .. " - " .. f.offer.levelMax .. "]")
        f.itemNameFrame:SetText(f.offer.originalMessage)
        f.sellerFrame:SetText(f.offer.username)
    end
    --f:Hide()
    --f:SetID(i)

    --f.btype = resultType
    --f.pfResultButton = true

    --f.tex = f:CreateTexture("BACKGROUND")
    --f.tex:SetAllPoints(f)
    --f.tex:SetTexture(1,1,1, ( compat.mod(i,2) == 1 and .02 or .04))

    -- text properties
    --f.text = f:CreateFontString("Caption", "LOW", "GameFontWhite")
    --f.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
    --f.text:SetAllPoints(f)
    --f.text:SetJustifyH("LEFT")
    --f.idText = f:CreateFontString("ID", "LOW", "GameFontDisable")
    --f.idText:SetPoint("LEFT", f, "LEFT", button_height, 0)

    --[[
  -- favourite button
  f.fav = CreateFrame("Button", nil, f)
  f.fav:SetHitRectInsets(-3,-3,-3,-3)
  f.fav:SetPoint("LEFT", 0, 0)
  f.fav:SetWidth(16)
  f.fav:SetHeight(16)
  f.fav.icon = f.fav:CreateTexture("OVERLAY")
  f.fav.icon:SetTexture(pfQuestConfig.path.."\\img\\fav")
  f.fav.icon:SetAllPoints(f.fav)

  -- faction icons
  if resultType ~= "items" then
    f.factionA = f:CreateTexture("OVERLAY")
    f.factionA:SetTexture(pfQuestConfig.path.."\\img\\icon_alliance")
    f.factionA:SetWidth(16)
    f.factionA:SetHeight(16)
    f.factionA:SetPoint("RIGHT", -5, 0)
    f.factionH = f:CreateTexture("OVERLAY")
    f.factionH:SetTexture(pfQuestConfig.path.."\\img\\icon_horde")
    f.factionH:SetWidth(16)
    f.factionH:SetHeight(16)
    f.factionH:SetPoint("RIGHT", -24, 0)
  end

  -- drop, loot, vendor buttons
  if resultType == "items" then
    local buttons = {
      ["U"] = { ["offset"] = -5,  ["icon"] = "icon_npc",    ["parameter"] = "id",   },
      ["O"] = { ["offset"] = -24, ["icon"] = "icon_object", ["parameter"] = "id",   },
      ["V"] = { ["offset"] = -43, ["icon"] = "icon_vendor", ["parameter"] = "name", },
    }

    for button, settings in pairs(buttons) do
      f[button] = CreateFrame("Button", nil, f)
      f[button]:SetHitRectInsets(-3,-3,-3,-3)
      f[button]:SetPoint("RIGHT", settings.offset, 0)
      f[button]:SetWidth(16)
      f[button]:SetHeight(16)

      f[button].buttonType = button
      f[button].parameter = settings.parameter

      f[button].icon = f[button]:CreateTexture("OVERLAY")
      f[button].icon:SetAllPoints(f[button])
      f[button].icon:SetTexture(pfQuestConfig.path.."\\img\\"..settings.icon)

      f[button]:SetScript("OnEnter", ResultButtonEnterSpecial)
      f[button]:SetScript("OnLeave", ResultButtonLeaveSpecial)
      f[button]:SetScript("OnClick", ResultButtonClickSpecial)
    end
  end
]]
    -- bind functions
    --f.Reload = ResultButtonReload
    --f:SetScript("OnLeave", ResultButtonLeave)
    --:SetScript("OnEnter", ResultButtonEnter)
    --[[
    f:SetScript("OnClick", function()
        DEFAULT_CHAT_FRAME:AddMessage("Button " .. f:GetID())
    end)
    ]]
    --f.fav:SetScript("OnClick", ResultButtonClickFav)

    return f
end

local function ResultButtonClick()
end

Browser = CreateFrame("Frame", "EmporiumBrowser", UIParent)
Browser:Hide()
Browser:SetWidth(BROWSER_WIDTH)
Browser:SetHeight(480)
Browser:SetPoint("CENTER", 0, 0)
Browser:SetFrameStrata("FULLSCREEN_DIALOG")
Browser:SetMovable(true)
Browser:EnableMouse(true)
Browser:RegisterForDrag("LeftButton")
Browser:SetScript("OnDragStart", function() this:StartMoving() end)
Browser:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
Browser:SetBackdrop(backdrop)
Browser:SetBackdropColor(0, 0, 0, 0.5)
Browser:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

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
closeBtn:SetBackdrop(backdrop)
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

Browser.tab = CreateScrollFrame("EmporiumBrowserTab", Browser)
Browser.tab:SetPoint("TOPLEFT", Browser, "TOPLEFT", 10, -65)
Browser.tab:SetPoint("BOTTOMRIGHT", Browser, "BOTTOMRIGHT", -10, 45)
Browser.tab:SetBackdrop(backdrop)
Browser.tab:SetBackdropColor(0, 0, 0, 0.5)
Browser.tab:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

--[[
Browser.tab.backdrop = CreateFrame("Frame", "EmporiumBrowserTabBackdrop", Browser.tab)
Browser.tab.backdrop:SetFrameLevel(1)
Browser.tab.backdrop:SetPoint("TOPLEFT", Browser.tab, "TOPLEFT", -5, 5)
Browser.tab.backdrop:SetPoint("BOTTOMRIGHT", Browser.tab, "BOTTOMRIGHT", 5, -5)
Browser.tab.backdrop:SetBackdrop(backdrop)
Browser.tab.backdrop:SetBackdropColor(0, 0, 0, 0.5)
Browser.tab.backdrop:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
]]

Browser.tab.list = CreateScrollChild("EmporiumBrowserTabList", Browser.tab)
Browser.tab.list:SetWidth(BROWSER_OFFER_LIST_WIDTH)


Browser.tab.buttons = {}

local MAX_OFFER_COUNT = 256
function RefreshBrowser()
    Browser.tab.list:Hide()
    local iOffer = 0
    for _, offer in EmporiumDB.Market.wts do
        if iOffer >= MAX_OFFER_COUNT then
            DEFAULT_CHAT_FRAME:AddMessage("|c00ff0000[Emporium]: Browser full")
            break
        end
        Browser.tab.buttons[iOffer] = Browser.tab.buttons[iOffer] or CreateWTSFrame(iOffer, Browser.tab.list)
        Browser.tab.buttons[iOffer].SetOffer(offer)
        Browser.tab.buttons[iOffer]:Show()
        iOffer = iOffer + 1
    end

    Browser.tab.list:SetHeight(iOffer * (button_height + button_margin))

    while Browser.tab.buttons[iOffer] do
        Browser.tab.buttons[iOffer]:Hide()
        iOffer = iOffer + 1
    end

    Browser.tab:SetScrollChild(Browser.tab.list)
    Browser.tab.list:Show()
end

Browser:SetScript("OnShow", function()
    RefreshBrowser()
    Browser.tab:SetVerticalScroll(0)
    PlaySound("igSpellBookOpen")
end)

Browser:SetScript("OnHide", function()
    PlaySound("igSpellBookClose")
end)
