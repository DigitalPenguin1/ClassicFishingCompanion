# Classic Fishing Companion


A comprehensive fishing companion addon for World of Warcraft Classic Era and TBC. Features Easy Cast (double-click fishing with auto-lure), auto-swap combat weapons when attacked, gear set management, real-time Stats HUD, zone-based catch tracking with best hour statistics, detailed statistics, lure manager with missing lure warnings, rare fish sound alerts, milestone notifications, and automatic backups.


**Update 1/15/26** - Full TBC support released in v1.0.9! The addon now works seamlessly in both Classic Era and TBC with automatic version detection.


## Features

- **Easy Cast - Double-click fishing with automatic lure application**
  - Double right-click to cast with fishing pole equipped
  - Automatically applies selected lure when needed (no buff or buff expired)
- **Auto-Swap Combat Weapons** - Defend yourself when attacked while fishing!
  - If not casting when combat starts, weapons swap instantly
  - If actively fishing, a button appears to click to swap
  - When combat ends, auto-swaps back to your fishing pole
- **Comprehensive Tracking**: Records every fish caught with location, timestamp, and efficiency metrics
- **Stats HUD**: Draggable on-screen display showing session/total catches, fish/hour, skill level, and active lure with color-coded timer
- **Gear Sets**: Save and swap between fishing and combat equipment with one click
- **Lure Manager**: Select your preferred lure and apply it instantly with the HUD button (Classic Era) or create a macro for application (TBC - due to API restrictions)
- **Zones Tab**: Collapsible zone-based view showing all fish caught per zone with icons, counts, percentages, best fishing hour, and top fish
- **Detailed Statistics**: Catch list with fish/miscellaneous separation, top catches, zone productivity, skill progression, and buff/pole usage
- **Rich Tooltips**: Hover over catches to see detailed statistics, best hour of day, and location data
- **Per-Character Mode**: Optional per-character statistics tracking with account data copy option
- **Missing Lure Warnings**: Configurable on-screen alerts (30, 60, or 90 seconds) when fishing without a lure
- **Automatic Backup System**: Internal backups every 24 hours (stored in SavedVariables: `WTF\Account\[ACCOUNT_NAME]\[RandomNumberString]\SavedVariables\ClassicFishingCompanion.lua.bak`)
  - Export reminder shown every 7 days of play time, export reminders every 7 days, one-click restore
- **Minimap Button**: Quick access to UI (left-click), HUD toggle (right-click), and session stats (hover)
- **Customizable Settings**: Toggle features, lock HUD position, enable debug mode, and more


## Quick Start


1. Enable the addon
2. Click the minimap button or type `/cfc` to open the UI
3. Start fishing - all catches are tracked automatically
4. Use the Stats HUD for real-time information

**TBC Note**: In TBC, Blizzard blocked the API for applying lures directly. Click the HUD lure button to open Lure Manager, select your lure, then click "Update CFC_ApplyLure Macro" to create a macro. Drag the macro to your action bar and click it to apply lures.


## Commands


- `/cfc` - Open/close main UI
- `/cfc stats` - Print statistics to chat
- `/cfc reset` - Reset all data (with confirmation)
- `/cfc debug` - Toggle debug mode
- `/cfc minimap` - Toggle minimap button
- `/cfc savefishing` - Save current gear as fishing set
- `/cfc savecombat` - Save current gear as a combat set
- `/cfc swap` - Swap between fishing and combat gear


## Interface Tabs


### Overview
Current session and lifetime stats at a glance with the recent catches list.


### Catch List
All unique catches separated into Fish and Miscellaneous sections, sorted by count. Hover over items for detailed statistics, locations, and catch dates.


### Zones
Zone-based collapsible view of all fish caught. Click a zone to expand and see every fish species caught there with icons, catch counts, and percentages. Zone tooltips show first/last visit, top fish, and best fishing hour. Fish tooltips show total caught, caught in zone, best hour, and top locations.


