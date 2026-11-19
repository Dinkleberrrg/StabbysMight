# Stabbys Might

A small WoW Classic 1.12 addon that shows **Blessing of Might** as **Stabbys Might** on your own screen
(and Greater Blessing of Might as Greater Stabbys Might).

It's cosmetic only. Other players still see Blessing of Might, and the real spell name stays the same for
macros (`/cast Blessing of Might`), Roid-Macros, simpleAuras and other addons.

## What gets renamed
- Tooltips: spellbook, action bars, buff icons (player, party, target, XPerl)
- ModernSpellBook and the default spellbook
- Chat messages, for example "You gain Stabbys Might."
- Tooltip descriptions: "Places a blessing on the stabbylike target, increasing stabby power by 20 for 5 min.
  Players may only have one stabby blessing on them per Paladin at any one time." (numbers come from the game)

## Install
Copy the `StabbysMight` folder into `Interface/AddOns` and restart the game.

## More renames
Edit the `RENAMES` table at the top of `StabbysMight.lua`.
