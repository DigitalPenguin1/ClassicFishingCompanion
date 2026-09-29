-- Classic Fishing Companion - Forever Theme
-- Gold and bronze styling sampled from the Forever action bar. Windows and
-- buttons are restyled after creation, so the layout code stays the same as
-- the Classic/TBC copies and only these colors decide the look.

CFCTheme = {}
local Theme = CFCTheme

-- Palette (r, g, b[, a])
Theme.GOLD = { 0.66, 0.50, 0.19, 1 }         -- Action bar slot border
Theme.GOLD_LIGHT = { 0.82, 0.66, 0.31, 1 }   -- Highlighted border, titles
Theme.BRONZE_DARK = { 0.13, 0.10, 0.04 }     -- Window background
Theme.BRONZE = { 0.22, 0.17, 0.08 }          -- Buttons, rows, bar tracks

Theme.WINDOW_ALPHA = 0.95
Theme.HUD_ALPHA = 0.5

-- Tooltip art tints cleanly, so the colors above come out as sampled
local WINDOW_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local BUTTON_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

-- Parent keys BackdropTemplateMixin uses for the pieces it draws
local BACKDROP_PIECES = {
    "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
    "TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "Center",
}

-- Unpack a palette entry with an optional alpha override
function Theme.Color(color, alpha)
    return color[1], color[2], color[3], alpha or color[4] or 1
end

-- Give an existing frame a backdrop, as if it had inherited BackdropTemplate
local function AddBackdrop(frame, backdrop)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
        frame:HookScript("OnSizeChanged", frame.OnBackdropSizeChanged)
    end
    frame:SetBackdrop(backdrop)
end

-- Restyle a BasicFrameTemplateWithInset window: drop the template's art,
-- keep its close button, and draw the gold border and bronze background.
-- Call right after CreateFrame, before adding the window's own textures.
function Theme.SkinWindow(frame)
    for _, region in ipairs({ frame:GetRegions() }) do
        if region:IsObjectType("Texture") then
            region:Hide()
        end
    end
    if frame.Inset then frame.Inset:Hide() end
    if frame.NineSlice then frame.NineSlice:Hide() end

    -- The template's corners share parent keys with the backdrop's pieces
    -- (TopLeftCorner, TopRightCorner). The backdrop reuses any texture it
    -- finds under those keys, so drop them and let it make its own.
    for _, key in ipairs(BACKDROP_PIECES) do
        frame[key] = nil
    end

    AddBackdrop(frame, WINDOW_BACKDROP)
    frame:SetBackdropColor(Theme.Color(Theme.BRONZE_DARK, Theme.WINDOW_ALPHA))
    frame:SetBackdropBorderColor(Theme.Color(Theme.GOLD))
end

-- Title text in the theme's gold
function Theme.StyleTitle(fontString)
    fontString:SetTextColor(Theme.Color(Theme.GOLD_LIGHT))
end

local function UpdateButtonBorder(button)
    if not button:IsEnabled() then
        button:SetBackdropBorderColor(Theme.Color(Theme.GOLD, 0.4))
    elseif button.cfcSelected then
        button:SetBackdropBorderColor(Theme.Color(Theme.GOLD_LIGHT))
    else
        button:SetBackdropBorderColor(Theme.Color(Theme.GOLD))
    end
end

-- Restyle a UIPanelButtonTemplate (or GameMenuButtonTemplate) button.
-- The template swaps its red art on press and hover, so the art is faded
-- out with alpha rather than hidden.
function Theme.SkinButton(button)
    if button.cfcSkinned then
        return
    end
    button.cfcSkinned = true

    for _, key in ipairs({ "Left", "Middle", "Right" }) do
        if button[key] then
            button[key]:SetAlpha(0)
        end
    end
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetDisabledTexture", "GetHighlightTexture" }) do
        local texture = button[getter] and button[getter](button)
        if texture then
            texture:SetAlpha(0)
        end
    end

    AddBackdrop(button, BUTTON_BACKDROP)
    button:SetBackdropColor(Theme.Color(Theme.BRONZE, 0.9))

    -- HIGHLIGHT layer shows on mouseover and while LockHighlight is on
    button.cfcHighlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.cfcHighlight:SetPoint("TOPLEFT", 3, -3)
    button.cfcHighlight:SetPoint("BOTTOMRIGHT", -3, 3)
    button.cfcHighlight:SetColorTexture(Theme.Color(Theme.GOLD_LIGHT, 0.15))

    -- Hover is shown by the HIGHLIGHT fill alone: most buttons SetScript their
    -- own OnEnter/OnLeave afterwards, which would wipe a hook there
    button:HookScript("OnEnable", UpdateButtonBorder)
    button:HookScript("OnDisable", UpdateButtonBorder)
    UpdateButtonBorder(button)
end

-- Mark a skinned button as the active one (used for the tab row)
function Theme.SetSelected(button, selected)
    button.cfcSelected = selected
    if selected then
        button:LockHighlight()
    else
        button:UnlockHighlight()
    end
    if button.cfcSkinned then
        UpdateButtonBorder(button)
    end
end
