--2

# World of Warcraft Secure Environment and Keybinding: Comprehensive Documentation

## Table of Contents
1. [Introduction to WoW's Secure Environment](#introduction-to-wows-secure-environment)
2. [Secure Templates and Handlers](#secure-templates-and-handlers)
3. [Keybinding System](#keybinding-system)
4. [Widget Scripts](#widget-scripts)
5. [Practical Implementation Challenges](#practical-implementation-challenges)
6. [Working Implementations](#working-implementations)
7. [Limitations and Constraints](#limitations-and-constraints)
8. [Best Practices](#best-practices)
9. [Common Pitfalls and Gotchas](#common-pitfalls-and-gotchas)
10. [Complete Example Implementations](#complete-example-implementations)

## Introduction to WoW's Secure Environment

World of Warcraft employs a security model that divides addon functionality into secure and insecure environments to prevent automation, botting, and exploits. Understanding this security model is essential for creating functioning keybinding addons.

### Secure vs. Insecure Environment

- **Secure Environment**: Can execute protected actions (cast spells, target units) but has limited API access
- **Insecure Environment**: Has full API access but cannot execute protected actions
- Crossing the secure/insecure boundary is restricted, especially during combat

### Protected Functions

Protected functions include spell casting, targeting, movement, and other gameplay-affecting actions. These protected functions cannot be called directly from insecure addon code, especially during combat.

```lua
-- INCORRECT: This will cause an error if used in insecure addon code
CastSpellByID(783) -- "ADDON_ACTION_FORBIDDEN" error
```

### Combat Lockdown Restrictions

During combat:
- Cannot modify secure frame attributes
- Cannot create new secure frames
- Cannot execute protected functions from insecure code
- State changes made before combat can persist during combat

## Secure Templates and Handlers

### SecureActionButtonTemplate

Basic template for creating buttons that can perform protected actions like casting spells.

```lua
local button = CreateFrame("Button", "ButtonName", UIParent, "SecureActionButtonTemplate")
button:SetSize(1, 1)
button:SetPoint("CENTER")
button:SetAttribute("type", "spell")
button:SetAttribute("spell", "Spell Name")
button:RegisterForClicks("AnyUp", "AnyDown")
```

Available attribute types:
```lua
-- For casting spells:
button:SetAttribute("type", "spell")
button:SetAttribute("spell", spellID) -- or spell name

-- For running macros:
button:SetAttribute("type", "macro")
button:SetAttribute("macrotext", "/cast SpellName")

-- For targeting units:
button:SetAttribute("type", "target")
button:SetAttribute("unit", "target")

-- For clicking other buttons:
button:SetAttribute("type", "click")
button:SetAttribute("clickbutton", otherButton)
```

### SecureHandlerAttributeTemplate

Used for responding to attribute changes in the secure environment.

```lua
local frame = CreateFrame("Frame", "FrameName", UIParent, "SecureHandlerAttributeTemplate")
frame:SetAttribute("_onattributechanged", [[
    if name == "attributeName" then
        -- Do something with value
    end
]])
```

Snippets executed by this template:
```
_onattributechanged (self, name, value)
    The snippet is executed when an attribute changes value; unless its name begins with an underscore.
    self - Secure frame handle to the frame.
    name - String - attribute name.
    value - Mixed - new attribute value.
```

### SecureHandlerStateTemplate

Executes snippets when state attributes change, ideal for use with RegisterStateDriver.

```lua
local frame = CreateFrame("Frame", "FrameName", UIParent, "SecureHandlerStateTemplate")
frame:SetAttribute("_onstate-statename", [[
    if newstate == "value" then
        -- Do something
    end
]])
RegisterStateDriver(frame, "statename", "condition")
```

Snippets executed by this template:
```
_onstate-identifier (self, stateid, newstate)
    The snippet is executed when the "state-identifier" attribute changes value; identifier may be any arbitrary string.
    self - Secure frame handle to the frame.
    stateid - String - identifier of the changed state.
    newstate - Mixed - new value of the "state-identifier" attribute.
```

### SecureHandlerWrapScript

Wraps a widget script with code that executes in the secure environment.

```lua
SecureHandlerWrapScript(frame, "script", header, preBody, postBody)
SecureHandlerBaseTemplate:WrapScript(header, script, preBody, postBody)
```

Valid script handlers for wrapping:
- OnEnter, OnLeave, OnShow, OnHide, OnMouseWheel, OnAttributeChanged
- OnClick, OnDoubleClick, PreClick, PostClick
- OnDragStart, OnReceiveDrag

For different script types, the function signatures differ:

```
OnEnter, OnLeave, OnShow, OnHide, OnMouseWheel, OnAttributeChanged
    allow, message = preBody(self)
    postBody(self, message)

OnClick, OnDoubleClick, PreClick, PostClick
    newbutton, message = preBody(self, button, down)
    postBody(self, message, button, down)

OnDragStart, OnReceiveDrag
    ... = preBody(self, button, down)
    postBody(self, message, button)
```

Return values affect execution flow:
- `allow` (boolean): Halts subsequent execution unless allow ~= false
- `message` (any type): If non-nil, triggers postBody and is passed as 'message'
- `newbutton` (string): If non-nil, changes 'button' in subsequent execution

### SecureHandlerSetFrameRef

Stores a frame handle for access from inside the restricted environment.

```lua
SecureHandlerSetFrameRef(frame, label, refFrame)
SecureHandlerBaseTemplate:SetFrameRef(label, refFrame)
```

Usage from within secure environment:
```lua
local refFrame = self:GetFrameRef("label")
```

This function is protected and cannot be called during combat.

## Keybinding System

### How Keybindings Work

When a user presses a key combination that's bound to an addon function, WoW checks if the binding is valid and executes the associated action. If the action requires protected functions, it must be executed within the secure environment.

### Bindings.xml Structure

```xml
<Bindings>
  <Binding name="BINDING_NAME" header="ADDON_HEADER" category="ADDONS">
    -- Code here (optional)
  </Binding>
</Bindings>
```

The Bindings.xml file is a special file that WoW automatically loads. **IMPORTANT: Do not list Bindings.xml in your TOC file.**

### CLICK Binding Pattern

For protected actions, the CLICK pattern is recommended with an empty body:

```xml
<Bindings>
  <Binding name="CLICK ButtonName:LeftButton" header="ADDON_HEADER" category="ADDONS">
  </Binding>
</Bindings>
```

This pattern directly clicks the specified button in the secure environment when the keybind is pressed. **The binding body should be empty when using CLICK.**

### Function Bindings

```xml
<!-- Function Binding: Calls a Lua function in the insecure environment -->
<Binding name="ADDON_FUNCTION" header="HEADER" category="ADDONS">
  MyAddon:DoSomething();
</Binding>
```

Function bindings cannot perform protected actions directly, but can perform non-protected actions like opening UI panels, printing messages, etc.

### When to Use Each Type

- **Use Click Bindings for**: Casting spells, using items, targeting units, and other protected actions
- **Use Function Bindings for**: Opening configuration panels, toggling addon features, and other non-protected actions

### Binding Global Variables

WoW uses global variables to display binding names in the Key Bindings UI:

```lua
-- For regular bindings:
BINDING_HEADER_ADDONNAME = "Addon Name"
BINDING_NAME_ADDONACTION = "Action Description"

-- For CLICK bindings (note the underscores instead of spaces and colons):
BINDING_HEADER_ADDONNAME = "Addon Name"
BINDING_NAME_CLICK_ButtonName_LeftButton = "Action Description"
```

**CRITICAL**: Getting this naming convention wrong is a common reason keybinds don't appear or work correctly.

### Header Multiple Registration

Each header should only be registered once in Bindings.xml:

```xml
<Bindings>
  <!-- First binding includes the header attribute -->
  <Binding name="RMB_SUMMONFAVORITEMOUNT" header="RANDOMMOUNTBUDDY" category="ADDONS">
    RandomMountBuddy:ClickMountButton();
  </Binding>

  <!-- Second binding omits the header attribute (same group) -->
  <Binding name="CLICK RMBTravelFormButton:LeftButton" category="ADDONS">
  </Binding>
</Bindings>
```

If you attempt to load a header more than once, you'll get an error: `Binding header HEADER was attempted to be loaded more than once.`

## Widget Scripts

### Button Scripts

```
Button
- OnClick(self, button, down) - Invoked when clicking a button.
- OnDoubleClick(self, button) - Invoked when double-clicking a button.
- PostClick(self, button, down) - Invoked immediately after OnClick.
- PreClick(self, button, down) - Invoked immediately before OnClick.
```

PreClick Details:
```
Fires immediately before OnClick.
(self, button, down)
Arguments:
self - Button - Widget being clicked.
button - string - "LeftButton", "RightButton", etc.
down - boolean - True when pressed, false when released.

Details:
Preceeded by OnMouseDown and OnMouseUp.
Blocked in the "up" direction by OnDoubleClick when it fires.
Blocked after dragging or if cursor moves off widget.
```

OnClick Details:
```
Called when the user clicks a button.
(self, button, down)
Arguments:
self - Button - Widget being clicked.
button - string - "LeftButton", "RightButton", etc.
down - boolean - True when pressed, false when released.

Details:
Button:RegisterForClicks() controls which interactions fire OnClick
Preceeded by OnMouseDown, OnMouseUp, PreClick; followed by PostClick.
```

PostClick Details:
```
Fires immediately after OnClick.
(self, button, down)
Arguments:
self - Button - Widget being clicked.
button - string - "LeftButton", "RightButton", etc.
down - boolean - True when pressed, false when released.
```

### Frame Scripts

```
Frame
- OnAttributeChanged(self, key, value) - Invoked when a secure frame attribute is changed.
- OnChar(self, text) - Invoked for each text character typed in the frame.
- OnDisable(self) - Invoked when the frame is disabled.
- OnDragStart(self, button) - Invoked when the mouse is dragged starting in the frame.
- OnDragStop(self) - Invoked when the mouse button is released after a drag started in the frame.
- OnEnable(self) - Invoked when the frame is enabled.
- OnEvent(self, event, ...) - Invoked whenever an event fires for which the frame is registered.
- OnUpdate(self, elapsed) - Invoked on every frame.
```

OnAttributeChanged Details:
```
Fires when an attribute is modified on a frame.
(name, value)
Arguments:
self - ScriptObject - The object the attribute of which was changed.
name - string - The lowercased name of the attribute that was modified.
value - any - The value that was assigned.

Details:
Triggered by Frame:SetAttribute().
Will be invoked even if values are identical.
```

OnEvent Details:
```
Fires when dispatching an event.
(self, event, ...)
Arguments:
self - Frame - The registered widget.
event - string - Name of the event.
... - Variable arguments - The event payload, if any.

Details:
Requires Frame:RegisterEvent()
```

OnUpdate Details:
```
Invoked when drawing the user interface (many times per second).
(self, elapsed)
Payload:
self - ScriptObject - The updated widget.
elapsed - number - The time in seconds since the last OnUpdate dispatch.

Details:
Preceeded by handlers associated with processing user input.
Blocked by hiding a frame or its parent.
Resource intensive - fires as often as the client can draw frames.
```

### ScriptRegion Scripts

```
ScriptRegion
- OnShow(self) - Invoked when the widget is shown.
- OnHide(self) - Invoked when the widget is hidden.
- OnEnter(self, motion) - Invoked when the cursor enters the widget's interactive area.
- OnLeave(self, motion) - Invoked when the mouse cursor leaves the widget's interactive area.
- OnMouseDown(self, button) - Invoked when a mouse button is pressed while the cursor is over the widget.
- OnMouseUp(self, button, upInside) - Invoked when the mouse button is released following a mouse down action in the widget.
- OnMouseWheel(self, delta) - Invoked when the widget receives a mouse wheel scrolling action.
- OnLoad(self) - Invoked when the widget is created.
```

## Practical Implementation Challenges

### Detecting Movement in Combat

A key discovery was that detecting player movement in combat is challenging:

1. `IsPlayerMoving()` API is only available in the insecure environment
2. There is no direct `[moving]` macro conditional equivalent
3. Secure environment restrictions prevent updating attributes based on movement during combat

**Attempted workarounds:**
- Use swimming/flying conditionals as proxies for movement: `[swimming]`, `[flying]`
- Pre-cache the movement state before entering combat
- Use separate buttons for different states

**Key finding**: Despite multiple approaches, it is not possible to reliably detect general movement (walking/running) during combat in the secure environment.

### Detecting Spell Success

Directly detecting if a spell like mount summoning succeeded is difficult, but we can use:

```lua
-- Try to summon a mount
/run RandomMountBuddy:SummonRandomMount(true)
-- Check if now mounted
/stopmacro [mounted]
```

This pattern allows checking the resulting state rather than detecting success/failure directly.

### Combat-Aware Form Switching for Druids

Implementing a system that switches between:
- Travel Form when moving
- Mount when stationary
- Cat Form in combat indoors
- Travel Form in combat outdoors

Was challenging due to combat lockdown restrictions. The most successful approach was to manage out-of-combat state changes well, but accept limited control during combat.

### Macro vs. Script Execution in Combat

A significant finding was that commands using `/run` or `/script` within macros may not execute as expected in combat. Simpler macro conditionals like `[indoors]`, `[outdoors]`, or `[mounted]` are more reliable during combat.

## Working Implementations

### Movement-Aware Button (Out of Combat)

This implementation successfully detects movement and switches between Travel Form and mounting:

```lua
-- Create the button
smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
smartButton:SetAttribute("type", "macro")
smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")

-- Create updater frame
updateFrame = CreateFrame("Frame")
updateFrame.elapsed = 0
updateFrame.lastMoving = false

-- Update button based on movement
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed > 0.1 then
        self.elapsed = 0
        if InCombatLockdown() then return end

        local isMoving = IsPlayerMoving()
        if isMoving ~= self.lastMoving then
            self.lastMoving = isMoving
            if isMoving then
                smartButton:SetAttribute("type", "spell")
                smartButton:SetAttribute("spell", travelFormName)
            else
                smartButton:SetAttribute("type", "macro")
                smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
            end
        end
    end
end)
```

### State-Based Button Switching

Using SecureHandlerStateTemplate to switch between buttons based on combat:

```lua
-- Create state handler
stateHandler = CreateFrame("Button", "RMBStateHandler", UIParent, "SecureHandlerStateTemplate, SecureActionButtonTemplate")

-- Set frame references
stateHandler:SetFrameRef("outCombatButton", smartButton)
stateHandler:SetFrameRef("inCombatButton", combatButton)

-- Set up state driver
stateHandler:SetAttribute("_onstate-combat", [[
    local outCombatButton = self:GetFrameRef("outCombatButton")
    local inCombatButton = self:GetFrameRef("inCombatButton")

    if newstate == "1" then
        -- In combat
        self:SetAttribute("type", "click")
        self:SetAttribute("clickbutton", inCombatButton)
    else
        -- Out of combat
        self:SetAttribute("type", "click")
        self:SetAttribute("clickbutton", outCombatButton)
    end
]])

-- Register state driver
RegisterStateDriver(stateHandler, "combat", "[combat] 1; 0")
```

### Combat Macro with Fallbacks

```lua
local combatMacro = [[
-- Dismount if mounted
/dismount [mounted]

-- Try to summon a mount (will usually fail in combat)
/run RandomMountBuddy:SummonRandomMount(true)
-- Stop if successfully mounted
/stopmacro [mounted]

-- Use Cat Form if indoors
/cast [indoors] ]] .. catFormName .. [[

-- Use Travel Form if outdoors
/cast [outdoors] ]] .. travelFormName
```

### Simple Druid Transformation Macro (Most Reliable in Combat)

```lua
local simpleCombatMacro = [[
-- Dismount if mounted
/dismount [mounted]

-- Use Cat Form if indoors
/cast [indoors] ]] .. catFormName .. [[

-- Use Travel Form if outdoors
/cast [outdoors] ]] .. travelFormName
```

## Limitations and Constraints

### Combat Lockdown Restrictions

1. **Button Attribute Changes**: Cannot modify secure frame attributes during combat
2. **Movement Detection**: Cannot use IsPlayerMoving() in the secure environment
3. **Script Execution**: Cannot invoke protected functions from insecure code during combat
4. **Attribute Propagation**: Cannot use SetFrameRef() in combat

### Macro System Limitations

1. **No [moving] Conditional**: No direct way to check if player is moving in macro conditionals
2. **Limited Lua in Macros**: `/run` commands in macros have restricted functionality
3. **Macro Execution Flow**: No proper if/else logic, only sequential execution with conditionals
4. **Error Handling**: Errors in macros don't provide useful debugging information
5. **Mounting in Combat**: Attempting to mount in combat usually fails with "Can't do that while in combat"

### Secure Environment API Restrictions

Only a limited set of APIs are available in the secure environment:

```
SecureCmdOptionParse("conditionalString") : parses a macro conditional.
GetShapeshiftForm() : returns current shape shift form.
IsStealthed() : returns 1 if the player is stealthed
UnitExists("unit") : returns 1 if the unit exists.
UnitIsDead("unit") : returns 1 if the unit is dead.
UnitIsGhost("unit") : returns 1 if the unit is a ghost.
UnitPlayerOrPetInParty("unit") : returns 1 if the unit is a player or a pet in your party.
UnitPlayerOrPetInRaid("unit") : returns 1 if the unit is a player or a pet in your raid.
IsRightAltKeyDown(), IsLeftAltKeyDown(), IsAltKeyDown() : return 1 if the relevant key is held down.
IsRightControlKeyDown(), IsLeftControlKeyDown(), IsControlKeyDown() : return 1 if the relevant key is held down.
IsRightShiftKeyDown(), IsLeftShiftKeyDown(), IsShiftKeyDown() : return 1 if the relevant key is held down.
IsModifierKeyDown() : returns 1 if any alt, control or shift key is held down.
IsModifiedClick("modifierType") : returns 1 if the associated modifier is held down.
GetMouseButtonClicked() : returns the mouse button responsible for the hardware click.
GetActionBarPage() : returns the current action bar page.
GetBonusBarOffset() : returns the current action bar "bonus" offset (stance-specific bars).
IsMounted() : returns 1 if the player is mounted.
IsSwimming() : returns 1 if the player is swimming.
IsSubmerged() : returns 1 if the player is in a body of water.
IsFlying() : returns 1 if the player is flying.
IsFlyableArea() : returns 1 if the player is in a flyable area (Northrend, Outland).
IsIndoors() : returns 1 if the player is indoors.
IsOutdoors() : returns 1 if the player is outdoors.
```

### Restricted Function Definitions

In the restricted environment, you **cannot** use the `function` keyword to define functions:

```lua
-- INCORRECT: This causes an error in restricted environment
frame:SetAttribute("_onstate-keybind", [[
    local function IsInForm()  -- Error: function keyword not permitted
        -- Function body
    end
]])

-- CORRECT: Use inline code instead
frame:SetAttribute("_onstate-keybind", [[
    -- Inline the code directly
    local inForm = false
    local id = GetShapeshiftForm()
    if id > 0 then
        -- rest of the logic
    end
]])
```

## Best Practices

### Keybinding Best Practices

1. Use the CLICK pattern with empty body for secure actions
2. Create button names with unique global identifiers
3. Register all appropriate binding globals
4. Don't include Bindings.xml in your TOC file
5. Use distinct header attributes only on the first binding in a group

### Secure Environment Best Practices

1. Create secure frames during initialization, before combat
2. Use state drivers for conditional behavior in combat
3. Implement fallback mechanisms for when primary actions fail
4. Keep secure code as simple as possible to avoid issues
5. Avoid complex macros in favor of simpler conditional statements

### Button Creation Timing

Create secure buttons early during addon initialization, such as during the PLAYER_LOGIN event:

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    -- Create secure button here
    self:UnregisterEvent(event)
end)
```

### Debugging Techniques

1. Check for syntax errors in secure handlers
2. Test button clicks directly via slash commands
3. Monitor attribute changes with debug statements
4. Verify binding names in the keybinding UI
5. Test outside combat before testing in combat
6. Check binding status with `/dump GetBindingAction("KEY")`
7. Verify button existence with `/dump _G["ButtonName"]`
8. Check WoW error log for XML parsing errors

## Common Pitfalls and Gotchas

### TOC File Omissions

**CRITICAL**: Never list Bindings.xml in your TOC file. WoW automatically loads this file, and including it leads to errors.

### API Changes

Recent WoW versions have changed some APIs:
- `C_Spell.GetSpellInfo()` now returns a table instead of multiple return values
- `SetBackdrop()` is deprecated; use `CreateTexture()` and `SetColorTexture()` instead

Example of handling the GetSpellInfo change:
```lua
local spellInfo = C_Spell.GetSpellInfo(783)
if type(spellInfo) == "table" and spellInfo.name then
    local spellName = spellInfo.name
    -- Use spellName...
end
```

### Binding Recognition Issues

Even if the binding appears to be set up correctly, WoW may not recognize it until the game is restarted (not just reloaded).

### Secure Handler Error Handling

Errors in secure handlers are often reported with minimal information. Common issues include:
- Typos in attribute names
- Incorrect variable scoping
- Missing colon vs. dot notation
- Trying to use disallowed functions

### Multiple Click Events

When registering for multiple click types with `RegisterForClicks("AnyUp", "AnyDown")`, scripts will fire twice per click - once on button press and once on release.

### Combat Lockdown Impact on UI

When in combat:
- Most secure frame attributes cannot be modified
- New secure frames cannot be created
- Keybindings still work, but dynamic behavior is limited

### XML Formatting Requirements

Binding.xml must be properly XML-formatted. Common issues:
- Missing closing tags
- Improper nesting
- Invalid characters in attribute values

## Complete Example Implementations

### Moonfire Casting Addon

A complete, working example of an addon that creates a keybinding to cast Moonfire:

#### File Structure
- MoonfireCaster/
  - MoonfireCaster.toc
  - MoonfireCaster.lua
  - Bindings.xml

#### TOC File (MoonfireCaster.toc)
```
## Interface: 110105
## Title: MoonfireCaster
## Notes: Simple addon to cast Moonfire (Spell ID 8921) with a keybind
## Author: You
## Version: 1.0
## SavedVariables: MoonfireCasterDB
## IconTexture: Interface\Icons\Spell_Nature_StarFall
MoonfireCaster.lua
```

**Note: Bindings.xml is not listed in the TOC file as WoW loads it automatically.**

#### Bindings.xml
```xml
<Bindings>
  <Binding name="CLICK MoonfireCasterButton:LeftButton" header="MOONFIRECASTER" category="ADDONS">
  </Binding>
</Bindings>
```

#### Lua File (MoonfireCaster.lua)
```lua
-- Define our binding globals
BINDING_HEADER_MOONFIRECASTER = "Moonfire Caster"
BINDING_NAME_CLICK_MoonfireCasterButton_LeftButton = "Cast Moonfire"

-- Create a frame for initialization
local frame = CreateFrame("Frame")

-- Create the secure button immediately
local button = CreateFrame("Button", "MoonfireCasterButton", UIParent, "SecureActionButtonTemplate")
button:SetAttribute("type", "macro")
button:SetAttribute("macrotext", "/cast Moonfire")
button:RegisterForClicks("AnyUp", "AnyDown")
button:SetSize(50, 50)
button:SetPoint("CENTER")

-- Initialize the addon
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent(event)

    -- Create a texture for the button
    local texture = button:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(button)
    texture:SetColorTexture(0, 0, 1, 0.5) -- Semi-transparent blue
    button:Show() -- Keep visible for testing

    -- Check if spell exists
    local spellInfo = C_Spell.GetSpellInfo(8921)
    if spellInfo and spellInfo.name then
        print("|cFF00FF00MoonfireCaster|r: Ready to cast " .. spellInfo.name)
    else
        print("|cFFFF0000MoonfireCaster|r: WARNING - Spell ID 8921 (Moonfire) not found")
    end

    print("|cFF00FF00MoonfireCaster|r: Addon loaded. You can:")
    print("1. Click the blue button directly")
    print("2. Use your keybind (set in ESC → Key Bindings → Addons)")
    print("3. Type /mfc cast to test via slash command")
end)

-- Create slash command
SLASH_MOONFIRECASTER1 = "/mfc"
SLASH_MOONFIRECASTER2 = "/moonfirecaster"

function SlashCmdList.MOONFIRECASTER(msg, editBox)
    msg = string.lower(msg or "")

    if msg == "help" or msg == "" then
        print("|cFF00FF00MoonfireCaster|r: Simple addon to cast Moonfire with a keybind")
        print("Set your keybind in the game's Keybinding menu (ESC → Key Bindings → Addons → Moonfire Caster)")
        print("Commands:")
        print("/mfc help - Show this help message")
        print("/mfc cast - Cast Moonfire by clicking the button")
        print("/mfc status - Show addon status")
        print("/mfc show - Make the button visible")
        print("/mfc hide - Hide the button")
        print("/mfc macro - Use macro approach (current)")
        print("/mfc spell - Use spell approach")
    elseif msg == "cast" then
        print("|cFF00FF00MoonfireCaster|r: Clicking button")
        if MoonfireCasterButton then
            MoonfireCasterButton:Click("LeftButton")
        else
            print("|cFFFF0000MoonfireCaster|r: Error - Button not found")
        end
    elseif msg == "status" then
        print("|cFF00FF00MoonfireCaster Status:|r")

        -- Button info
        print("Button exists: " .. (MoonfireCasterButton and "Yes" or "No"))
        if MoonfireCasterButton then
            local btnType = MoonfireCasterButton:GetAttribute("type")
            print("Button type: " .. (btnType or "nil"))
            if btnType == "spell" then
                print("Button spell: " .. (MoonfireCasterButton:GetAttribute("spell") or "nil"))
            elseif btnType == "macro" then
                print("Button macro: " .. (MoonfireCasterButton:GetAttribute("macrotext") or "nil"))
            end
            print("Button visible: " .. (MoonfireCasterButton:IsVisible() and "Yes" or "No"))
        end

        -- Check binding name in globals
        print("Binding name global: " .. (BINDING_NAME_CLICK_MoonfireCasterButton_LeftButton or "nil"))

        -- Check binding
        local bindingAction = "CLICK MoonfireCasterButton:LeftButton"
        local key = GetBindingKey(bindingAction)
        print("Binding action: " .. bindingAction)
        print("Bound to key: " .. (key or "None"))

        -- SpellInfo
        local spellInfo = C_Spell.GetSpellInfo(8921)
        if spellInfo and spellInfo.name then
            print("Spell check: " .. spellInfo.name)
            print("Spell ID: " .. (spellInfo.spellID or "unknown"))
        else
            print("Spell check: FAILED - Moonfire not found")
        end
    elseif msg == "show" then
        if MoonfireCasterButton then
            MoonfireCasterButton:Show()
            print("|cFF00FF00MoonfireCaster|r: Button is now visible")
        end
    elseif msg == "hide" then
        if MoonfireCasterButton then
            MoonfireCasterButton:Hide()
            print("|cFF00FF00MoonfireCaster|r: Button is now hidden")
        end
    elseif msg == "macro" then
        if MoonfireCasterButton then
            MoonfireCasterButton:SetAttribute("type", "macro")
            MoonfireCasterButton:SetAttribute("macrotext", "/cast Moonfire")
            print("|cFF00FF00MoonfireCaster|r: Using macro approach")
        end
    elseif msg == "spell" then
        if MoonfireCasterButton then
            MoonfireCasterButton:SetAttribute("type", "spell")
            MoonfireCasterButton:SetAttribute("spell", 8921)
            print("|cFF00FF00MoonfireCaster|r: Using spell approach")
        end
    end
end
```

### Smart Mount/Travel Form Implementation

A specialized implementation for druids that handles:
- Out of combat: Mount when standing, Travel Form when moving
- In combat: Use Travel Form outdoors, Cat Form indoors

```lua
-- Create movement-aware button for out of combat
smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
smartButton:SetSize(1, 1)
smartButton:SetPoint("CENTER")
smartButton:RegisterForClicks("AnyUp", "AnyDown")

-- Initially set to mount
smartButton:SetAttribute("type", "macro")
smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")

-- Create combat button with simple indoor/outdoor check
combatButton = CreateFrame("Button", "RMBCombatButton", UIParent, "SecureActionButtonTemplate")
combatButton:SetSize(1, 1)
combatButton:SetPoint("CENTER")
combatButton:RegisterForClicks("AnyUp", "AnyDown")

-- Simple combat macro for indoor/outdoor forms
local simpleCombatMacro = [[
-- Dismount if mounted
/dismount [mounted]

-- Use Cat Form if indoors
/cast [indoors] ]] .. catFormName .. [[

-- Use Travel Form if outdoors
/cast [outdoors] ]] .. travelFormName

combatButton:SetAttribute("type", "macro")
combatButton:SetAttribute("macrotext", simpleCombatMacro)

-- Track movement for out of combat button
updateFrame = CreateFrame("Frame")
updateFrame.elapsed = 0
updateFrame.lastMoving = false

updateFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed > 0.1 then
        self.elapsed = 0
        if InCombatLockdown() then return end

        local isMoving = IsPlayerMoving()
        if isMoving ~= self.lastMoving then
            self.lastMoving = isMoving
            if isMoving then
                smartButton:SetAttribute("type", "spell")
                smartButton:SetAttribute("spell", travelFormName)
            else
                smartButton:SetAttribute("type", "macro")
                smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
            end
        end
    end
end)

-- Create state handler for combat switching
stateHandler = CreateFrame("Button", "RMBStateHandler", UIParent, "SecureHandlerStateTemplate, SecureActionButtonTemplate")
stateHandler:SetSize(1, 1)
stateHandler:SetPoint("CENTER")
stateHandler:RegisterForClicks("AnyUp", "AnyDown")

-- Set frame references
stateHandler:SetFrameRef("outCombatButton", smartButton)
stateHandler:SetFrameRef("inCombatButton", combatButton)

-- Set up combat state driver
stateHandler:SetAttribute("_onstate-combat", [[
    local outCombatButton = self:GetFrameRef("outCombatButton")
    local inCombatButton = self:GetFrameRef("inCombatButton")

    if newstate == "1" then
        -- In combat
        self:SetAttribute("type", "click")
        self:SetAttribute("clickbutton", inCombatButton)
    else
        -- Out of combat
        self:SetAttribute("type", "click")
        self:SetAttribute("clickbutton", outCombatButton)
    end
]])

-- Initialize to out of combat
stateHandler:SetAttribute("type", "click")
stateHandler:SetAttribute("clickbutton", smartButton)

-- Register state driver for combat
RegisterStateDriver(stateHandler, "combat", "[combat] 1; 0")
```
