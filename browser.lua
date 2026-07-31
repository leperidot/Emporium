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



local function DebugHyperlinkClick(arg1, arg2, arg3, arg4)
  print("OnHyperlinkClick args:", arg1, arg2, arg3, arg4)
  if not arg1 then print("arg1 is nil") end
  if arg2 == nil then print("arg2 is nil") end
  if arg3 == nil then print("arg3 is nil") end
end

--[[ChatFrame1:SetScript("OnHyperlinkClick", function ()
    print(arg1)
    print(arg2)
    print(arg3)
end);]]

local once = true

TEST = {test = 1}
function CreateWTSFrame(index, parent)
    local f = CreateFrame("Frame", nil, parent)

    f:SetPoint("TOPLEFT", parent, "TOPLEFT", button_margin, -index * (button_height + button_margin) - button_margin)
    f:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", button_margin, -(index + 1) * (button_height + button_margin))
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

    --[[f.itemNameFrame = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.itemNameFrame:SetPoint("TOPLEFT", f, "TOPLEFT", xLeft + halfPadding, 0)
    f.itemNameFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", xRight - halfPadding, 0)
    f.itemNameFrame:SetJustifyH("LEFT")
    f.itemNameFrame:SetJustifyV("MIDDLE")
    f.itemNameFrame:SetTextColor(1, 1, 1)]]

    f.itemNameFrame = CreateFrame("SimpleHTML", nil, f)
    f.itemNameFrame:SetFont('Fonts\\FRIZQT__.TTF', 11);
    f.itemNameFrame:SetPoint("TOPLEFT", f, "TOPLEFT", xLeft + halfPadding, 0)
    f.itemNameFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", xRight - halfPadding, 0)

    f.itemNameFrame:SetScript("OnHyperlinkClick", function ()
        ChatFrame_OnHyperlinkShow(arg1, arg2, arg3)
    end)
    f.itemNameFrame:SetScript("OnHyperlinkEnter", function ()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -10, -5)
        GameTooltip:SetHyperlink(arg1)
        GameTooltip:Show()
    end)
    f.itemNameFrame:SetScript("OnHyperlinkLeave", function ()
        GameTooltip:Hide()
    end)


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
        table.remove(EmporiumDB.Market.wts, f:GetID())
        RefreshBrowser()
    end)
    f.clearOffer:SetScript("OnEnter", function() this:SetBackdropBorderColor(1, 0.2, 0.2, 1) end)
    f.clearOffer:SetScript("OnLeave", function() this:SetBackdropBorderColor(0.2, 0.2, 0.2, 1) end)


    f.SetOffer = function(offerID, offer)
        f.offer = offer
        f:SetID(offerID)
        f.RefreshFrame()
    end
    f.RefreshFrame = function()
        local lvlMin = f.offer.levelMin or 0
        local lvlMax = f.offer.levelMax or 0
        f.levelRangeFrame:SetText("[" .. f.offer.levelMin .. " - " .. f.offer.levelMax .. "]")
        f.itemNameFrame:SetText("<html><body><p>" .. f.offer.content .. "</p></body></html>")
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
table.insert(UISpecialFrames, "EmporiumBrowser")

Browser.searchText = ""
Browser.levelCheck = false

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

BROWSER_TAB_MARGIN = 10

Browser.tab = CreateScrollFrame("EmporiumBrowserTab", Browser)
Browser.tab:SetPoint("TOPLEFT", Browser, "TOPLEFT", BROWSER_TAB_MARGIN, -65)
Browser.tab:SetPoint("BOTTOMRIGHT", Browser, "BOTTOMRIGHT", -BROWSER_TAB_MARGIN, 45)
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
    local iFrame = 0
    for iOffer, offer in ipairs(EmporiumDB.Market.wts) do
        if iFrame >= MAX_OFFER_COUNT then
            DEFAULT_CHAT_FRAME:AddMessage("|c00ff0000[Emporium]: Browser full")
            break
        end

        local searchTextFilter = (not Browser.searchText or string.len(Browser.searchText) == 0) -- No search text
            or (string.find(string.lower(offer.content), string.lower(Browser.searchText)))      -- Search text match the offer
        local levelCheckFilter = (not Browser.levelCheck)
            or (UnitLevel("player") >= offer.levelMin and UnitLevel("player") <= offer.levelMax)

        if searchTextFilter and levelCheckFilter then
            Browser.tab.buttons[iFrame] = Browser.tab.buttons[iFrame] or CreateWTSFrame(iFrame, Browser.tab.list)
            Browser.tab.buttons[iFrame].SetOffer(iOffer, offer)
            Browser.tab.buttons[iFrame]:Show()
            iFrame = iFrame + 1
        end
    end

    Browser.tab.list:SetHeight(iFrame * (button_height + button_margin))

    while Browser.tab.buttons[iFrame] do
        Browser.tab.buttons[iFrame]:Hide()
        iFrame = iFrame + 1
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

