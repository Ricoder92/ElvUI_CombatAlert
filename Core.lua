local E, L, V, P, G = unpack(ElvUI)

local PLUGIN = E:NewModule("ElvUI_CombatAlert", "AceEvent-3.0")

-- Locale table owned by this plugin
PLUGIN.L = PLUGIN.L or {}

-- Custom mover category name (shows as category in /moveui)
PLUGIN.MOVER_CATEGORY = "CombatAlert Modules"

-- ------------------------------------------------------------
-- Localization helper
-- ------------------------------------------------------------
function PLUGIN:TS(key, fallback)
    local LT = self.L or {}
    return LT[key] or fallback or key
end

-- ------------------------------------------------------------
-- Table helpers (deep copy + merge defaults)
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- DB root for this plugin (ElvUI profile DB)
-- ------------------------------------------------------------
function PLUGIN:GetDB()
    E.db.ElvUI_CombatAlert = E.db.ElvUI_CombatAlert or {}
    return E.db.ElvUI_CombatAlert
end

-- ------------------------------------------------------------
-- Profile callbacks (new profile / reset / copy / change)
-- We re-merge defaults and ask all modules to UpdateAll()
-- ------------------------------------------------------------
function PLUGIN:ApplyDefaultsAndUpdate()
    -- collect defaults from all sub-modules
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

    -- update modules
    for _, mod in pairs(self.modules) do
        if type(mod.UpdateAll) == "function" then
            mod:UpdateAll()
        elseif type(mod.InitializeModule) == "function" then
            -- fallback for modules that only implement InitializeModule
            mod:InitializeModule()
        end
    end
end

function PLUGIN:OnProfileChanged()
    -- ensure DB has defaults on fresh profile + update all modules
    self:ApplyDefaultsAndUpdate()
end

-- ------------------------------------------------------------
-- Initialize
-- ------------------------------------------------------------
function PLUGIN:Initialize()
    -- 1) Merge defaults into current profile DB (important for new profiles)
    self:ApplyDefaultsAndUpdate()

    -- 2) Hook ElvUI's profile change callbacks (AceDB)
    -- E.data is the AceDB instance ElvUI uses. This is the most reliable way.
    if E.data and E.data.RegisterCallback then
        E.data:RegisterCallback("OnProfileChanged", function() self:OnProfileChanged() end)
        E.data:RegisterCallback("OnProfileCopied", function() self:OnProfileChanged() end)
        E.data:RegisterCallback("OnProfileReset", function() self:OnProfileChanged() end)
        E.data:RegisterCallback("OnProfileNew", function() self:OnProfileChanged() end)
    elseif E.db and E.db.RegisterCallback then
        -- fallback (some builds expose callbacks on E.db)
        E.db:RegisterCallback("OnProfileChanged", function() self:OnProfileChanged() end)
        E.db:RegisterCallback("OnProfileCopied", function() self:OnProfileChanged() end)
        E.db:RegisterCallback("OnProfileReset", function() self:OnProfileChanged() end)
        E.db:RegisterCallback("OnProfileNew", function() self:OnProfileChanged() end)
    end
end

E:RegisterModule(PLUGIN:GetName())