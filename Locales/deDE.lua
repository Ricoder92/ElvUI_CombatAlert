local E = unpack(ElvUI)
local PLUGIN = E:GetModule("ElvUI_CombatAlert", true)
if not PLUGIN then return end

local L = PLUGIN.L

L["CA_TITLE"] = "CombatAlert"
L["CA_TAB_COMBAT_IN_OUT"] = "Kampf Begin/Ende"

L["CA_ENABLED"] = "Modul aktivieren"
L["CA_FONT_HEADER"] = "Font (Begin + Ende)"
L["CA_FONT"] = "Font"
L["CA_FONT_SIZE"] = "Font Size"
L["CA_FONT_OUTLINE"] = "Outline"

L["CA_BEGIN_HEADER"] = "Kampf BEGIN"
L["CA_END_HEADER"] = "Kampf ENDE"

L["CA_TEXT"] = "Text"
L["CA_COLOR"] = "Farbe"
L["CA_HOLD_TIME"] = "Anzeigedauer (Sek.)"
L["CA_FADE_ENABLED"] = "FadeOut aktiv"
L["CA_FADE_TIME"] = "Fade Dauer (Sek.)"

L["CA_SOUND_ENABLED"] = "Sound aktiv"
L["CA_SOUND"] = "Sound"
L["CA_SOUND_CHANNEL"] = "Sound Channel"

L["CA_TEST_BEGIN"] = "Test BEGIN"
L["CA_TEST_END"] = "Test ENDE"

L["NONE"] = "None"

L["SOUND_CHANNEL_MASTER"] = "Master"
L["SOUND_CHANNEL_SFX"] = "SFX"
L["SOUND_CHANNEL_MUSIC"] = "Music"
L["SOUND_CHANNEL_AMBIENCE"] = "Ambience"
L["SOUND_CHANNEL_DIALOG"] = "Dialog"

L["OUTLINE_NONE"] = "None"
L["OUTLINE_OUTLINE"] = "Outline"
L["OUTLINE_THICK"] = "Thick Outline"
L["OUTLINE_MONO"] = "Mono Outline"
L["OUTLINE_OUTLINE_MONO"] = "Outline Mono"
L["OUTLINE_SHADOW"] = "Shadow"
L["OUTLINE_SHADOW_OUTLINE"] = "Shadow + Outline"
L["OUTLINE_SHADOW_THICK"] = "Shadow + Thick"

L["MOVER_COMBAT_IN_OUT"] = "Kampf Begin/Ende"
L["DEFAULT_COMBAT_BEGIN"] = "++ Kampf ++"
L["DEFAULT_COMBAT_END"] = "-- Kampf --"