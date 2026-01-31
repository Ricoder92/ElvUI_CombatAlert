local E, L, V, P, G = unpack(ElvUI)

local PLUGIN = E:NewModule("ElvUI_CombatAlert", "AceEvent-3.0")
PLUGIN.L = PLUGIN.L or {}

PLUGIN.MOVER_CATEGORY = "CombatAlert Modules"

function PLUGIN:TS(key, fallback)
    local L = self.L or {}
    return L[key] or fallback or key
end

local function CopyDeep(tbl)
    if type(tbl) ~= "table" then return tbl end
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = (type(v) == "table") and CopyDeep(v) or v
    end
    return t
end

local function MergeDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            MergeDefaults(dst[k], v)
        else
            if dst[k] == nil then dst[k] = v end
        end
    end
end

function PLUGIN:GetDB()
    E.db.ElvUI_CombatAlert = E.db.ElvUI_CombatAlert or {}
    return E.db.ElvUI_CombatAlert
end

function PLUGIN:Initialize()
    local defaults = {}

    for _, mod in pairs(self.modules) do
        if type(mod.GetDefaults) == "function" then
            local d = mod:GetDefaults()
            if type(d) == "table" then
                MergeDefaults(defaults, d)
            end
        end
    end

    local db = self:GetDB()
    MergeDefaults(db, CopyDeep(defaults))

    for _, mod in pairs(self.modules) do
        if type(mod.InitializeModule) == "function" then
            mod:InitializeModule()
        end
    end
end

E:RegisterModule(PLUGIN:GetName())