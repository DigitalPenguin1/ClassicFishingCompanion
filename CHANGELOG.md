# Changelog

All notable changes to Classic Fishing Companion will be documented in this file.

## [1.1.5] - 2026-02-25

### Milestone
- 10,000 downloads! Thank you to the Classic fishing community for your support!

## [1.1.4] - 2026-02-21

### Improved
- Tooltip flicker eliminated — shift-comparing items in bags no longer causes the equipped item tooltip to flash every second while HUD is visible
- Lure statistics now show proper lure names (e.g. "Bright Baubles") instead of generic "Fishing Lure +75" — existing stats are automatically merged on update
- Minimap icon background now matches the addon logo
- Catch & Release notifications now appear as a brief HUD indicator instead of chat messages
- Welcome message displays after a short delay on login/reload
- Easy Cast now allows recasting while your line is already out — useful for repositioning your lure in fish pools

## [1.1.3] - 2026-02-20

### Improved
- Gear Sets tab redesigned with toggle view — switch between combat and fishing sets with full-width item display instead of cramped side-by-side columns
- Gear swap no longer corrupts saved sets — removed auto-save that was overwriting gear data with partially-swapped equipment
- Fishing pole validation — swapping to fishing gear is blocked if your fishing pole is missing from bags and equipment, preventing incomplete swaps
- HUD no longer toggles when gear swap fails — if auto-swap on HUD is enabled and the swap is blocked, the HUD stays in its current state
- Easy Cast camera handling — binding is no longer set during active fishing channel, preventing brief camera lock when clicking swap button during combat
- Easy Cast pre-combat detection — binding clears before combat lockdown using UnitAffectingCombat check
- Quick recast after missed fish — double right-click now works immediately after a missed catch instead of requiring an extra click

## [1.1.2] - 2026-02-18

### Fixed
- Fixed tooltip flashing when swapping to fishing gear — lure detection now uses enchant ID lookup instead of tooltip scanning, eliminating the once-per-second tooltip refresh that caused flickering
- Added console warning when Easy Cast cannot apply a lure because you're out of stock — shown at most once every 10 minutes to avoid spam

## [1.1.1] - 2026-02-17

### Fixed
- Fixed Sharpened Fish Hook ID and Easy Cast support — lure now applies correctly via Easy Cast
- Fixed HUD showing wrong lure name for same-bonus lures (e.g. Sharpened Fish Hook showing as Aquadynamic Fish Attractor)

## [1.1.0] - 2026-02-17

### Fixed
- Fixed Sharpened Fish Hook ID (was 3486, corrected to 34861) — lure now properly applies with Easy Cast and detected on fishing pole
- Fixed HUD showing wrong lure name for same-bonus lures (e.g. Sharpened Fish Hook showing as Aquadynamic Fish Attractor) — HUD now uses selected lure as source of truth when bonus matches
- Fixed Easy Cast not recognizing Sharpened Fish Hook — added to lure name table so macro builds correctly

## [1.0.18] - 2026-02-16

### Added
- **Goals Tab** - Set session-based catch goals for specific fish
  - Pick a fish from the dropdown, set a target count, and track progress with visual progress bars
  - Active goals display on the HUD with color-coded progress (yellow at 75%, green on completion)
  - Goals reset each session (login/reload) so you can set fresh targets every time you fish
  - Up to 3 goals shown on HUD simultaneously
- **Catch & Release Tab** - Mark fish for deletion via keybind
  - Select fish to add to your release list
  - When you catch a fish on the list, press your Release Fish keybind to delete it from bags
  - Catches still count in your statistics
  - Keybind setup: ESC > Settings > Key Bindings > Classic Fishing Companion > Release Fish
- **Release Fish keybind** in Key Bindings menu
- **Two-row tab layout** to accommodate new Goals and Release tabs

### Improved
- Fish dropdowns in Goals and Release tabs sorted alphabetically
- Smarter fish detection — non-fish items (Discarded Nutriment, Glowcap) filtered from catch lists and dropdowns
- HUD dynamically scales height based on active goal count
- Loot detection now requires a recent Fishing cast — looting ground objects with a pole equipped no longer creates false catches

### Fixed
- Fixed HUD backdrop rendering on top of text and buttons (frame level ordering)
- Fixed non-fish items appearing in the Fish section of the catch list

## [1.0.17] - 2026-02-10

### Improved
- Reduced debug output noise for cleaner logging, Updated minimap icon to match curseforge page logo. 

## [1.0.16] - 2026-02-09

