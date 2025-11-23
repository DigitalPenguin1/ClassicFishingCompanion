# Classic Fishing Companion

A comprehensive fishing tracker addon for World of Warcraft Anniversary Classic. Track all your catches, monitor your fishing efficiency, view detailed statistics, and display real-time fishing stats with an on-screen HUD!

Update 11/22/25 - Waiting on PTR access for TBC so I can start testing. More to come. -- Relyk22

## Features

### 📊 Comprehensive Tracking
- **Every Fish Tracked**: Records every single fish you catch
- **Location Data**: Saves the zone and subzone where each fish was caught
- **Timestamp Records**: Each catch is timestamped for detailed history
- **Fish Per Hour**: Real-time calculation of your fishing efficiency
- **Session Statistics**: Track your current fishing session separately from lifetime stats
- **Fishing Skill Tracking**: Monitors your fishing skill level and records skill increases
- **Buff Usage Tracking**: Tracks which fishing lures and buffs you use
- **Fishing Pole Tracking**: Records which fishing poles you use and how often

### 🎯 Stats HUD (Heads-Up Display)
- **On-Screen Stats Display**: Real-time fishing statistics overlay
  - Session catches count
  - Total lifetime catches
  - Fish per hour rate
  - Current fishing skill level
  - Active fishing buff/lure name
  - **Buff Timer Countdown**: Color-coded timer showing time remaining on lures
    - 🟢 Green: More than 2 minutes remaining
    - 🟡 Yellow: 1-2 minutes remaining
    - 🔴 Red: Less than 1 minute remaining
- **Draggable & Lockable**: Position the HUD anywhere on screen
- **Clickable Lock Icon**: Click the padlock icon in the top-right corner to instantly lock/unlock the HUD
- **Quick Toggle**: Right-click minimap icon to show/hide HUD

### 🎣 Detailed Statistics
- **Fish List**: View all unique fish you've caught with catch counts
- **History Log**: Browse through your recent catches with dates and locations
- **Top Fish**: See which fish you catch most often
- **Zone Statistics**: Find out which zones are most productive
- **Fishing Skill Progress**: View recent skill level increases
- **Buff Usage Stats**: See which lures and buffs you use most often
- **Fishing Pole Stats**: Track which fishing poles you've used
- **Lifetime Tracking**: All-time statistics across all your fishing sessions

### 🖥️ User Interface
- **Clean Tabbed Interface**: Easy-to-navigate UI with multiple tabs
  - **Overview**: Current session and lifetime stats at a glance
  - **Fish List**: All fish types you've caught, sorted by count
  - **History**: Recent catches with full details
  - **Statistics**: Detailed stats including skill progress, buff usage, pole usage, top fish, and zones
  - **Settings**: Customize addon behavior and display options
- **Minimap Button**: Quick access button on your minimap
  - Left-click: Open main UI
  - Right-click: Toggle Stats HUD
  - Drag: Move button around minimap
  - Hover: See quick session stats tooltip
- **Real-time Updates**: UI and HUD update automatically as you catch fish

### ⚙️ Settings & Customization
- **Minimap Icon**: Show/hide the minimap button
- **Announce Fish Catches**: Optional chat messages when catching fish
- **Warn When Fishing Without Buff**: On-screen warnings every 60 seconds when fishing without a lure (enabled by default)
- **Show Stats HUD**: Toggle the on-screen stats display
- **Lock Stats HUD**: Prevent HUD from being moved accidentally
- **Debug Mode**: Enable detailed debug output for troubleshooting
- **Clear All Statistics**: Reset all tracked data with confirmation dialog

### ✨ Additional Features
- **Automatic Detection**: Automatically detects when you catch fish
- **Buff Detection**: Recognizes common fishing lures (Shiny Bauble, Nightcrawlers, Bright Baubles, Aquadynamic Fish Attractor)
- **Missing Buff Warnings**: Prominent on-screen warning displayed every 60 seconds when fishing without a lure/buff
  - Displays in center of screen for 10 seconds
  - HUD shows "None" in red when no buff is active
  - Helps maximize fishing skill bonus by reminding you to apply lures
