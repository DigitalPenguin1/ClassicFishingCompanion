# Classic Fishing Companion

A comprehensive fishing companion addon for World of Warcraft Classic Era and TBC.

## Features

- **Easy Cast** - Double right-click to cast; automatically applies lure when needed
- **Auto-Swap Combat Weapons** - Swaps to combat gear when attacked, back to fishing when combat ends
- **Stats HUD** - Draggable display with session/total catches, fish/hour, skill, and lure timer
- **Zones Tab** - Collapsible zone-based view of all fish caught with icons, counts, and tooltips
- **Gear Sets** - Save and swap between fishing and combat equipment
- **Lure Manager** - Select and apply lures from the HUD
- **Catch List & Statistics** - Detailed tracking with fish/misc separation, top catches, and zone productivity
- **Rare Fish Alerts** - Sound notification when you catch a rare fish
- **Milestone Notifications** - Celebrate catch milestones
- **Missing Lure Warnings** - On-screen alerts when fishing without a lure
- **Automatic Backups** - Internal backups every 24 hours with one-click restore
- **Per-Character Mode** - Optional per-character stats with account data copy
- **Keybinding Support** - Bind keys via Escape > Options > KeyBindings
- **Minimap Button** - Left-click UI, right-click HUD, hover for stats

## Quick Start

1. Enable the addon
2. Click the minimap button or type `/cfc` to open the UI
3. Start fishing - all catches are tracked automatically

## Commands

- `/cfc` - Open/close main UI
- `/cfc hud` - Toggle Stats HUD (includes gear swap if enabled)
- `/cfc stats` - Print statistics to chat
- `/cfc reset` - Reset all data (with confirmation)
- `/cfc debug` - Toggle debug mode
- `/cfc minimap` - Toggle minimap button
- `/cfc savefishing` / `/cfc savecombat` - Save current gear as fishing/combat set
- `/cfc swap` - Swap between fishing and combat gear

## Troubleshooting & Support

| Issue | Solution |
|-------|----------|
| Fish not tracking | Enable addon in AddOns menu, use `/cfc debug` for details |
| Minimap button missing | Type `/cfc` or check Settings tab |
| Stats HUD not showing | Right-click minimap button or `/cfc hud` |
| UI not showing | Check addon is enabled, try `/reload` |
| Data not saving | Exit WoW properly, check `WTF\Account\[NAME]\SavedVariables\` |

**Debug tip**: Use `/cfc debug` to enable debug logging. To copy debug output from chat, install [Chat Copy Paste](https://www.curseforge.com/wow/addons/chat-copy-paste).

**Issues or suggestions** Report bugs at:

https://github.com/DigitalPenguin1/ClassicFishingCompanion/issues

## Transferring Data from Classic Era to TBC

1. **Close WoW completely** (Exit Game, not just log out)
2. Copy both files from `_classic_era_` to the same paths in `_anniversary_`:
   - `WTF\Account\[ACCOUNT]\SavedVariables\ClassicFishingCompanion.lua`
   - `WTF\Account\[ACCOUNT]\[SERVER]\[CHARACTER]\SavedVariables\ClassicFishingCompanion.lua`
3. Launch TBC and log into your character

## Version History

See [CHANGELOG.md] for detailed version history.

## Credits

Created for World of Warcraft Classic. Uses embedded Ace3 libraries (Copyright 2007, Ace3 Development Team).

Free to use and modify for personal use.

**Happy Fishing!** 🎣