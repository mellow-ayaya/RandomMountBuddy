### Random Mount Buddy

Improve your summon-random-favorite-mount experience with RandomMountBuddy! Minimal setup required: just set up the keybind and you're good to!

![](https://media.forgecdn.net/attachments/1418/176/screenshot-2025-12-08-092849-jpg.jpg)
### &nbsp;
### About

This addon solves a niche issue with random summoning: if you've favorited multiple recolors or versions of the same mount (like several Cloud Serpent colors), you'll see them much more often compared to mounts with less recolors/variants. Random Mount Buddy picks a random mount type first, then a random color/variant, ensuring better distribution across your favorites.
### &nbsp;
### How It Works

With default random summoning, favoriting multiple variants of the same mount creates heavily skewed odds. Here's a real example from version 1.0.22 with 711 flying mounts:

- Without Random Mount Buddy: Cloud Serpent ~4.36%, Ashes of Al'ar ~0.14%
- With Random Mount Buddy: Cloud Serpent ~1%, Ashes of Al'ar ~0.11% (Ashes now ~3.4x fairer relative to Cloud Serpent)

And that's just one way Random Mount Buddy balances heavily recolored mounts with unique ones!

*Technicalities: all Cloud Serpent and Ashes variants favorited; flying mount count includes faction exclusives so the ratio may vary slightly, but should remain similar.*

### &nbsp;
### Features

Base features:
- Mounts with recolors are grouped in Families, similar Families are grouped in Groups.
- Instead of summoning an individual mount, the addon summons a random group or ungrouped family/mount.
- If you like seeing unique mounts like Alunira (unique gryphon variant), enable 'Favor Unique Mounts' to give them independent (better) summon chances instead of grouping them.
- Mount browser: see your entire mount collection grouped in Families and Groups and adjust various settings with ease such as weight and uniqueness.

Summoning features:
- Contextual Summoning: Automatically filters by flying/ground/swimming based on your location.
- Improved Randomness: Recently used mount families become temporarily unavailable for better variety.
- Weight System: Prioritize your favorites while still getting variety.
- Favorite Sync: Automatically sync with your WoW Mount Journal favorites.
- D.R.I.V.E. support: Automatically summon G-99 Breakneck when in the correct zones.
- Macros: Create macros using /run RMB:SRM(true) or /rmb s. Note: Macros won't automatically use class spells like Travel Form - see Macro examples below.
- Rules: Create rules to summon specific mounts in specific conditions such as player level, zone, instance type, while in party with a friend, when using a specific keybind, and more!

Utility features:
- Press the addon keybind to use class spells such as Flight/Travel/Cat form depending on the situation, or Levitate while falling! Classes supported: Druid, Shaman, Mage, Monk, Priest.

### &nbsp;
### Macro examples:

You can use /rmb s to create macros that will summon using the addon's logic! Due to technical limitations, these macros will not be able to use the class specific settings, but everything else is compatible. If you would like to make macros that also have class functionality similar to the addon, see the below examples.

NOTE: All the macros below can be used while moving, but you will see an error from failing to mount "Can't do that while moving". If you find that annoying, add this to the top of the macro:
```
/run UIErrorsFrame:SuppressMessagesThisFrame()
```

#### Druid
```
/cancelform [noform:4]
/rmb s
/cast [swimming,noform:3,nomounted][outdoors,noform:3,nomounted] Travel Form;[noswimming,indoors,noform:2,nomounted] Cat Form
```

Explanation:

/cancelform [noform:4] -> Cancels form if not in Moonkin form. Do not set it to [noform:2] as it might give you issues.

/cast [swimming,noform:3][outdoors,noform:3] Travel Form;[noswimming,indoors,noform:2] Cat Form  -> If moving or unable to mount, summoning a mount will fail and it will instead cast Travel form if available, or Cat form instead.

/rmb s  -> Summon random mount with fancy addon logic

#### Shaman
```
/rmb s
/cast [noform] Ghost Wolf
```

Explanation:

/rmb s -> Summon random mount with fancy addon logic

/cast [noform] Ghost Wolf  -> If moving or unable to mount, summoning a mount will fail and it will instead cast Ghost Wolf, [noform] makes it so that you can't cancel Ghost Wolf by clicking the macro twice

#### Mage
```
/rmb s
/cast [@player] Slowfall
```

Explanation:

/rmb s -> Summon random mount with fancy addon logic

/cast [@player] Slowfall  -> If moving or unable to mount, summoning a mount will fail and it will instead cast Slowfall

#### Monk
```
/cancelaura [noflying] Zen Flight
/rmb s
/cast Zen Flight
```

Explanation:

/cancelaura [noflying] Zen Flight -> Cancels Zen Flight only if you're on the ground

/rmb s -> Summon random mount with fancy addon logic

/cast Zen Flight -> If moving or unable to mount, summoning a mount will fail and it will instead cast Zen Flight

#### Priest
```
/rmb s
/cast [@player] Levitate
```

Explanation:

/rmb s -> Summon random mount with fancy addon logic

/cast [@player] Levitate  -> If moving or unable to mount, summoning a mount will fail and it will instead cast Levitate

### &nbsp;
### Installation

1.  Download the latest release package (`.zip` file)
2.  Extract the `RandomMountBuddy` folder into your `World of Warcraft\_retail_\Interface\AddOns\` directory
3.  Restart World of Warcraft or Reload your UI (`/reload`)
4.  Set up a keybind for the addon in Options -> Keybinds -> Addons -> Random Mount Buddy Summon
### &nbsp;
### Known issues:

- None at the moment
### &nbsp;
### Need Help?

If you have questions or run into issues, post in the Curseforge comments. For bug reports, please enable the Debugging Messages and provide them along with the issue description.
### &nbsp;
### Disclaimer

This addon contains modified UI textures from World of Warcraft (owned by Blizzard Entertainment). These assets are used with the purpose of creating visual consistency with the original interfaces and remain the intellectual property of their respective owners. This addon is not affiliated with or endorsed by Blizzard Entertainment.

World of Warcraft™ and Blizzard Entertainment® are trademarks or registered trademarks of Blizzard Entertainment, Inc. in the U.S. and/or other countries.
### &nbsp;
### License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)