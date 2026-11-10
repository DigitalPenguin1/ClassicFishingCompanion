# Easy Cast & Lures

Easy Cast combines two things: a convenient casting method and automatic lure management.

---

## Easy Cast

Easy Cast casts your fishing line for you. On each cast, CFC checks if your lure has expired and re-applies it before casting. It only works while the HUD is visible and a fishing pole is equipped.

**To enable Easy Cast:**
1. Open CFC (`/cfc`)
2. Go to the **Settings** tab
3. Check **Enable Easy Cast**
4. Under **Cast with**, pick **Double Right-Click** or **Cast & Loot Key** (Forever only)

Only the trigger you pick is active. Double Right-Click is the default.

### Double Right-Click

Double right-click anywhere in the world to cast. A single right-click on the bobber still loots normally.

### Cast & Loot Key (Forever)

One key does the whole fishing loop:

1. Press the key to cast (CFC applies your lure first if it has run out)
2. When the bobber splashes, put your cursor on it and press the same key to loot
3. Press it again to cast the next line

While your line is out, the key acts as WoW's **Interact With Mouseover**, which is why it loots whatever is under your cursor.

**Setting the key:** select **Cast & Loot Key**, click the key button next to it, then press a key. You can use:
- Any keyboard key, with or without Shift, Ctrl or Alt
- Middle mouse button or a side mouse button (Button 4/5)
- Shift, Ctrl or Alt + right-click

Plain right-click and plain left-click can't be used. Every right-click would cast, which breaks turning the camera and clicking NPCs. Press **Escape** to cancel, or **Clear** to remove the key.

**When the key goes back to normal:** in combat, without a fishing pole equipped, while a loot window or popup is open, or with Easy Cast off, CFC lets go of the key. It then does whatever it's normally bound to in WoW's Key Bindings.

> **Note:** The Cast & Loot Key is only on WoW: Forever. Classic Era and TBC don't have Interact With Mouseover, so they use Double Right-Click.

---

## Selecting a Lure

1. Open the CFC HUD or UI
2. Use the **Lure dropdown** to select the lure you want to use
3. CFC will apply that lure automatically whenever it expires

> **Note:** The lure must be in your bags. If you run out, a message will appear in chat (shown at most once every 10 minutes).

---

## Supported Lures

### Classic Era

| Lure | Fishing Bonus |
|---|---|
| Aquadynamic Fish Attractor | +100 |
| Bright Baubles | +75 |
| Flesh Eating Worm | +75 |
| Nightcrawlers | +50 |
| Aquadynamic Fish Lens | +50 |
| Shiny Bauble | +25 |

### TBC Classic

| Lure | Fishing Bonus |
|---|---|
| Sharpened Fish Hook | +100 |
| Aquadynamic Fish Attractor | +100 |
| Bright Baubles | +75 |
| Flesh Eating Worm | +75 |
| Nightcrawlers | +50 |
| Aquadynamic Fish Lens | +50 |
| Shiny Bauble | +25 |

---

## Lure Detection

CFC detects the active lure on your fishing pole using the enchant ID — no tooltip scanning needed. This was improved in v1.1.2 to eliminate tooltip flickering that some users experienced when swapping to their fishing gear set.

---

## Out-of-Lure Warning

If Easy Cast tries to apply a lure but you have none in your bags, CFC will print a message in chat:

> *Classic Fishing Companion: Out of [Lure Name]! Casting without a lure.*

This message is throttled to once per 10 minutes so it doesn't spam you mid-session.

---

*Back to [[Home]]*
