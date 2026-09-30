# Changelog

For the full detailed changelog, see [CHANGELOG.md](https://github.com/DigitalPenguin1/ClassicFishingCompanion/blob/main/CHANGELOG.md) on GitHub.

---

## Recent Versions

### v1.2.3
Forever-only update; Classic Era and TBC only get a colored name in the AddOns list.
- **Forever** - Tabs are icons down the right side of the window, with the tab name on hover
- **Forever** - Gear sets use the game's Equipment Manager (a set named "Fishing"), stored by the server so restarts can't wipe them
- **Forever** - Pick which set to swap back to; the default "CFC Normal" is saved from what you're wearing each time you swap to fishing
- **Forever** - Larger window title with the Forever logo; AddOns list name is now "Classic Fishing Companion - Forever"
- **Forever** - Double right-clicking a mob no longer applies your lure, and the combat weapon swap no longer triggers "Interface action failed"
- **Forever** - HUD no longer leaves a gap above its buttons when no lure is active

### v1.2.2
Forever-only update; Classic Era and TBC are unchanged.
- **Forever** - HUD Skill line shows fishing bonus from gear other than your pole and lure as its own +N badge
- **Forever** - HUD lure countdown bar behind Time Left, red in the last minute
- **Forever** - Recent Catches rows with icon, zone and time ago; quality-colored icon borders; new progress bar look; modern dropdowns and scrollbars
- **Forever** - Fish without a known fish word in the name now sort under Fish in the Catch List and show in the Zones tab
- **Forever** - Fixed a Lua error on the Zones tab and the Statistics tab scrolling past its content

### v1.2.1
- HUD swap button shows gauntlets instead of a sword when swapping back to your normal gear, since your normal set might be healing or caster gear
- **Forever** - HUD and all windows now use gold and bronze to match the Forever action bar
- **Forever** - Classic Fishing Companion is listed in the addon list next to the minimap (left-click opens the window, right-click toggles the HUD). Hide the minimap icon in Settings if you only want one
- **Forever** - New page under Esc > Options > AddOns to open the main window or its Settings
- **Forever** - HUD Apply Lure button now applies your lure

### v1.2.0
- **World of Warcraft: Forever support (beta testing)** - loaded by its own TOC; Classic Era and TBC are unchanged
- HUD **Setup** button opens the Gear Sets tab when no fishing set is saved
- Your normal gear is remembered automatically when you save a fishing set while already wearing it
- Double right-click no longer tries to cast Fishing without a fishing pole equipped
- HUD gear button matches the gear you're wearing at login, even after logging out mid-swap
- Saving your fishing set while wearing it updates the HUD right away
- **Forever beta known issue:** the client doesn't load addon saved data after a restart, so catches and settings reset. This is a Blizzard bug

### v1.1.13
- Fishing totals no longer count loot from other sources — mob loot, gathering, and containers opened from your bags are no longer recorded as catches ([#19](https://github.com/DigitalPenguin1/ClassicFishingCompanion/issues/19))
- Fishing pole cast counts are no longer inflated by non-fishing loot
- Catches now track correctly with fast auto-loot addons
- Right-click any item in the Catch List to purge it from your database
- New **Recalculate Totals** button in Settings (`/cfc recalc`) recounts your totals from your catch history
- Updated for Classic Era 1.15.9

### v1.1.12
- **TBC** - Sharpened Fish Hook now shows by name on the HUD (named from your selected lure) instead of always as Aquadynamic Fish Attractor — both share the same +100 weapon enchant and an identical pole tooltip
- HUD grows taller when a long lure name wraps to a second line, so the lure timer no longer falls outside the frame
- HUD grows wider when the Captain Rumsey's Lager +10 bonus is shown, so the skill line no longer runs off the edge

### v1.1.2
- Fixed tooltip flickering when swapping to fishing gear — lure detection now uses enchant ID lookup instead of tooltip scanning
- Added console warning when Easy Cast cannot apply a lure due to being out of stock (shown max once per 10 minutes)

### v1.1.1
- Fixed Sharpened Fish Hook ID and Easy Cast support
- Fixed HUD showing wrong lure name for same-bonus lures

### v1.1.0
- Fixed Sharpened Fish Hook ID (corrected to 34861)
- Fixed HUD wrong lure name for same-bonus lures
- Fixed Easy Cast not recognizing Sharpened Fish Hook

### v1.0.18
- Added **Goals Tab** — session-based catch goals with HUD progress tracking
- Added **Catch & Release Tab** — delete unwanted fish via keybind
- Added **Release Fish keybind** in Key Bindings menu
- Two-row tab layout to fit new tabs
- Fish dropdowns sorted alphabetically
- Smarter fish detection — non-fish items filtered from lists
- HUD dynamically scales height based on active goals
- Loot detection now requires a recent fishing cast

### v1.0.17
- Reduced debug output noise
- Updated minimap icon

### v1.0.16
- Added **Keybinding Support** — Toggle HUD and Toggle UI keybinds
- Added `/cfc hud` command
- Added TBC fish detection (crawdad, darter, feltail, crocolisk)
- Added Nat Pagle quest fish detection (ahi, striker, sailfin)
- Added addon icon for TBC addon list

---

*View the full history on [GitHub](https://github.com/DigitalPenguin1/ClassicFishingCompanion/blob/main/CHANGELOG.md)*

*Back to [[Home]]*
