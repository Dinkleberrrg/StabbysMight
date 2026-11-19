-- Stabbys Might: cosmetic rename, only changes text you see on your own screen.
-- Spell names used by the game, macros and other addons (simpleAuras, Roid-Macros,
-- /cast ...) are NOT touched, so everything keeps working with the real name.

-- Add more renames here if you like: ["Real name"] = "Shown name"
-- (Greater Blessing of Might automatically becomes "Greater Stabbys Might".)
local RENAMES = {
  ["Blessing of Might"] = "Stabbys Might",
}

local function Rename(text)
  if type(text) ~= "string" then return text end
  for from, to in pairs(RENAMES) do
    if string.find(text, from, 1, true) then
      text = string.gsub(text, from, to)
    end
  end
  return text
end

local function FixFontString(fs)
  if not fs then return end
  local t = fs:GetText()
  if t then
    local n = Rename(t)
    if n ~= t then fs:SetText(n) end
  end
end

----------------------------------------------------------------------
-- Tooltips (spellbook, action bars, buffs on you / party / target)
----------------------------------------------------------------------
local function FixTooltip(tt)
  local name = tt:GetName()
  local lines = tt:NumLines() or 0
  for i = 1, lines do
    FixFontString(getglobal(name .. "TextLeft" .. i))
    FixFontString(getglobal(name .. "TextRight" .. i))
  end
end

local SET_METHODS = {
  "SetSpell", "SetAction", "SetPetAction", "SetShapeshift",
  "SetUnitBuff", "SetUnitDebuff", "SetPlayerBuff",
  "SetTrainerService", "SetCraftSpell", "SetHyperlink",
}

local function HookTooltip(tt)
  if not tt or tt.StabbysMightHooked then return end
  tt.StabbysMightHooked = true

  for _, m in ipairs(SET_METHODS) do
    local orig = tt[m]
    if orig then
      tt[m] = function(self, a1, a2, a3, a4, a5)
        local r1, r2, r3, r4 = orig(self, a1, a2, a3, a4, a5)
        FixTooltip(self)
        return r1, r2, r3, r4
      end
    end
  end

  -- Addons that write their own tooltip text (ModernSpellBook, XPerl, ...)
  local origSetText = tt.SetText
  tt.SetText = function(self, text, a2, a3, a4, a5, a6)
    return origSetText(self, Rename(text), a2, a3, a4, a5, a6)
  end
  local origAddLine = tt.AddLine
  tt.AddLine = function(self, text, a2, a3, a4, a5)
    return origAddLine(self, Rename(text), a2, a3, a4, a5)
  end
  local origAddDouble = tt.AddDoubleLine
  tt.AddDoubleLine = function(self, l, r, a3, a4, a5, a6, a7, a8)
    return origAddDouble(self, Rename(l), Rename(r), a3, a4, a5, a6, a7, a8)
  end
end

----------------------------------------------------------------------
-- Chat ("You gain Stabbys Might.") - display only, combat log events
-- that addons read are unchanged.
----------------------------------------------------------------------
local function HookChatFrame(cf)
  if not cf or cf.StabbysMightHooked then return end
  cf.StabbysMightHooked = true
  local orig = cf.AddMessage
  cf.AddMessage = function(self, text, a2, a3, a4, a5, a6)
    return orig(self, Rename(text), a2, a3, a4, a5, a6)
  end
end

----------------------------------------------------------------------
-- Spellbooks
----------------------------------------------------------------------
local function HookDefaultSpellbook()
  if not SpellButton_UpdateButton or StabbysMight_SBHooked then return end
  StabbysMight_SBHooked = true
  local orig = SpellButton_UpdateButton
  SpellButton_UpdateButton = function(a1, a2, a3)
    orig(a1, a2, a3)
    FixFontString(getglobal(this:GetName() .. "SpellName"))
  end
end

local function HookModernSpellBook()
  if not CSpellItem or not CSpellItem.SetTextContent or CSpellItem.StabbysMightHooked then return end
  CSpellItem.StabbysMightHooked = true
  local orig = CSpellItem.SetTextContent
  CSpellItem.SetTextContent = function(self, spellInfo)
    orig(self, spellInfo)
    FixFontString(self.nameText)
  end
end

----------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function()
  HookModernSpellBook()
  if event == "PLAYER_LOGIN" then
    HookTooltip(GameTooltip)
    HookTooltip(ItemRefTooltip)
    for i = 1, NUM_CHAT_WINDOWS or 7 do
      HookChatFrame(getglobal("ChatFrame" .. i))
    end
    HookDefaultSpellbook()
  end
end)
