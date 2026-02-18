# Easy Cast & Lures

Easy Cast combines two things: a convenient casting method and automatic lure management.

---

## Easy Cast

When enabled, **double right-clicking** your fishing bobber casts your fishing pole. On each cast, CFC checks if your lure has expired and re-applies it automatically before casting.

**To enable Easy Cast:**
1. Open CFC (`/cfc`)
2. Go to the **Settings** tab
3. Enable **Easy Cast**

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
