local E, L, V, P, G = unpack(ElvUI)
local PLUGIN = E:GetModule("ElvUI_CombatAlert")

local Mod = PLUGIN:NewModule("CombatInOut", "AceEvent-3.0")

local _G = _G

Mod.DB_KEY = "combat_in_out"
Mod.MOVER_NAME = "CombatInOutMover"

local Loc = PLUGIN.L or {}
local function T(key, fallback)
    return Loc[key] or fallback or key
end

local function FetchFont(name)
    if not E.LSM then return nil end
    return E.LSM:Fetch("font", name)
end

local function ApplyFontWithOutline(fs, fontPath, size, outline)
    outline = outline or "OUTLINE"

    local flags = nil
    local shadowOffsetX, shadowOffsetY = 0, 0
    local shadowAlpha = 0

    if outline == "NONE" then
        flags = nil
    elseif outline == "OUTLINE" then
        flags = "OUTLINE"
    elseif outline == "THICKOUTLINE" then
        flags = "THICKOUTLINE"
    elseif outline == "MONOCHROMEOUTLINE" then
        flags = "MONOCHROMEOUTLINE"
    elseif outline == "OUTLINEMONOCHROME" then
        flags = "OUTLINE,MONOCHROME"
    elseif outline == "SHADOW" then
        flags = nil
        shadowOffsetX, shadowOffsetY = 1, -1
        shadowAlpha = 0.75
    elseif outline == "SHADOWOUTLINE" then
        flags = "OUTLINE"
        shadowOffsetX, shadowOffsetY = 1, -1
        shadowAlpha = 0.75
    elseif outline == "SHADOWTHICKOUTLINE" then
        flags = "THICKOUTLINE"
        shadowOffsetX, shadowOffsetY = 2, -2
        shadowAlpha = 0.85
    else
        flags = "OUTLINE"
    end

    if flags then
        fs:SetFont(fontPath, size, flags)
    else
        fs:SetFont(fontPath, size)
    end

    if shadowAlpha > 0 then
        fs:SetShadowColor(0, 0, 0, shadowAlpha)
        fs:SetShadowOffset(shadowOffsetX, shadowOffsetY)
    else
        fs:SetShadowColor(0, 0, 0, 0)
        fs:SetShadowOffset(0, 0)
    end
end

function Mod:GetDefaults()
    return {
        [self.DB_KEY] = {
            enabled = true,

            font = "Expressway",
            fontSize = 18,
            fontOutline = "OUTLINE_SHADOW_OUTLINE",

            begin = {
                enabled = true,
                text = T("DEFAULT_COMBAT_BEGIN", "++ Combat ++"),
                color = { r = 1.0, g = 0.2, b = 0.2, a = 1.0 },
                holdTime = 2,
                fadeEnabled = true,
                fadeTime = 2,

                soundEnabled = false,
                sound = "None",
                soundChannel = "Master",
            },

            ["end"] = {
                enabled = true,
                text = T("DEFAULT_COMBAT_END", "-- Combat --"),
               
                color = { r = 0.1, g = 1.0, b = 0.1, a = 1.0 },
                holdTime = 2,
                fadeEnabled = true,
                fadeTime = 2,

                soundEnabled = false,
                sound = "None",
                soundChannel = "Master",
            },
        }
    }
end

function Mod:GetDB()
    return E.db.ElvUI_CombatAlert[self.DB_KEY]
end

function Mod:CreateDisplay()
    if self.frame then return end

    local f = CreateFrame("Frame", "ElvUI_CombatAlert_CombatInOutFrame", E.UIParent)
    f:SetSize(180, 40)

    f:ClearAllPoints()
    f:SetPoint("CENTER", E.UIParent, "CENTER", -200, 0)

    local fs = f:CreateFontString(nil, "OVERLAY")
    fs:SetPoint("CENTER", f, "CENTER", 0, 0)
    fs:SetJustifyH("CENTER")
    fs:SetJustifyV("MIDDLE")

    f.text = fs
    self.frame = f

    E:CreateMover(
        f,
        self.MOVER_NAME,
        T("MOVER_COMBAT_IN_OUT", "Combat Begin/End"),
        nil, nil, nil,
        "ALL,SOLO",
        nil,
        "ElvUI_CombatAlert",
        PLUGIN.MOVER_CATEGORY
    )
end

function Mod:ApplyStyle()
    if not self.frame then return end
    local db = self:GetDB()

    local fontPath = FetchFont(db.font) or FetchFont("Expressway") or _G.STANDARD_TEXT_FONT
    local size = tonumber(db.fontSize) or 32
    local outline = db.fontOutline or "OUTLINE"

    ApplyFontWithOutline(self.frame.text, fontPath, size, outline)
end

function Mod:StopTimers()
    if self.holdTimer then
        self.holdTimer:Cancel()
        self.holdTimer = nil
    end

    if self.frame then
        E:UIFrameFadeRemoveFrame(self.frame)
        self.frame:SetAlpha(1)
    end
end

function Mod:HideNow()
    if not self.frame then return end
    E:UIFrameFadeRemoveFrame(self.frame)
    self.frame:SetAlpha(1)
    self.frame:Hide()
end

function Mod:ShowEntry(which)
    local db = self:GetDB()
    if not db.enabled then return end

    local entry = db[which]
    if not entry or not entry.enabled then return end

    self:CreateDisplay()
    self:StopTimers()
    self:ApplyStyle()

    self.frame.text:SetText(entry.text or "")
    local c = entry.color or {}
    self.frame.text:SetTextColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)

    self.frame:Show()
    self.frame:SetAlpha(1)

    if entry.soundEnabled and entry.sound and entry.sound ~= "None" then
        local channel = entry.soundChannel or "Master"
        local soundPath = E.LSM and E.LSM:Fetch("sound", entry.sound)
        if soundPath then
            pcall(PlaySoundFile, soundPath, channel)
        end
    end

    local hold = tonumber(entry.holdTime) or 0
    local fadeEnabled = entry.fadeEnabled ~= false
    local fade = tonumber(entry.fadeTime) or 1.5

    if hold < 0 then hold = 0 end
    if fade < 0.05 then fade = 0.05 end

    if not fadeEnabled then
        if hold > 0 then
            self.holdTimer = C_Timer.NewTimer(hold, function()
                self:HideNow()
            end)
        else
            self:HideNow()
        end
        return
    end

    if hold > 0 then
        self.holdTimer = C_Timer.NewTimer(hold, function()
            if not self.frame then return end
            E:UIFrameFadeOut(self.frame, fade, 1, 0)
        end)
    else
        E:UIFrameFadeOut(self.frame, fade, 1, 0)
    end
end

function Mod:CombatStart()
    self:ShowEntry("begin")
end

function Mod:CombatEnd()
    self:ShowEntry("end")
end

function Mod:UpdateAll()
    local db = self:GetDB()

    if not db.enabled then
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        if self.frame then
            self:StopTimers()
            self.frame:Hide()
        end
        return
    end

    self:CreateDisplay()
    self:ApplyStyle()

    self:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatStart")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "CombatEnd")

    self:StopTimers()
    self.frame:Hide()
end

function Mod:InitializeModule()
    self:UpdateAll()
end