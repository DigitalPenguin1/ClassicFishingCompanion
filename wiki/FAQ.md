# FAQ

Answers to common questions and issues.

---

## Installation & Setup

**Q: The addon isn't showing up in my AddOns list.**
> Make sure the folder is named exactly `ClassicFishingCompanion` inside your `Interface\AddOns\` directory. If there's a version number in the folder name (e.g. `ClassicFishingCompanion-1.1.2`), rename it.

**Q: The minimap button is missing.**
> Type `/cfc minimap` to toggle it back on, or open the UI with `/cfc` and check the Settings tab.

**Q: The UI isn't opening.**
> Check that the addon is enabled on the character select screen (AddOns button, bottom-left). If it is, try `/reload` and then `/cfc`.

---

## Fishing & Tracking

**Q: Fish aren't being tracked.**
> Make sure you are actually fishing (casting with a fishing pole equipped). CFC requires a recent fishing cast before it records loot — items looted from ground objects or mobs while your pole is equipped will not be tracked.

**Q: A non-fish item is showing up in my catch list.**
> Use `/cfc debug` to check what's being detected, then [report it](https://github.com/DigitalPenguin1/ClassicFishingCompanion/issues/new/choose) so we can add it to the filter list.

**Q: My data disappeared after a patch or update.**
> Your data is stored in WoW's `SavedVariables` folder and should survive updates. If data is missing, check `WTF\Account\[ACCOUNT]\SavedVariables\ClassicFishingCompanion.lua` exists. You may also be able to restore from an auto-backup in the Settings tab.

---

## Lures & Easy Cast

**Q: Easy Cast isn't applying my lure.**
> Make sure:
> - Easy Cast is enabled in Settings
> - A lure is selected in the HUD lure dropdown
> - You have that lure in your bags
> - You are double right-clicking the bobber (not casting manually)

**Q: The HUD is showing the wrong lure name.**
> If you use two lures with the same fishing bonus (e.g. Sharpened Fish Hook and Aquadynamic Fish Attractor both give +100), make sure the correct lure is selected in the dropdown — CFC uses your selection as the source of truth when bonuses match.

**Q: I get an "Out of lure" message every cast.**
> The message is throttled to once per 10 minutes. If it's appearing more often, check your bags — you may genuinely be out of stock.

---

## Gear Sets

**Q: The auto-swap isn't working when I enter combat.**
> Make sure both a fishing set and combat set have been saved. See [[Gear Sets]] for setup instructions.

**Q: Swapping gear unequips my weapon but doesn't equip the right one.**
> Re-save your combat gear set with the correct weapon equipped: `/cfc savecombat`

---

## Catch & Release

**Q: The Release Fish keybind isn't working.**
> After binding the key, you must **fully restart WoW** (not just `/reload`) for it to take effect. This is a WoW limitation for new keybind categories.

**Q: I pressed the keybind but nothing happened.**
> The fish must have been caught and flagged for release first. Check that it's on your release list in the Release tab.

---

## Goals

**Q: My goals disappeared after a reload.**
> This is intended — goals are session-based and reset on each login or `/reload` so you can set fresh targets every fishing session. Your catch statistics are not affected.

---

## Still Having Issues?

[Open a Bug Report](https://github.com/DigitalPenguin1/ClassicFishingCompanion/issues/new/choose) and include your addon version, WoW client, and any debug output from `/cfc debug`.

---

*Back to [[Home]]*
