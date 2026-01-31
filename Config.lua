local E, _, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")

local PLUGIN = E:GetModule("ElvUI_CombatAlert", true)
if not PLUGIN then return end

local L = PLUGIN.L or {}
local function T(key, fallback)
    return L[key] or fallback or key
end

-- ----------------------------------------
-- Localized helpers
-- ----------------------------------------
local function T(key)
    return (L and L[key]) or key
end

local function SoundValues()
    local t = { ["None"] = T("NONE") }
    local sounds = E.LSM and E.LSM:HashTable("sound") or {}
    for k, v in pairs(sounds) do
        t[k] = v
    end
    return t
end

local function SoundChannelValues()
    return {
        ["Master"]   = T("SOUND_CHANNEL_MASTER"),
        ["SFX"]      = T("SOUND_CHANNEL_SFX"),
        ["Music"]    = T("SOUND_CHANNEL_MUSIC"),
        ["Ambience"] = T("SOUND_CHANNEL_AMBIENCE"),
        ["Dialog"]   = T("SOUND_CHANNEL_DIALOG"),
    }
end

local function OutlineValues()
    return {
        ["NONE"]              = T("OUTLINE_NONE"),
        ["OUTLINE"]           = T("OUTLINE_OUTLINE"),
        ["THICKOUTLINE"]      = T("OUTLINE_THICK"),
        ["MONOCHROMEOUTLINE"] = T("OUTLINE_MONO"),
        ["OUTLINEMONOCHROME"] = T("OUTLINE_OUTLINE_MONO"),

        ["SHADOW"]            = T("OUTLINE_SHADOW"),
        ["SHADOWOUTLINE"]     = T("OUTLINE_SHADOW_OUTLINE"),
        ["SHADOWTHICKOUTLINE"]= T("OUTLINE_SHADOW_THICK"),
    }
end