### Added
- **Keybinding Support** - Bind keys to Toggle Fishing HUD and Toggle Fishing UI
  - Custom "Classic Fishing Companion" section in WoW Key Bindings menu
  - Toggle HUD keybind includes auto-swap gear if enabled
- **`/cfc hud` command** - Toggle the Stats HUD from chat (includes gear swap if enabled)
- **TBC Fish Detection** - Added keywords for TBC fish: crawdad, darter, feltail, crocolisk
- **Nat Pagle Quest Fish Detection** - Added keywords: ahi, striker, sailfin
- **Addon Icon** - Fishing icon now shows in TBC addon list

### Fixed
- Fixed Barbed Gill Trout showing as misc instead of fish ("bar" in miscKeywords matched "Barbed")
- Fixed What's New dialog crash from unescaped %% in SetFormattedText

## [1.0.15] - 2026-02-05
- Bug Fixes for TBC.

## [1.0.14] - 2026-02-03

### Added
- **Zones Tab** - Redesigned History tab into a zone-based collapsible view
  - Click any zone to expand and see all fish caught there with icons and counts
  - Zone headers show total fish, unique species, and % of total catches
  - Fish entries show catch count and % of zone catches
  - Zone tooltip: first/last visit dates, top fish, and best fishing hour
  - Fish tooltip: total caught, caught in zone, first/last date, best hour, top 5 locations
  - Only fish are shown (chests, lockboxes, gear, etc. are filtered out)
- **Best Hour statistics** on all fish tooltips across Zones and Catch List tabs
  - Shows the hour of day when you've caught the most of each fish
  - Helps identify AM vs PM fish spawns

## [1.0.13] - 2026-01-27

### Added
- **Auto-Swap Combat Weapons** - Automatically swap to combat weapons when attacked while fishing!
  - If not casting when combat starts, weapons swap instantly
  - If actively fishing, a "COMBAT! Click to Swap" button appears
  - When combat ends, automatically swaps back to your fishing pole
  - Enable in Settings under the Easy Cast section
  - Requires combat gear set to be saved (`/cfc savecombat`)

## [1.0.12] - 2026-01-21

### Fixed
- Fixed gear swapper not equipping both weapons when dual-wielding identical one-handed weapons
  - Main hand is now always processed before off-hand
  - Tracks used bag slots to prevent picking the same item twice

## [1.0.11] - 2026-01-19

### Added
- **Easy Cast - Double-click fishing with automatic lure application**
  - Double right-click to cast with fishing pole equipped
  - Automatically applies selected lure when needed (no buff or buff expired)
  - No more macros needed - Easy Cast handles everything
  - Works safely with combat (clears binding state when entering/leaving combat)
  - Blocked when loot windows or confirmation dialogs are open
