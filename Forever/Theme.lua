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

-- Draw a 1px border around a region, using textures on the region's frame
function Theme.AddBorder(frame, region, color, alpha)
    local r, g, b, a = Theme.Color(color or Theme.GOLD, alpha)
    local edges = {}
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local edge = frame:CreateTexture(nil, "OVERLAY")
        edge:SetColorTexture(r, g, b, a)
        edges[side] = edge
    end
    edges.TOP:SetPoint("TOPLEFT", region, "TOPLEFT", -1, 1)
    edges.TOP:SetPoint("TOPRIGHT", region, "TOPRIGHT", 1, 1)
    edges.TOP:SetHeight(1)
    edges.BOTTOM:SetPoint("BOTTOMLEFT", region, "BOTTOMLEFT", -1, -1)
    edges.BOTTOM:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", 1, -1)
    edges.BOTTOM:SetHeight(1)
    edges.LEFT:SetPoint("TOPLEFT", region, "TOPLEFT", -1, 1)
    edges.LEFT:SetPoint("BOTTOMLEFT", region, "BOTTOMLEFT", -1, -1)
    edges.LEFT:SetWidth(1)
    edges.RIGHT:SetPoint("TOPRIGHT", region, "TOPRIGHT", 1, 1)
    edges.RIGHT:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", 1, -1)
    edges.RIGHT:SetWidth(1)

    function edges:SetColor(cr, cg, cb, ca)
        for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
            self[side]:SetColorTexture(cr, cg, cb, ca or 1)
        end
    end
    function edges:SetShown(shown)
        for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
            self[side]:SetShown(shown)
        end
    end
    return edges
end

-- Glossy status bar fill, tinted. Replaces a flat SetColorTexture on bar fills.
local STATUSBAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
function Theme.SetBarFill(texture, r, g, b, a)
    texture:SetTexture(STATUSBAR_TEXTURE)
    texture:SetVertexColor(r, g, b, a or 1)
end

-- Crop the default icon edge and give it a 1px border colored by item quality
function Theme.StyleIcon(frame, icon)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon.cfcBorder = Theme.AddBorder(frame, icon, Theme.GOLD, 0.6)
end

-- Quality 2 (green) and up get their quality color; common and unknown stay gold
function Theme.SetIconQuality(icon, quality)
    if not icon.cfcBorder then
        return
    end
    if quality and quality >= 2 and C_Item and C_Item.GetItemQualityColor then
        local r, g, b = C_Item.GetItemQualityColor(quality)
        if r then
            icon.cfcBorder:SetColor(r, g, b, 1)
            return
        end
    end
    icon.cfcBorder:SetColor(Theme.Color(Theme.GOLD, 0.6))
end

-- Modern dropdown (WowStyle1DropdownTemplate) with one radio option per choice.
--   opts.getOptions()      -> { { text = "...", value = ... }, ... }
--   opts.getSelected()     -> the selected value, or nil
--   opts.onSelect(value)   -> called when the player picks an option
--   opts.defaultText       -> shown while nothing is selected
--   opts.emptyText         -> shown (disabled) when there are no options
-- Call dropdown:GenerateMenu() after changing the selection from outside.
function Theme.CreateDropdown(parent, width, opts)
    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(width)
    if opts.defaultText then
        dropdown:SetDefaultText(opts.defaultText)
    end

    local function IsSelected(value)
        return opts.getSelected() == value
    end
    local function SetSelected(value)
        opts.onSelect(value)
    end

    dropdown:SetupMenu(function(_, rootDescription)
        local options = opts.getOptions()
        if #options == 0 and opts.emptyText then
            rootDescription:CreateTitle(opts.emptyText)
        end
        -- Long catch lists scroll instead of running off the screen
        if #options > 20 and rootDescription.SetScrollMode then
            rootDescription:SetScrollMode(20 * 20)
        end
        for _, option in ipairs(options) do
            rootDescription:CreateRadio(option.text, IsSelected, SetSelected, option.value)
        end
    end)
    return dropdown
end

-- Scroll area with the modern thin scrollbar (ScrollFrameTemplate +
-- MinimalScrollBar). Falls back to the old UIPanelScrollFrameTemplate if the
-- modern template is missing or didn't build its scrollbar.
function Theme.CreateScrollFrame(parent, name)
    local ok, scrollFrame = pcall(CreateFrame, "ScrollFrame", name, parent, "ScrollFrameTemplate")
    if ok and scrollFrame and scrollFrame.ScrollBar then
        return scrollFrame
    end
    if ok and scrollFrame then
        scrollFrame:Hide()
    end
    return CreateFrame("ScrollFrame", name and (name .. "Legacy") or nil, parent, "UIPanelScrollFrameTemplate")
end