- **Persistent Data**: All data is saved between sessions
- **Lightweight**: Minimal performance impact
- **Classic WoW Compatible**: Fully optimized for Classic WoW character encoding

## Usage

### Getting Started
1. Load into the game with the addon enabled
2. You'll see the Stats HUD appear on screen (can be toggled in Settings)
3. Start fishing!
4. The addon automatically tracks every fish you catch

### Opening the UI
- **Click** the minimap button (fish icon)
- **Type** `/cfc` in chat
- The Stats HUD can be toggled by right-clicking the minimap button

### Minimap Button Controls
- **Left-Click**: Open/close the main UI window
- **Right-Click**: Toggle Stats HUD visibility
- **Drag**: Move button around the minimap edge
- **Hover**: View tooltip with quick session stats

### Commands
- `/cfc` - Open/close the main UI
- `/cfc stats` - Print statistics to chat
- `/cfc reset` - Reset all data (with confirmation)
- `/cfc debug` - Toggle debug mode
- `/cfc minimap` - Toggle minimap button visibility

### Using the Stats HUD
The HUD displays real-time fishing information:
- **Session**: Fish caught this session
- **Total**: Lifetime fish caught
- **Fish/Hour**: Current fishing efficiency
- **Skill**: Your fishing skill level (current/max)
- **Buff**: Active fishing lure or buff
- **Time Left**: Countdown timer for buff expiration
  - Timer changes color as time runs low
  - Helps you know when to reapply lures

**Moving and Locking the HUD:**
1. Make sure HUD is unlocked (click the padlock icon in top-right corner or check Settings tab)
2. Click and drag the HUD to your preferred position
3. Click the lock icon to lock it in place, or use the Settings tab
4. A locked padlock icon 🔒 means the HUD is locked; an unlocked icon 🔓 means it can be moved
5. Hover over the lock icon to see a tooltip with the current state

### Understanding the Interface

#### Overview Tab
- **Current Session**: Shows catches, fish/hour, and time for your current play session
- **Lifetime Statistics**: All-time totals across all sessions
- **Fishing Skill**: Current skill level with max
- **Recent Catches**: Quick list of your last 10 catches

#### Fish List Tab
- Displays all unique fish types you've caught
- Sorted by most caught first
- Shows total count for each fish type

#### History Tab
- Complete log of your recent catches (last 50)
- Shows fish name, date/time, and location
- Scrollable list

#### Statistics Tab
- **Fishing Skill**: Current skill level and recent skill increases
- **Fishing Poles Used**: Which poles you've used and how many casts
- **Fishing Buffs Used**: Which lures/buffs you've applied and usage count
- **Top 10 Most Caught Fish**: Your most common catches
- **Fishing Zones**: Most productive fishing locations

#### Settings Tab
- **Show Minimap Icon**: Toggle minimap button visibility
- **Announce Fish Catches**: Enable/disable chat messages for catches
- **Warn When Fishing Without Buff**: Enable/disable on-screen warnings when fishing without a lure (enabled by default)
- **Show Stats HUD**: Toggle the on-screen HUD
- **Lock Stats HUD**: Prevent HUD from being dragged
- **Enable Debug Mode**: Show detailed debug information
- **Clear All Statistics**: Reset all data (warns about permanent deletion)

### Tips
- The Stats HUD provides at-a-glance information without opening the main UI
- Buff timer helps you maximize your fishing skill bonus by reapplying lures promptly
- Missing buff warnings appear in the center of your screen when fishing without a lure - keep your fishing skill bonus active!
- Click the lock icon in the top-right of the HUD for quick lock/unlock without opening Settings
- Lock the HUD once you've positioned it to avoid accidental movement during gameplay
- All location data is saved for each catch
- Fishing skill increases are automatically tracked and displayed in Statistics
- You can reset data at any time through Settings or `/cfc reset` command