- **Rare fish sound notification**
  - Plays a sound when catching rare fish (Brownell's Blue Striped Racer, Dezian Queenfish, Keefer's Angelfish, Mr. Pinchy, Feralas Ahi, Misty Reed Mahi Mahi, Sar'theris Striker, Savage Coast Blue Sailfin)
  - Test with `/cfc testsound` command
- **Easy Cast status indicator on Lure tab**
  - Shows "Enabled" (green) or "Disabled" (red) with helpful hints
- **Settings tab reorganized into sections**
  - General, Announcements, HUD Settings, Easy Cast, Advanced, Data Management
  - Easier navigation with section headers and separator lines

### Fixed
- Fixed mob loot being tracked as fish catches during combat
  - Combat now resets the fishing cast timer to prevent false tracking
- Fixed Easy Cast interfering with combat actions
  - Binding state is cleared when entering combat and after leaving combat
- Loot windows now properly block Easy Cast recasting
  - Prevents accidental casts when BoP confirmation dialogs are open
- Purge button now works with lure usage statistics (case-insensitive matching)

## [1.0.10] - 2026-01-15

### Added
- **Auto-Swap Gear on HUD Toggle**
  - New option in Settings to automatically swap gear when toggling the HUD via minimap right-click
  - Right-click minimap to show HUD → automatically equips fishing gear
  - Right-click minimap to hide HUD → automatically equips combat gear
  - Shows warning if gear sets are not configured

## [1.0.9] - 2026-01-08

### Added
- **Full TBC (The Burning Crusade) support**
  - Separate TBC-specific UI and HUD files loaded via ClassicFishingCompanion_TBC.toc
  - Macro-based lure application system for TBC (workaround for Blizzard's API restrictions)
  - "Update CFC_ApplyLure Macro" button in Lure Manager creates/updates a macro for lure application
  - Dynamic lure icon on HUD button that changes based on selected lure
  - Max fishing skill announcement updated to 375 for TBC
  - All v1.0.8 features (Catch List, tooltips, per-character stats, gear swap) work in both Classic Era and TBC

### Fixed
- Fixed lure detection not working in TBC
  - Updated tooltip pattern matching to support TBC's format: "Fishing Lure (+25 Fishing Skill) (10 min)"
  - Classic Era format still supported: "Fishing Lure +25"
  - Applied fix to both HUD lure display and missing lure warnings
- Fixed per-character mode "Cancel" button doing nothing in TBC
  - Now properly shows "Start Fresh?" confirmation dialog when clicked
- Fixed missing lure warnings showing even when lure is applied in TBC
- Fixed Statistics tab layout overlapping in TBC
  - "Fishing Poles Used" and other sections were overlapping with the graph bars
  - Created properly positioned text area below the graph containers

### Changed
- Shared Core.lua, Database.lua, and Minimap.lua files work across both Classic Era and TBC
- Version detection added to Core.lua (WOW_PROJECT_ID: 2 = Classic Era, 5 = TBC)
- SavedVariables automatically transfer from Classic Era to TBC when characters move

## [1.0.8] - 2025-12-15

### Added
- **Renamed Fish List to Catch List**
  - Better reflects that it tracks all catches, not just fish
  - Separated fish from miscellaneous catches (lockboxes, gear, potions, etc.)
  - Two sections: "Fish" and "Miscellaneous" on same page
- **Rich tooltips on catches**
  - Hover over any catch to see detailed statistics
  - Shows total caught, locations where caught, first/last catch dates
  - Works in Catch List, Overview recent catches, and History tabs
- **Per-Character Statistics mode**
  - Optional mode to track each character's fishing separately
  - Enable in Settings tab with choice to copy account-wide data or start fresh
  - Account-wide mode remains default for seamless multi-character experience
  - Can switch back to account-wide mode at any time
- **Smart fish categorization**
  - Uses item type, subtype, and keyword matching
  - Properly categorizes edge cases (potions, gems, crafting materials)
  - Miscellaneous section includes: lockboxes, chests, gear, potions, gems, scrolls, recipes

### Fixed
- Improved catch categorization logic to handle non-fish items correctly
- Better handling of items that don't fit typical fish patterns
- Fixed miscellaneous items appearing in fish section

## [1.0.7] - 2025-12-08

### Added
- **Configurable lure warning interval**
  - New dropdown in Settings to choose warning frequency: 30, 60, or 90 seconds
  - Replaces the hardcoded 30-second interval
  - Setting persists across sessions

### Changed
- Renamed "Buff" to "Lure" throughout the addon for clarity
  - Raid warning now says "No Fishing Lure!" instead of "No Fishing Pole Buff!"
  - Settings checkbox now says "Warn When Fishing Without Lure"
  - Statistics tab now shows "Fishing Lures Used" instead of "Fishing Buffs Used"
  - Clear stats dialog updated to reference "Lure usage tracking"

### Fixed
- Fixed "Unknown Lure (ID: XXX)" appearing in lure statistics
  - Non-fishing weapon enchants (sharpening stones, weightstones, etc.) were being incorrectly tracked as lures
  - Addon now only tracks enchants that are confirmed fishing lures (by enchant ID or tooltip text)
  - Unknown enchants are now ignored instead of creating erroneous entries
- Fixed purge function not removing items from lure usage statistics
  - Purge Item now also checks the lure/buff usage table
  - Can now properly remove incorrectly tracked lures like "Unknown Lure (ID: 625)"

## [1.0.6] - 2025-12-05

### Added
- **Refresh Icons** button in Fish List tab
  - Scans your bags for fish and updates their icons in the database
  - Useful for updating icons of fish caught before v1.0.6
  - Shows how many icons were found and updated
  - Icons are saved permanently once refreshed
- **Automatic background icon refresh**
  - Runs silently every 5 minutes to update fish icons from bags
  - Only updates missing or default icons (non-intrusive)
  - Automatically keeps your fish icons up-to-date
- **"What's New" dialog**
  - Shows version highlights when opening UI after update
  - Can be dismissed permanently or acknowledged for future updates
  - Helps users discover new features and fixes
  - Dynamic content system - easy to update for new versions
- **Automatic database migration** v1.0.6
  - Detects when upgrading from older version
  - Notifies users about improved icon caching
  - Reminds users to use Refresh Icons button if they have fish in bags
- **Centralized version management**
  - Single version constant (CFC.VERSION) used throughout addon
  - Easier version updates and maintenance
- **Statistics Tab enhancements**
  - Hourly productivity analysis showing catches by hour of day
  - Weekly breakdown showing last 7 days of fishing activity
  - Monthly breakdown showing last 4 weeks of fishing activity
  - Visual bar graphs for hourly, daily, and weekly statistics
  - Peak fishing period detection (morning, afternoon, evening, night)
- **Fish rarity color coding**
  - Fish names now display in their item quality color (gray/white/green/blue/purple/orange)
  - Applied throughout Overview, Fish List, History, and Statistics tabs
- **Catch milestone notifications**
  - Celebrates fishing milestones: 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000, 100000 catches
  - On-screen notification and sound effect when reaching milestones
- **Max fishing skill announcement**
  - Optional announcement when reaching maximum fishing skill (300)
  - Configurable channel: Off, Say, Party, Guild, or Emote
  - Setting available in Settings tab
- **Centralized color codes and constants**
  - CFC.COLORS table for consistent color usage across addon
  - CFC.CONSTANTS table for slots, bags, intervals, lure IDs, enchant IDs, and milestones

### Fixed
- Fixed lure statistics incorrectly incrementing when using `/reload` command
  - Addon now detects existing lures on load/reload and doesn't count them as new applications
  - Only genuine new lure applications are tracked in statistics
  - Prevents inflation of lure usage counts from UI reloads
- Improved Fish List icon loading reliability
  - Now uses item links (more reliable) when caching fish icons at catch time
  - Tries multiple methods to retrieve icons: cached data, item link, item name, bag scanning
  - Better handling of WoW API item data caching delays
  - New fish caught going forward will have more reliable icon caching
- Fixed debug spam in Apply Lure function
  - Wrapped 30+ debug print statements in conditional checks
  - Only user-facing messages now display during normal operation
- Added nil checks to catch history loops
  - Prevents "nil" appearing in output if catch data is incomplete
  - Fallback values for missing itemName, zone, and date fields
- Improved gear swap error messages
  - Added cursor validation after item pickup
  - User-friendly error messages instead of silent failures
- Locale-independent lure detection
  - Now uses weapon enchant IDs instead of tooltip text parsing
  - Works correctly regardless of game language setting
  - Fallback to tooltip parsing if enchant ID not recognized

## [1.0.5] - 2025-11-30

### Added
- Fishing pole and lure bonus display on HUD skill line
  - Shows fishing pole inherent bonus in green with pole icon (e.g., "+25")
  - Shows active lure bonus in yellow with lure icon (e.g., "+75")
  - Dynamic icon fetching displays actual equipped pole and selected lure icons
  - Supports all lure types: +25 (Shiny Bauble), +50 (Nightcrawlers, Aquadynamic Fish Lens), +75 (Bright Baubles, Flesh Eating Worm), +100 (Aquadynamic Fish Attractor)
  - Example display: "Skill: 150/300 +25 [pole icon] +75 [lure icon]"
- Casting protection for gear swapper
  - Prevents gear swaps while casting or channeling any spell
  - Shows warning message when attempting to swap during cast
  - Uses UnitCastingInfo and UnitChannelInfo for comprehensive protection
- Configurable announcement settings
  - New setting to enable/disable buff warning messages (enabled by default)
  - New setting to enable/disable fishing skill increase announcements (enabled by default)
  - Both settings available in Settings tab with clear descriptions
- Data import/export functionality
  - Export all fishing data for backup or transfer between characters
  - Import data from exported files to restore or merge statistics
- Automatic backup system
  - Internal backups created every 24 hours (stored in SavedVariables: `WTF\Account\[ACCOUNT_NAME]\[RandomNumberString]\SavedVariables\ClassicFishingCompanion.lua.bak`)
  - Export reminder shown every 7 days of play time
  - "Enable Automatic Backups" setting to toggle automatic backups (enabled by default)
  - "Restore from Backup" button to restore from most recent automatic backup
  - Backup timestamp displayed in Settings tab
  - Session data preserved when restoring from backup
  - Confirmation dialog when restoring backup

### Changed
- Performance optimizations
  - Moved lure mapping tables to module-level constants to prevent recreation on every HUD update
  - Eliminated duplicate GetCurrentFishingBuff() call (was called twice per update)
  - Consolidated multiple time() calls in fishing state checks to single variable
  - Removed redundant conditional checks

### Fixed
- Fixed Fish List icon loading for Anniversary Classic
  - Updated to use C_Container API (Anniversary Classic uses modernized container system)
  - Searches player bags using C_Container.GetContainerItemInfo to get icon textures
  - Maintains backward compatibility with older Classic versions
  - Falls back to default fish icon for items not in bags
  - Provides better visual consistency for caught fish no longer in inventory
- Fixed Fish List showing wrong icons for fish no longer in bags
  - Icons are now cached when fish are first caught and stored in database
  - Cached icons are used first, eliminating dependency on item cache or bag contents
  - Icons automatically update when found via GetItemInfo or bag scanning
  - Ensures correct icons display even for fish caught long ago or sold/banked
- Fixed tooltip pollution causing item data caching issues
  - Moved tooltip creation to module-level for reuse in GetFishingPoleBonus() and GetCurrentFishingBuff()
  - Prevents excessive tooltip creation impacting item icon loading
- Improved code efficiency by removing unnecessary operations
- Optimized HUD update cycle for better performance

## [1.0.3] - 2024-11-23

### Added
- Gear Sets system for quick equipment swapping
  - Save fishing and combat gear sets with one click
  - Swap between gear sets instantly with HUD button or slash commands
  - New "Gear Sets" tab in main UI for managing saved equipment
  - Visual display of all saved items in each gear set
  - Quick swap button on Stats HUD showing current mode (🎣 Fishing / ⚔️ Combat)
  - Slash commands: `/cfc savefishing`, `/cfc savecombat`, `/cfc swap`
  - Combat lockdown protection prevents gear swaps during combat
  - Automatic detection of gear configuration status
- Lure Manager system for quick lure application
  - New "Lure" tab in main UI for selecting preferred fishing lures
  - "Apply Lure" button on HUD to instantly apply selected lure to fishing pole
  - Support for all common fishing lures (Shiny Bauble, Nightcrawlers, Bright Baubles, Flesh Eating Worm, Aquadynamic Fish Attractor, Aquadynamic Fish Lens)
  - Corrected lure icons to match actual Classic WoW items
  - Inventory check warns when attempting to apply lure not in bags
  - Warning message when attempting to apply lure while in combat gear

### Changed
- HUD now displays "Lure:" instead of "Buff:" for better clarity
- Simplified HUD gear swap button text to prevent overlap ("Swap to" + icon)
- Renamed "Lure Manager" tab to "Lure" for cleaner interface

### Fixed
- Fixed lure tracking false positives when buying lures from vendors
  - Increased detection threshold from 5 to 500 seconds to prevent false counts
  - Only genuine lure applications are now tracked
- Fixed lure statistics tracking incorrect data
  - Now reads actual lure from fishing pole tooltip instead of trusting UI selection
  - Prevents false statistics when clicking Apply Lure for items not in inventory
- Fixed lure statistics showing duplicate entries with different time formats
  - Improved regex pattern to strip both minute and second formats from lure names
  - Ensures consistent lure names in statistics regardless of time remaining
- Fixed raid warnings triggering when not in fishing gear mode
  - Warnings now only appear when in fishing gear mode, not combat gear
  - Added gear mode check to prevent false warnings after swapping to combat gear
- Fixed combat loot being tracked as fish catches
  - Addon now only tracks loot from actual fishing casts, not combat kills
  - Uses UnitIsDead check to distinguish fishing loot from mob loot
  - Prevents mob loot from being tracked when you have a fishing pole equipped
- Fixed missing buff warnings not triggering consistently when actively fishing
  - Removed overly restrictive time-since-last-cast check
  - Warning now triggers reliably every 30 seconds (reduced from 60) when fishing without a lure
  - Warning only requires fishing pole equipped and fishing gear mode active
- Fixed "Clear All Statistics" button not clearing fishing pole usage and sessions data
- Fixed lure selection not updating the Apply Lure button macro
- Improved macro handling for lure application

## [1.0.2] - 2024-11-22

### Added
- Clickable lock icon on HUD for instant lock/unlock toggle
- Hover tooltips on lock icon showing current state and instructions
- Native WoW padlock icons for professional appearance

## [1.0.1] - 2024-11-22

### Added
- Missing buff warning system
  - On-screen warnings every 60 seconds when fishing without a lure/buff
  - Displays prominently in center of screen for 10 seconds
  - HUD shows "None" in red when no buff is active
  - Warning enabled by default, can be toggled in Settings

### Changed
- Updated settings UI with clearer descriptions

### Fixed
- Bug where cooked/crafted fish were incorrectly tracked as caught fish
  - Addon now only tracks items from "You receive loot:" messages (fishing)
  - Ignores "You create:" messages from cooking and other professions

## [1.0.0] - 2024-11-21

### Added
- Initial release with comprehensive fishing tracking
- Stats HUD with real-time display
- Buff timer with color-coded countdown
- Fishing skill progression tracking
- Buff and pole usage statistics
- Customizable settings
- Minimap button with quick actions
- Full Classic WoW compatibility