### Statistics
- Fishing skill level and recent increases
- Fishing poles used and cast counts
- Lures/buffs applied and usage frequency
- Top 10 most caught fish
- Most productive fishing zones


### Gear Sets
Save and manage fishing and combat equipment. Equip your desired gear, click "Save Current Gear", then use the swap button to quickly switch between sets. Cannot swap during combat.


### Settings
- Show/hide minimap button and Stats HUD
- Lock/unlock HUD position
- **Per-Character Statistics**: Track each character separately or use account-wide tracking
- Enable/disable fish catch announcements
- Configure lure warning interval (30, 60, or 90 seconds)
- Enable/disable fishing skill increase announcements
- Debug mode
- Enable/disable automatic backups (creates backups every 24 hours in SavedVariables)
- Export/import data for backup or transfer
- Restore from automatic backup (one-click restore to last backup)
- Purge specific items from the database
- Clear all statistics


## Stats HUD


The HUD displays:
- **Session/Total**: Fish caught this session and lifetime
- **Fish/Hour**: Current fishing efficiency
- **Skill**: Fishing skill level (current/max) with pole bonus (green) and lure bonus (yellow) shown with dynamic icons
- **Lure**: Active lure with color-coded timer (🟢 >2min, 🟡 1-2min, 🔴 <1min)
- **Lure Button**: One-click button to apply selected lure to fishing pole (Classic Era) or open Lure Manager (TBC - due to API restrictions)
- **Swap Button**: Quick gear swap showing current mode (🎣 Fishing / ⚔️ Combat), protected during casting


**To move the HUD**: Click the lock icon (top-right) to unlock, drag to position, then lock again.


## Data Tracked


**Per Fish**: Name, timestamp, zone, sub-zone, coordinates, formatted date/time
**Additional**: Fishing skill progression, lures/buffs applied, fishing poles used


## Troubleshooting


| Issue | Solution |
|-------|----------|
| Fish not tracking | Enable addon in AddOns menu, use `/cfc debug` for details |
| Minimap button missing | Type `/cfc` or check Settings tab |
| Stats HUD not showing | Right-click minimap button or enable in Settings |
| Buff timer not showing | Apply a fishing lure to your pole |
| UI not showing | Check addon is enabled, try `/reload` |
| Data not saving | Exit WoW properly, check SavedVariables folder (`WTF\Account\[ACCOUNT_NAME]\SavedVariables\ClassicFishingCompanion.lua`) |


## Performance


Lightweight design with minimal impact:
- Only tracks events during fishing
- Efficient data storage
- HUD updates once per second
- No continuous scanning


## Version History


See [CHANGELOG.md](CHANGELOG.md) for detailed version history.


**Latest (v1.0.14)**: New Zones tab with collapsible zone-based fish tracking, best hour statistics, and percentage breakdowns.


## Support

## Transferring Data from Classic Era to TBC

**Important**: WoW must be completely closed (not just logged out) before copying files.

### Files to Copy
- **Account-level** (shared settings): `_classic_era_\WTF\Account\[ACCOUNT]\SavedVariables\ClassicFishingCompanion.lua`
- **Per-character** (fishing statistics): `_classic_era_\WTF\Account\[ACCOUNT]\[SERVER]\[CHARACTER]\SavedVariables\ClassicFishingCompanion.lua`

### Steps

1. **Close WoW completely** (Exit Game, not just log out)
2. **Copy both files** from your `_classic_era_` folder to the same paths in your `_anniversary_` folder
3. **Launch TBC** and log into your character

### If It Doesn't Work
- Make sure WoW was **completely closed** before copying
- Make sure you copied **both** files
- You must log into the character in TBC at least once first to create the folders


Issues or suggestions? Check Troubleshooting first, then report bugs at:
https://github.com/DigitalPenguin1/ClassicFishingCompanion/issues


## Credits


Created for World of Warcraft Classic
Uses embedded Ace3 libraries (Copyright © 2007, Ace3 Development Team)


## License


Free to use and modify for personal use.


**Happy Fishing!** 🎣