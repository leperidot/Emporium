do -- minimap icon
    EmporiumIcon = CreateFrame('Button', "EmporiumIcon", Minimap)
    EmporiumIcon:SetClampedToScreen(true)
    EmporiumIcon:SetMovable(true)
    EmporiumIcon:EnableMouse(true)
    EmporiumIcon:RegisterForDrag('LeftButton')
    EmporiumIcon:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

    EmporiumIcon:SetWidth(31)
    EmporiumIcon:SetHeight(31)
    EmporiumIcon:SetFrameLevel(9)
    EmporiumIcon:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    EmporiumIcon:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

    EmporiumIcon:SetScript("OnDragStart", function()
        if IsControlKeyDown() then
            this:StartMoving()
        end
    end)

    EmporiumIcon:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    EmporiumIcon:SetScript("OnClick", function()
        if Browser:IsShown() then
            Browser:Hide()
        else
            Browser:Show()
        end
    end)

    EmporiumIcon:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, ANCHOR_BOTTOMLEFT)
        GameTooltip:SetText("Emporium", 1, 0.82, 0, 1)
        GameTooltip:AddLine("Left-Click to open the market browser.", 1, 1, 1)
        GameTooltip:AddLine("Hold control and drag to move.", 1, 1, 1)
        GameTooltip:Show()
    end)

    EmporiumIcon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    EmporiumIcon:RegisterEvent("PLAYER_ENTERING_WORLD")
    EmporiumIcon:SetScript("OnEvent", function()
        this:Show()
    end)

    EmporiumIcon.icon = EmporiumIcon:CreateTexture(nil, 'BACKGROUND')
    EmporiumIcon.icon:SetWidth(20)
    EmporiumIcon.icon:SetHeight(20)
    EmporiumIcon.icon:SetTexture("Interface\\Icons\\inv_misc_note_02")
    EmporiumIcon.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    EmporiumIcon.icon:SetPoint('CENTER', 1, 1)

    EmporiumIcon.overlay = EmporiumIcon:CreateTexture(nil, 'OVERLAY')
    EmporiumIcon.overlay:SetWidth(53)
    EmporiumIcon.overlay:SetHeight(53)
    EmporiumIcon.overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    EmporiumIcon.overlay:SetPoint('TOPLEFT', 0, 0)
end