## Data Tracked

For each fish caught, the addon records:
- Fish name (item name)
- Exact timestamp
- Zone name
- Sub-zone name
- Player coordinates
- Date and time (formatted)

Additional tracking:
- Fishing skill level and skill-ups
- Fishing lures/buffs applied (name, count, timestamps)
- Fishing poles used (name, cast count, timestamps)

## Statistics Calculated
- Total catches (lifetime and session)
- Unique fish types caught
- Fish per hour (session and average)
- Total fishing time
- Per-fish statistics and locations
- Zone productivity
- Fishing skill progression
- Buff/lure usage frequency
- Fishing pole usage statistics

## Troubleshooting

### Fish not being tracked?
- Make sure you're actually fishing (casting Fishing spell)
- Some items from fishing pools may not be tracked correctly
- Check if the addon is enabled in the AddOns menu
- Enable debug mode (`/cfc debug`) to see detailed tracking information

### Minimap button missing?
- Type `/cfc` to open the UI
- Check Settings tab to show the minimap button
- Try `/reload` to reset UI

### Stats HUD not showing?
- Right-click the minimap button to toggle HUD
- Check the "Show Stats HUD" option in Settings tab
- Make sure HUD isn't positioned off-screen (reset position in Settings)

### Buff timer not showing?
- Make sure you have a fishing lure applied to your fishing pole
- Supported lures: Shiny Bauble, Nightcrawlers, Bright Baubles, Aquadynamic Fish Attractor
- Timer appears only when a fishing buff is active

### UI not showing?
- Make sure addon is enabled
- Check for Lua errors with `/console scriptErrors 1`
- Try `/reload` to reload the UI

### Data not saving?
- Data is saved automatically
- Make sure WoW closes properly (not Alt+F4)
- Check SavedVariables folder for `ClassicFishingCompanionDB.lua`

### Special characters showing as boxes?
- This has been fixed in the latest version
- Update to the current version if you see � or □ symbols

## Performance

This addon is designed to be lightweight:
- Only tracks events when you're actually fishing
- Efficient data storage
- Minimal UI updates when window is closed
- HUD updates once per second (minimal impact)
- No continuous scanning or heavy operations

## Version History

### Version 1.0.2
- Improved HUD lock/unlock functionality
  - Lock icon is now clickable for instant lock/unlock toggle
  - Hover tooltip shows current lock state and click instruction
  - Uses native WoW padlock icons for professional appearance

### Version 1.0.1
- Added missing buff warning system
  - On-screen warnings every 60 seconds when fishing without a lure/buff
  - Displays prominently in center of screen for 10 seconds
  - HUD now shows "None" in red when no buff is active
  - Warning enabled by default, can be toggled in Settings
- Updated settings UI with clearer descriptions
- Fixed bug where cooked/crafted fish were incorrectly tracked as caught fish
  - Addon now only tracks items from "You receive loot:" messages (fishing)
  - Ignores "You create:" messages from cooking and other professions

### Version 1.0.0
- Initial release with comprehensive fishing tracking
- Stats HUD with real-time display
- Buff timer with color-coded countdown
- Fishing skill progression tracking
- Buff and pole usage statistics
- Customizable settings
- Minimap button with quick actions
- Full Classic WoW compatibility

## Support

If you encounter any issues or have suggestions:
1. Check the Troubleshooting section above
2. Make sure you're running the latest version
3. Enable debug mode to get detailed information
4. Report bugs with detailed information (what happened, when, any error messages) https://github.com/DigitalPenguin1/ClassicFishingCompanion/issues

## Credits

Created for World of Warcraft Classic


Uses embedded Ace3 libraries for the addon framework.

Copyright (c) 2007, Ace3 Development Team

## License

Free to use and modify for personal use.

---

**Happy Fishing!** 🎣

*May your lines be tight, your lures be fresh, and your catches be plenty!*
