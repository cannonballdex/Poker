# Poker 23rd Anniversary Quest Script

Automates the **“Paintings Playing Poker” 23rd Anniversary quest** path for EverQuest using **MacroQuest** and Lua.

This script handles travel, invis, shrink, movement, vendor interactions, campfire logic, and several fallback teleport methods so the quest can be run with less manual input.

## What this script does

The script:

- Loads saved settings from a config file
- Opens an ImGui-based GUI
- Checks for required consumables such as **Cloudy Potions**
- Uses class-specific invis and movement helpers
- Uses shrink clickies or class abilities when needed
- Travels through the quest route automatically
- Talks to the required NPCs
- Uses several return methods such as:
  - **Gate**
  - **Philter of Major Translocation**
  - **Bulwark of Many Portals**
  - **Fellowship campfire**
  - **Drunkard's Stein**
  - **Zueria Slide: Nektulos**
  - **Throne of Heroes**
- Tracks runtime and loop count
- Optionally repeats the quest if looping is enabled

## Files

This script expects these Lua modules to exist in the same MacroQuest Lua environment:

- `init.lua` – main quest logic
- `poker_config.lua` – settings load/save logic
- `poker_gui.lua` – ImGui window and controls

## Requirements

Before running the script, make sure you have:

- **MacroQuest**
- **Lua support enabled in MacroQuest**
- Navigation/travel commands available in your setup such as:
  - `/nav`
  - `/travelto`
- The companion config and GUI files:
  - `poker_config.lua`
  - `poker_gui.lua`

## Optional items and abilities used by the script

The script can use several items and abilities if available.

### Consumables and items

- `Cloudy Potion`
- `Philter of Major Translocation`
- `Bulwark of Many Portals`
- `Fellowship Registration Insignia`
- `Drunkard's Stein`
- `Zueria Slide: Nektulos`

### Shrink clickies checked by the script

- `Wand of Imperceptibility`
- `Anizok's Minimizing Device`
- `Bestial Sandals`
- `Boots of Beast Mastery`
- `Boots of the Beastlord`
- `Cobalt Bracer`
- `Earring of Diminutiveness`
- `Humanoid Reductionizer`
- `Ring of the Ancients`
- `Savage Boots`
- `Shimmering Bauble of Trickery`
- `Vial of Shrieker Essence`
- `Wild Lord's Sandals`

### Class-specific behavior

The script contains special handling for several classes, including:

- `BRD`
- `ROG`
- `BST`
- `SHM`
- `MAG`
- `WIZ`
- `SHD`
- `NEC`
- `DRU`
- `RNG`
- `BER`

Some classes are also treated as needing **Cloudy Potions** for invis support:

- `WAR`
- `CLR`
- `MNK`
- `BER`
- `PAL`

## Expected settings

The script reads settings from `config.load()` and uses these values:

- `Debug`
- `Campfire`
- `CloudyPots`
- `Philter`
- `Bulwark`
- `Campfire_HighPassHold`
- `LOOP`

Your `poker_config.lua` file should provide these settings and a matching `save()` function.

## How to run

From MacroQuest, run the script with Lua:

```text
/lua run init
```

If your file is named differently, use that filename instead.

## What the route includes

Based on the script logic, the run includes travel through several zones and interactions, including:

- Plane of Knowledge
- Freeport West
- Freeport East
- Nektulos
- Neriak A
- Neriak B
- Highpass Hold
- Qeynos Hills / Qeynos pathing sequence
- Return to Plane of Knowledge
- Final turn-in at Slick in Freeport West

## How looping works

If `LOOP` is enabled in your config, the script will keep running the quest repeatedly until stopped.

If `LOOP` is disabled, it will run once and exit.

## Debugging

When `Debug` is enabled, the script prints extra status output for things like:

- zoning
- movement
- travel retries
- teleport fallback logic
- item usage
- campfire handling

This is useful when a step fails and you need to see where the run stopped.

## Important notes

- The script assumes your character can safely use the required travel route.
- Some parts rely on **specific items, AAs, or fellowship features** being available.
- The script uses hardcoded NPC names, locations, and zone IDs.
- The script also uses hardcoded item names, so spelling must match exactly in game.
- If a teleport method fails, the script often tries another fallback automatically.
- The script destroys an empty **Bulwark of Many Portals** when detected.

## Troubleshooting

### The script does not start
Check that:

- `mq` can be required successfully
- `poker_config.lua` exists
- `poker_gui.lua` exists
- MacroQuest Lua is working correctly

### Travel or navigation fails
Check that:

- your navigation plugin is loaded
- `/nav` works manually
- `/travelto` works manually
- the target zones and doors are reachable on your server/setup

### The character gets stuck waiting
This can happen around:

- zoning
- campfire placement
- fellowship insignia cooldowns
- failed teleport retries

Enable `Debug` and watch the last printed step.

### Cloudy Potions are not being purchased
The script expects:

- class to match one of the potion-using classes
- fewer than 20 potions in inventory
- access to **Mirao Frostpouch** in Plane of Knowledge

## Safety and usage warning

Use this only where it is allowed by the rules for your server and tools.  
You are responsible for how and where you run automation.

## Summary

This is a quest automation script for the **Paintings Playing Poker** anniversary task. It is built around MacroQuest Lua and is designed to reduce manual travel and interaction by combining pathing, invis, shrink, teleport fallback logic, and optional looped execution.