Browser.input = CreateFrame("EditBox", "EmporiumBrowserSearch", Browser)
--Browser.input:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
Browser.input:SetFontObject("GameFontDisable")
Browser.input:SetAutoFocus(false)
Browser.input:SetText("Search")
Browser.input:SetJustifyH("LEFT")
Browser.input:SetPoint("TOPLEFT", Browser, "TOPLEFT", BROWSER_TAB_MARGIN, -30)
Browser.input:SetWidth(BROWSER_OFFER_LIST_WIDTH * 0.3)
Browser.input:SetHeight(20)
Browser.input:SetTextInsets(4, 4, 4, 4)
Browser.input:SetBackdrop(backdrop)
Browser.input:SetBackdropColor(0, 0, 0, 0.5)
Browser.input:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- Search icon
Browser.input.searchIcon = Browser.input:CreateTexture("$parentSearchIcon", "OVERLAY")
--Browser.input.searchIcon:SetTexture(pfQuestConfig.path .. "\\img\\tracker_search")
Browser.input.searchIcon:SetHeight(14)
Browser.input.searchIcon:SetWidth(14)
Browser.input.searchIcon:SetVertexColor(0.6, 0.6, 0.6)
Browser.input.searchIcon:SetPoint("LEFT", Browser.input, "LEFT", 6, 0)

-- Clear search input
Browser.input.clearButton = CreateFrame("Button", "$parentClearButton", Browser.input)
Browser.input.clearButton:Hide()
Browser.input.clearButton:SetHeight(17)
Browser.input.clearButton:SetWidth(17)
Browser.input.clearButton:SetPoint("RIGHT", Browser.input, "RIGHT", -3, 0)
Browser.input.clearButton.texture = Browser.input.clearButton:CreateTexture(nil, "ARTWORK")
--Browser.input.clearButton.texture:SetTexture(pfQuestConfig.path .. "\\img\\tracker_close")
Browser.input.clearButton.texture:SetHeight(17)
Browser.input.clearButton.texture:SetWidth(17)
Browser.input.clearButton.texture:SetAlpha(0.5)
Browser.input.clearButton.texture:SetPoint("TOPLEFT", Browser.input.clearButton, "TOPLEFT", 0, 0)
Browser.input.clearButton:SetScript("OnEnter", function()
    this.texture:SetAlpha(1.0)
end)
Browser.input.clearButton:SetScript("OnLeave", function()
    this.texture:SetAlpha(0.5)
end)
Browser.input.clearButton:SetScript("OnMouseDown", function()
    if this:IsEnabled() then
        this.texture:SetPoint("TOPLEFT", this, "TOPLEFT", 1, -1)
    end
end)
Browser.input.clearButton:SetScript("OnMouseUp", function()
    this.texture:SetPoint("TOPLEFT", this, "TOPLEFT", 0, 0)
end)
Browser.input.clearButton:SetScript("OnClick", function()
    PlaySound("igMainMenuOptionCheckBoxOn")
    Browser.input:SetText("")
    --[[ If there is no focus, then the ClearFocus() method does not call the OnEditFocusLost script.
    In 1.12, there is no HasFocus() method, so there is no way to check for focus. therefore,
    for ease of implementation and to avoid double calling the OnEditFocusLost script, I use the
    SetFocus() method to accurately ensure that the OnEditFocusLost script is called.]]
    Browser.input:SetFocus()
    Browser.input:ClearFocus()
end)


Browser.input:SetScript("OnEscapePressed", function() this:ClearFocus() end)
Browser.input:SetScript("OnEnterPressed", function() this:ClearFocus() end)
Browser.input:SetScript("OnEditFocusGained", function()
    this:HighlightText()
    this:SetFontObject("GameFontWhite")
    this.searchIcon:SetVertexColor(1.0, 1.0, 1.0)
    if this:GetText() == "Search" then this:SetText("") end
    this.clearButton:Show()
end)

Browser.input:SetScript("OnEditFocusLost", function()
    this:HighlightText(0, 0)
    this:SetFontObject("GameFontDisable")
    this.searchIcon:SetVertexColor(0.6, 0.6, 0.6)
    if this:GetText() == "" then
        this:SetText("Search")
        this.clearButton:Hide()
    end
end)

-- This script updates all the search tabs when the search text changes
Browser.input:SetScript("OnTextChanged", function()
    local text = this:GetText()
    if (text == "Search") then text = "" end

    local newSearch = string.len(text) >= 3 and text or ""
    if newSearch ~= Browser.searchText then
        Browser.searchText = newSearch
        RefreshBrowser()
    end
end)

Browser.levelCheckButton = CreateFrame("CheckButton", "EmporiumBrowserLevelCheck", Browser, "UICheckButtonTemplate")
Browser.levelCheckButton:SetPoint("LEFT", Browser.input, "RIGHT", 145, -2)
Browser.levelCheckButton:SetWidth(24)
Browser.levelCheckButton:SetHeight(24)
-- Browser.levelCheckButton_GlobalNameText:SetText("CheckBox Name")
Browser.levelCheckButton.tooltip = "This is where you place MouseOver Text."
Browser.levelCheckButton:SetScript("OnClick", function()
    Browser.levelCheck = this:GetChecked()
    RefreshBrowser()
end
);

Browser.levelCheckButton.label = Browser.levelCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Browser.levelCheckButton.label:SetPoint("RIGHT", Browser.levelCheckButton, "LEFT", -2, 2)
Browser.levelCheckButton.label:SetJustifyV("MIDDLE")
Browser.levelCheckButton.label:SetText("Level range")