local function InsertOptions()
    local PLUGIN = E:GetModule("ElvUI_CombatAlert", true)
    local Mod = PLUGIN and PLUGIN:GetModule("CombatInOut", true)
    if not PLUGIN or not Mod then return end

    local function DB()
        E.db.ElvUI_CombatAlert = E.db.ElvUI_CombatAlert or {}
        E.db.ElvUI_CombatAlert[Mod.DB_KEY] = E.db.ElvUI_CombatAlert[Mod.DB_KEY] or {}
        return E.db.ElvUI_CombatAlert[Mod.DB_KEY]
    end

    local function Entry(which)
        local db = DB()
        db[which] = db[which] or {}
        return db[which]
    end

    E.Options.args.ElvUI_CombatAlert = {
        order = 200,
        type = "group",
        name = T("CA_TITLE"),
        childGroups = "tab",
        args = {
            combatInOut = {
                order = 1,
                type = "group",
                name = T("CA_TAB_COMBAT_IN_OUT"),
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = T("CA_ENABLED"),
                        get = function() return DB().enabled end,
                        set = function(_, v)
                            DB().enabled = v
                            Mod:UpdateAll()
                        end,
                    },

                    headerFont = {
                        order = 10,
                        type = "header",
                        name = T("CA_FONT_HEADER"),
                    },

                    font = {
                        order = 11,
                        type = "select",
                        name = T("CA_FONT"),
                        dialogControl = "LSM30_Font",
                        values = function() return E.LSM:HashTable("font") end,
                        get = function() return DB().font end,
                        set = function(_, v)
                            DB().font = v
                            Mod:ApplyStyle()
                        end,
                    },

                    fontSize = {
                        order = 12,
                        type = "range",
                        name = T("CA_FONT_SIZE"),
                        min = 8, max = 72, step = 1,
                        get = function() return DB().fontSize end,
                        set = function(_, v)
                            DB().fontSize = v
                            Mod:ApplyStyle()
                        end,
                    },

                    fontOutline = {
                        order = 13,
                        type = "select",
                        name = T("CA_FONT_OUTLINE"),
                        values = OutlineValues,
                        get = function() return DB().fontOutline end,
                        set = function(_, v)
                            DB().fontOutline = v
                            Mod:ApplyStyle()
                        end,
                    },

                    -- -----------------------
                    -- BEGIN
                    -- -----------------------
                    headerBegin = { order = 20, type = "header", name = T("CA_BEGIN_HEADER") },

                    beginText = {
                        order = 21,
                        type = "input",
                        width = "full",
                        name = T("CA_TEXT"),
                        get = function() return Entry("begin").text end,
                        set = function(_, v) Entry("begin").text = v end,
                    },

                    beginColor = {
                        order = 22,
                        type = "color",
                        name = T("CA_COLOR"),
                        hasAlpha = true,
                        get = function()
                            local c = Entry("begin").color or {}
                            return c.r or 1, c.g or 1, c.b or 1, c.a or 1
                        end,
                        set = function(_, r, g, b, a)
                            local e = Entry("begin")
                            e.color = e.color or {}
                            e.color.r, e.color.g, e.color.b, e.color.a = r, g, b, a
                        end,
                    },

                    beginHold = {
                        order = 23,
                        type = "range",
                        name = T("CA_HOLD_TIME"),
                        min = 0, max = 10, step = 0.1,
                        get = function() return Entry("begin").holdTime end,
                        set = function(_, v) Entry("begin").holdTime = v end,
                    },

                    beginFadeEnabled = {
                        order = 24,
                        type = "toggle",
                        name = T("CA_FADE_ENABLED"),
                        get = function() return Entry("begin").fadeEnabled end,
                        set = function(_, v) Entry("begin").fadeEnabled = v end,
                    },

                    beginFade = {
                        order = 25,
                        type = "range",
                        name = T("CA_FADE_TIME"),
                        min = 0.05, max = 10, step = 0.1,
                        disabled = function() return Entry("begin").fadeEnabled == false end,
                        get = function() return Entry("begin").fadeTime end,
                        set = function(_, v) Entry("begin").fadeTime = v end,
                    },

                    beginSoundEnabled = {
                        order = 27,
                        type = "toggle",
                        name = T("CA_SOUND_ENABLED"),
                        get = function() return Entry("begin").soundEnabled end,
                        set = function(_, v) Entry("begin").soundEnabled = v end,
                    },

                    beginSound = {
                        order = 28,
                        type = "select",
                        name = T("CA_SOUND"),
                        dialogControl = "LSM30_Sound",
                        values = SoundValues,
                        disabled = function() return not Entry("begin").soundEnabled end,
                        get = function() return Entry("begin").sound or "None" end,
                        set = function(_, v) Entry("begin").sound = v end,
                    },

                    beginSoundChannel = {
                        order = 29,
                        type = "select",
                        name = T("CA_SOUND_CHANNEL"),
                        values = SoundChannelValues,
                        disabled = function() return not Entry("begin").soundEnabled end,
                        get = function() return Entry("begin").soundChannel or "Master" end,
                        set = function(_, v) Entry("begin").soundChannel = v end,
                    },

                    beginTest = {
                        order = 26,
                        type = "execute",
                        name = T("CA_TEST_BEGIN"),
                        func = function() Mod:ShowEntry("begin") end,
                    },

                    -- -----------------------
                    -- END
                    -- -----------------------
                    headerEnd = { order = 30, type = "header", name = T("CA_END_HEADER") },

                    endText = {
                        order = 31,
                        type = "input",
                        width = "full",
                        name = T("CA_TEXT"),
                        get = function() return Entry("end").text end,
                        set = function(_, v) Entry("end").text = v end,
                    },

                    endColor = {
                        order = 32,
                        type = "color",
                        name = T("CA_COLOR"),
                        hasAlpha = true,
                        get = function()
                            local c = Entry("end").color or {}
                            return c.r or 1, c.g or 1, c.b or 1, c.a or 1
                        end,
                        set = function(_, r, g, b, a)
                            local e = Entry("end")
                            e.color = e.color or {}
                            e.color.r, e.color.g, e.color.b, e.color.a = r, g, b, a
                        end,
                    },

                    endHold = {
                        order = 33,
                        type = "range",
                        name = T("CA_HOLD_TIME"),
                        min = 0, max = 10, step = 0.1,
                        get = function() return Entry("end").holdTime end,
                        set = function(_, v) Entry("end").holdTime = v end,
                    },

                    endFadeEnabled = {
                        order = 34,
                        type = "toggle",
                        name = T("CA_FADE_ENABLED"),
                        get = function() return Entry("end").fadeEnabled end,
                        set = function(_, v) Entry("end").fadeEnabled = v end,
                    },

                    endFade = {
                        order = 35,
                        type = "range",
                        name = T("CA_FADE_TIME"),
                        min = 0.05, max = 10, step = 0.1,
                        disabled = function() return Entry("end").fadeEnabled == false end,
                        get = function() return Entry("end").fadeTime end,
                        set = function(_, v) Entry("end").fadeTime = v end,
                    },

                    endSoundEnabled = {
                        order = 37,
                        type = "toggle",
                        name = T("CA_SOUND_ENABLED"),
                        get = function() return Entry("end").soundEnabled end,
                        set = function(_, v) Entry("end").soundEnabled = v end,
                    },

                    endSound = {
                        order = 38,
                        type = "select",
                        name = T("CA_SOUND"),
                        dialogControl = "LSM30_Sound",
                        values = SoundValues,
                        disabled = function() return not Entry("end").soundEnabled end,
                        get = function() return Entry("end").sound or "None" end,
                        set = function(_, v) Entry("end").sound = v end,
                    },

                    endSoundChannel = {
                        order = 39,
                        type = "select",
                        name = T("CA_SOUND_CHANNEL"),
                        values = SoundChannelValues,
                        disabled = function() return not Entry("end").soundEnabled end,
                        get = function() return Entry("end").soundChannel or "Master" end,
                        set = function(_, v) Entry("end").soundChannel = v end,
                    },

                    endTest = {
                        order = 36,
                        type = "execute",
                        name = T("CA_TEST_END"),
                        func = function() Mod:ShowEntry("end") end,
                    },
                },
            },
        },
    }
end

EP:RegisterPlugin("ElvUI_CombatAlert", InsertOptions)