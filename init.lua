-- init.lua Poker 23rd Anniversary Quest Script
-- Author: jb321 - Remastered by: Cannonballdex

---@type Mq
local mq = require('mq')
local config = require('poker_config')
local gui = require('poker_gui')

local state = {
    settings = config.load(),
    running = true,
    gui_open = true,
    loop_count = 0,
    statusMessage = '',
    last_run_time_text = 'n/a',
}

local NoInvisClass = {'WAR', 'CLR', 'MNK', 'BER', 'PAL'}
local ShrinkRace = {'Barbarian', 'Vah Shir', 'Ogre', 'Troll'}
local ShrinkClick = {
    'Wand of Imperceptibility',
    'Anizok\'s Minimizing Device',
    'Bestial Sandals',
    'Boots of Beast Mastery',
    'Boots of the Beastlord',
    'Cobalt Bracer',
    'Earring of Diminutiveness',
    'Humanoid Reductionizer',
    'Ring of the Ancients',
    'Savage Boots',
    'Shimmering Bauble of Trickery',
    'Vial of Shrieker Essence',
    'Wild Lord\'s Sandals',
}
local PotClass = {'WAR', 'CLR', 'MNK', 'BER', 'PAL'}
local pots = 'Cloudy Potion'

local function printf(...)
    print(string.format(...))
end

local function Debug()
    return state.settings.Debug
end

local function Campfire()
    return state.settings.Campfire
end

local function CloudyPots()
    return state.settings.CloudyPots
end

local function Philter()
    return state.settings.Philter
end

local function Bulwark()
    return state.settings.Bulwark
end

local function Campfire_HighPassHold()
    return state.settings.Campfire_HighPassHold
end

local function LOOP()
    return state.settings.LOOP
end

local function hasValue(list, value)
    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end
    return false
end

local function shutdown()
    pcall(function()
        config.save(state.settings)
    end)
    pcall(function()
        mq.imgui.destroy('poker_gui')
    end)
end

mq.imgui.init('poker_gui', function()
    gui.draw(state, config)
end)

local function DeleteEmptyBulwark()
    local itemName = 'Bulwark of Many Portals'

    local item = mq.TLO.FindItem('=' .. itemName)
    if not item() then
        return false
    end

    local charges = item.Charges() or 0
    if charges > 0 then
        return false
    end

    if mq.TLO.Me.Hovering() or mq.TLO.Me.Casting() then
        return false
    end

    if Debug() then
        print('\at DEBUG - DELETING EMPTY BULWARK')
    end

    if mq.TLO.Cursor.ID() ~= nil then
        if Debug() then
            printf('DEBUG - Clearing cursor: %s', mq.TLO.Cursor.Name())
        end
        mq.cmd('/autoinventory')
        mq.delay('500ms')
    end

    mq.cmdf('/ctrl /itemnotify "%s" leftmouseup', itemName)
    mq.delay('1s')

    if mq.TLO.Cursor.Name() == itemName then
        mq.cmd('/destroy')
        mq.delay('500ms')
        print('\arDestroyed:\ay (Empty) \apBulwark of Many Portals')
        return true
    end

    return false
end

local function zoning(z_id)
    if Debug() then print('\at DEBUG - WAITING ON ZONE') end

    mq.delay('5s')

    while mq.TLO.Me.Moving() do
        mq.delay(10)
    end

    ::DoorClick::

    if mq.TLO.Navigation.Velocity() == 0 then
        mq.delay('5s')
    end

    mq.delay('5s')

    if mq.TLO.Zone.ID() == z_id then
        return
    end

    if mq.TLO.Navigation.Velocity() == 0 and mq.TLO.Zone.ID() ~= z_id and mq.TLO.NearestSpawn('PC')() ~= nil then
        if Debug() then print('\at POKSWITCH FAILED - TRAVELING TO') end
        if z_id == 202 then
            mq.cmd('/travelto poknowledge')
        end
        if z_id == 383 then
            mq.cmd('/travelto freeportwest')
        end
        if z_id == 2 then
            mq.cmd('/dismount')
            mq.cmd('/travelto qeynos2')
        end
    end

    while mq.TLO.Zone.ID() ~= z_id or mq.TLO.NearestSpawn('PC')() == nil do
        goto DoorClick
    end
end

local function moving()
    if Debug() then print('\at DEBUG - MOVING') end
    mq.delay(500)
    while mq.TLO.Navigation.Active() do
        mq.delay(100)
    end
    mq.delay('2s')
end

local function NeedPotions()
    if not CloudyPots() then
        return
    end

    for i = 1, #PotClass do
        if mq.TLO.Me.Class.ShortName() == PotClass[i] and mq.TLO.FindItemCount(14514)() < 20 then
            if mq.TLO.Zone.ID() ~= 202 then
                print('You need Cloudy Potions')
                mq.cmd('/travelto poknowledge')
                mq.delay(500)
                zoning(202)
                mq.delay(1000)
            end

            if mq.TLO.Zone.ID() == 202 then
                mq.cmd('/nav spawn Mirao Frostpouch')
                while mq.TLO.Navigation.Active() do
                    mq.delay(10)
                end

                mq.cmd('/tar Mirao Frostpouch')
                mq.delay(500)
                mq.cmd('/usetarget')
                mq.delay(500)

                mq.TLO.Merchant.SelectItem('=' .. pots)
                mq.delay(1000)
                mq.TLO.Merchant.Buy(20)

                mq.TLO.Merchant.SelectItem('=' .. pots)
                mq.delay(1000)
                mq.TLO.Merchant.Buy(20)

                mq.TLO.Merchant.SelectItem('=' .. pots)
                mq.delay(1000)
                mq.TLO.Merchant.Buy(20)

                mq.TLO.Merchant.SelectItem('=' .. pots)
                mq.delay(1000)
                mq.TLO.Merchant.Buy(20)

                mq.TLO.Merchant.SelectItem('=' .. pots)
                mq.delay(1000)
                mq.TLO.Merchant.Buy(20)

                mq.cmd('/notify MerchantWnd "MW_Done_Button" leftmouseup')

                if mq.TLO.FindItemCount(14514)() > 1 then
                    print('Much Safer With Cloudy Potions')
                end
            end
        end
    end
end

local function ShrinkClicky()
    local race = mq.TLO.Me.Race()
    if hasValue(ShrinkRace, race) and mq.TLO.Me.Height() > 2.88 then
        for _, item in ipairs(ShrinkClick) do
            local clicky = mq.TLO.FindItem(item)()
            if clicky then
                if Debug() then print('\at DEBUG - CHECKING FOR SHRINK CLICKY') end
                mq.cmdf('/useitem "%s"', clicky)
                while mq.TLO.Me.Casting() do
                    mq.delay(100)
                end
                break
            end
        end
    end

    if mq.TLO.Me.Class.ShortName() == 'BER' and mq.TLO.Me.Height() > 2.88 then
        mq.cmd('/useitem Wand')
        mq.delay('9s')
    end

    if mq.TLO.Me.Class.ShortName() == 'BST' and mq.TLO.Me.Height() > 2.88 then
        mq.cmd('/alt act 3709')
        mq.delay(3500)
        mq.cmd('/alt act 7025')
        mq.delay(3500)
        mq.cmd('/alt act 980')
        mq.delay(1000)
    end

    if mq.TLO.Me.Class.ShortName() == 'SHM' and mq.TLO.Me.Height() > 2.88 then
        mq.cmd('/alt act 9503')
        mq.delay(3500)
        mq.cmd('/alt act 630')
        mq.delay(1500)
    end
end

local function UseCloudyPotion()
    local className = mq.TLO.Me.Class.ShortName()
    local needsPotion = hasValue(NoInvisClass, className)

    if mq.TLO.Me.Invis() == false and needsPotion then
        if Debug() then print('\at DEBUG - USING CLOUDY POT') end
        mq.cmd('/useitem "Cloudy Potion"')
        mq.cmd('/removelev')
    end
end

local function BardSelos()
    if mq.TLO.Me.Class.ShortName() == 'BRD' then
        if Debug() then print('\at DEBUG - USING BARD SELOS') end
        if mq.TLO.Me.Buff('Selo\'s Accelerato')() == nil and mq.TLO.Me.Buff('Selo\'s Accelerando')() == nil then
            if mq.TLO.Me.AltAbilityReady('Selo\'s Sonata')() then
                mq.cmd('/alt activate 3704')
            end
        end
    end
end

local function CastGate()
    if Debug() then print('\at DEBUG - USING GATE') end

    if mq.TLO.Zone.ID() ~= 202 and mq.TLO.Me.AltAbilityReady('Gate')() and mq.TLO.Me.ZoneBound.ID() == 202 then
        mq.cmd('/alt act 1217')
        mq.delay(10000)
        repeat
            while mq.TLO.Zone.ID() ~= 202 and not mq.TLO.Me.Casting() do
                mq.cmd('/alt act 1217')
                mq.delay(10000)
            end
        until mq.TLO.Zone.ID() == 202
        zoning(202)
    end

    if Philter() and mq.TLO.Zone.ID() ~= 202 and mq.TLO.FindItem('Philter of Major Translocation')() and mq.TLO.Me.ZoneBound.ID() == 202 and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then print('\at DEBUG - USING GATE POT') end
        mq.cmd('/casting "Philter of Major Translocation" Item')
        mq.delay(12000)
        repeat
            while mq.TLO.Zone.ID() ~= 202 and not mq.TLO.Me.Casting() do
                mq.delay(10500)
                mq.cmd('/casting "Philter of Major Translocation" Item')
            end
        until mq.TLO.Zone.ID() == 202
        zoning(202)
    end

    DeleteEmptyBulwark()

    local bulwark = mq.TLO.FindItem('=Bulwark of Many Portals')
    local bulwarkCharges = 0
    if bulwark() then
        bulwarkCharges = bulwark.Charges() or 0
    end

    if Bulwark()
        and mq.TLO.Zone.ID() ~= 202
        and bulwark()
        and bulwarkCharges > 0
        and mq.TLO.Me.ZoneBound.ID() == 202
        and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then
            printf('\at DEBUG - USING BULWARK (%d charges left)', bulwarkCharges)
        end

        mq.cmd('/casting "Bulwark of Many Portals" Item')
        mq.delay('1s')

        repeat
            while mq.TLO.Zone.ID() ~= 202 and not mq.TLO.Me.Casting() do
                DeleteEmptyBulwark()

                bulwark = mq.TLO.FindItem('=Bulwark of Many Portals')
                if not bulwark() then
                    if Debug() then
                        print('\at DEBUG - BULWARK NO LONGER EXISTS')
                    end
                    return
                end

                bulwarkCharges = bulwark.Charges() or 0
                if bulwarkCharges < 1 then
                    DeleteEmptyBulwark()
                    if Debug() then
                        print('\at DEBUG - BULWARK OUT OF CHARGES')
                    end
                    return
                end

                mq.cmd('/casting "Bulwark of Many Portals" Item')
                mq.delay('10s')
            end
        until mq.TLO.Zone.ID() == 202

        zoning(202)
    end
end

local function UseInvisSpell()
    if Debug() then print('\at DEBUG - FIND INVIS SPELL') end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'BST' then
        mq.cmd('/alt act 980')
        mq.delay(1000)
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'BRD' then
        if mq.TLO.Me.AltAbilityReady('Shauri\'s Sonorous Clouding')() then
            mq.cmd('/alt act 3704')
            mq.delay(2000)
            mq.cmd('/alt act 231')
            mq.delay(2000)
            mq.cmd('/removelev')
        else
            if mq.TLO.Me.Buff('Shauri\'s Sonorous Clouding')() == nil then
                mq.cmd('/cast "Shauri\'s Sonorous Clouding"')
                mq.delay('2s')
            end
        end
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'SHM' then
        mq.cmd('/alt act 630')
        mq.delay(1500)
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'MAG' then
        mq.cmd('/alt act 1210')
        mq.delay(1000)
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'WIZ' then
        mq.cmd('/alt act 1210')
        mq.delay(1000)
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'SHD' then
        mq.cmd('/alt act 531')
        mq.delay(1000)
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'NEC' then
        mq.cmd('/alt act 531')
        mq.delay(1000)
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'DRU' then
        mq.cmd('/alt act 80')
        mq.delay(1000)
    end

    if mq.TLO.Me.Invis() == false and mq.TLO.Me.Class.ShortName() == 'RNG' then
        mq.cmd('/alt act 80')
        mq.delay(1000)
    end

    if mq.TLO.Me.Invis('SOS')() == false and mq.TLO.Me.Class.ShortName() == 'ROG' then
        if Debug() then print('\at DEBUG - ROG SNEAK HIDE') end
        mq.cmd('/makemevisible')
        mq.cmd('/removelev')

        if mq.TLO.Me.Sneaking() == false then
            while mq.TLO.Me.AbilityReady('Sneak')() == false do
                mq.delay(10)
            end
            mq.cmd('/doability sneak')
        end

        while mq.TLO.Me.AbilityReady('Hide')() == false do
            mq.delay(10)
        end
        mq.cmd('/doability hide')
    end

    mq.delay('1s')
    mq.cmd('/removelev')
end

local function Mount()
    if mq.TLO.Me.Class.ShortName() ~= 'BRD' then
        if mq.TLO.Me.Class.ShortName() ~= 'ROG' then
            mq.cmd('/useitem ${Me.Inventory[Ammo]}')
            while mq.TLO.Me.Casting() do
                mq.delay(10)
            end
            UseCloudyPotion()
            UseInvisSpell()
        end

        if mq.TLO.Me.Class.ShortName() == 'ROG' then
            mq.cmd('/useitem ${Me.Inventory[Ammo]}')
            UseInvisSpell()
        end
    end
end

local function runQuest()
    if mq.TLO.FindItem('Philter of Major Translocation')() then
        printf('You have %s Gate Potions', mq.TLO.FindItemCount('Philter of Major Translocation')())
    else
        print('You have no gate potions')
    end

    if mq.TLO.FindItem('Cloudy Potion')() then
        printf('You have %s Cloudy Potions', mq.TLO.FindItemCount('Cloudy Potion')())
    else
        print('You have no Cloudy Potions')
    end

    DeleteEmptyBulwark()

    if mq.TLO.Me.ZoneBound.ID() ~= 202 then
        print('You will not be able to use gate for this script unless you bind in POK')
    end

    mq.cmd('/popup Starting: Paintings Playing Poker 23rd Anniversary Quest')
    NeedPotions()

    local start_time = os.time()

    if Campfire() and mq.TLO.Zone.ID() == 202 and mq.TLO.Me.Fellowship() ~= nil and mq.TLO.Me.Fellowship.Campfire() == false and not mq.TLO.Me.Hovering() and mq.TLO.SpawnCount('radius 50 fellowship')() < 3 then
        mq.cmd('/squelch /nav locyxz 24.25 -357.18 -156')
        moving()
    end

    while Campfire() and mq.TLO.Zone.ID() == 202 and mq.TLO.Me.Fellowship() ~= nil and mq.TLO.Me.Fellowship.Campfire() == false and not mq.TLO.Me.Hovering() and mq.TLO.SpawnCount('radius 50 fellowship')() < 3 do
        print('\ayWaiting on group to drop a campfire')
        mq.delay('5s')
    end

    if Campfire() and mq.TLO.Me.Fellowship() ~= nil and mq.TLO.Me.Fellowship.Campfire() == false and mq.TLO.SpawnCount('radius 50 fellowship')() > 2 then
        mq.cmd('/windowstate FellowshipWnd open')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_Subwindows tabselect 2')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_RefreshList leftmouseup')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_CampsiteKitList listselect 1')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_CreateCampsite leftmouseup')
        mq.delay(500)
        mq.cmd('/windowstate FellowshipWnd close')
        mq.delay(500)
        print('\agDropped a Campfire')
        mq.delay(500)
    end

    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/removelev')

    if Debug() then print('\at DEBUG - TRAVEL FREEPORT WEST') end

    mq.cmd('/squelch /travelto freeportwest')
    mq.delay(500)
    zoning(383)
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/removelev')

    if Debug() then print('\at DEBUG - NAV SPAWN SLICK') end

    mq.cmd('/nav locxyz 161 2 -52')
    moving()
    mq.cmd('/tar slick')
    mq.delay(500)
    mq.cmd('/keypress h')
    mq.delay(500)
    mq.cmd('/keypress h')
    mq.delay(500)
    mq.cmd('/say paintings')
    mq.delay(500)
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/removelev')
    mq.cmd('/squelch /nav locyxz -177 -415 -85')
    moving()

    if Debug() then print('\at DEBUG - TRAVEL FREEPORT EAST') end

    mq.cmd('/travelto freeporteast')
    mq.delay(500)
    zoning(382)
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/removelev')

    if Debug() then print('\at DEBUG - NAV SPAWN BLUFFIN') end

    mq.cmd('/nav spawn bluffin')
    moving()
    mq.cmd('/tar bluffin')
    mq.delay(1000)
    mq.cmd('/keypress hail')
    mq.delay(1000)
    mq.cmd('/autoinv')
    mq.delay(1000)

    if Debug() then print('\at DEBUG - DRINK MEMENTO GROG') end

    if mq.TLO.FindItem('Memento Grog')() then
        mq.cmd('/useitem "Memento Grog"')
    end

    if mq.TLO.Me.Level() >= 105 and mq.TLO.FindItem('Zueria Slide: Nektulos')() and mq.TLO.FindItem('Zueria Slide: Nektulos').TimerReady() == 0 then
        if mq.TLO.Me.Height() < 4 then
            mq.cmd('/nav loc 214.33 -881.32 8.26')
            moving()
        end

        ::TryAgainSlideToNektulos::
        mq.cmd('/useitem "Zueria Slide: Nektulos"')
        if mq.TLO.Zone.ID() == 382 and not mq.TLO.Me.Casting() then
            mq.cmd('/useitem "Zueria Slide: Nektulos"')
            mq.delay('22s')
        end
        if mq.TLO.Zone.ID() == 382 then
            goto TryAgainSlideToNektulos
        end
        mq.delay('22s')
        zoning(25)
    else
        CastGate()
        ShrinkClicky()
        BardSelos()
        UseCloudyPotion()
        UseInvisSpell()
        mq.cmd('/removelev')

        if mq.TLO.Zone.ID() ~= 202 then
            if Debug() then print('\at DEBUG - TRAVEL POK') end
            mq.cmd('/travelto poknowledge')
            mq.delay(500)
            zoning(202)
        end

        if Debug() then print('\at DEBUG - TRAVEL NEKTULOS') end

        UseCloudyPotion()
        UseInvisSpell()
        mq.cmd('/travelto nektulos')
        mq.delay(500)
        zoning(25)
        UseCloudyPotion()
        UseInvisSpell()
    end

    if Debug() then print('\at DEBUG - TRAVEL NERIAKA') end
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/travelto neriaka')
    mq.delay(500)
    zoning(40)
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/removelev')
    mq.cmd('/squelch /nav locyx -352 -207')
    moving()

    if Debug() then print('\at DEBUG - NAV SPAWN SLUG') end

    mq.cmd('/nav spawn slug')
    moving()

    if Debug() then print('\at DEBUG - TRAVEL NERIAKB') end

    mq.cmd('/travelto neriakb')
    mq.delay(500)
    zoning(41)
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/removelev')

    if Debug() then print('\at DEBUG - NAV SPAWN MAREN') end

    mq.cmd('/nav spawn maren')
    moving()
    mq.cmd('/squelch /nav locyx -149 -993')
    moving()
    mq.cmd('/travelto neriaka')
    mq.delay(500)
    zoning(40)
    mq.delay('5s')

    if Debug() then print('\atCHECKING STATUS OF CAMPFIRE IS MY INSIGNIA READY? IF NO CAMPFIRE MOVE ON OR WAIT FOR INSIGNIA READY') end

    if mq.TLO.FindItem('Fellowship Registration Insignia')() then
        if Debug() then
            printf('Insignia Ready in %s Seconds', mq.TLO.FindItem('Fellowship Registration Insignia').TimerReady())
        end
    end

    if Campfire_HighPassHold() and mq.TLO.Me.Fellowship() ~= nil and not mq.TLO.Me.Fellowship.Campfire() then
        if Debug() then print('\at DEBUG - NO CAMPFIRE UP USE MOUNT AND TRAVEL HIGHPASSHOLD') end
        Mount()
        if mq.TLO.Zone.ID() == 40 then
            if Debug() then print('\at DEBUG - NO CAMPFIRE TRAVEL TO MOORS') end
            UseCloudyPotion()
            UseInvisSpell()
            mq.delay('2s')
            mq.cmd('/travelto moors')
            mq.delay(500)
            zoning(395)
            mq.delay(500)
        end
    end

    while Campfire_HighPassHold()
        and mq.TLO.Me.Fellowship() ~= nil
        and mq.TLO.Me.Fellowship.Campfire()
        and mq.TLO.FindItem('Fellowship Registration Insignia')()
        and mq.TLO.FindItem('Fellowship Registration Insignia').TimerReady() ~= 0
        and mq.TLO.Zone.ID() == 40 do
        mq.delay(1000)
    end

    if (
        Campfire_HighPassHold()
        and mq.TLO.Me.Fellowship() ~= nil
        and mq.TLO.Me.Fellowship.Campfire()
        and mq.TLO.FindItem('Fellowship Registration Insignia')()
        and mq.TLO.FindItem('Fellowship Registration Insignia').TimerReady() == 0
        and not mq.TLO.Me.Hovering()
        and mq.TLO.Zone.ID() == 40
    ) or (
        Campfire_HighPassHold()
        and mq.TLO.Me.Fellowship() ~= nil
        and mq.TLO.Me.Fellowship.Campfire() == nil
        and not mq.TLO.Me.Hovering()
        and mq.TLO.Zone.ID() == 40
    ) then
        if Debug() then print('\at DEBUG - ATTEMPTING FELLOWSHIP TO HIGHPASSHOLD') end

        if mq.TLO.Me.Fellowship() ~= nil
            and mq.TLO.Me.Fellowship.Campfire()
            and mq.TLO.FindItem('Fellowship Registration Insignia')()
            and mq.TLO.FindItem('Fellowship Registration Insignia').TimerReady() == 0 then
            mq.cmd('/makemevisible')
            mq.cmd('/casting "Fellowship Registration Insignia" Item -maxtries|2')
            mq.delay('10s')
            while mq.TLO.Zone.ID() == 40 do
                mq.cmd('/casting "Fellowship Registration Insignia" Item -maxtries|2')
                mq.delay(1000)
            end
            zoning(407)
        end

        if mq.TLO.Zone.ID() == 40 then
            if Debug() then print('\at DEBUG - NO CAMPFIRE TRAVEL TO MOORS') end
            UseCloudyPotion()
            UseInvisSpell()
            mq.delay('2s')
            if mq.TLO.Me.Class.ShortName() ~= 'BRD' then
                mq.cmd('/travelto moors')
                mq.delay(500)
                zoning(395)
            end
        end
    end

    if Campfire_HighPassHold() and mq.TLO.Zone.ID() == 395 then
        Mount()
    end

    if (not Campfire_HighPassHold()) or mq.TLO.Zone.ID() ~= 407 then
        if Debug() then print('\at DEBUG - NOT USING CAMPFIRE HIGHPASSHOLD TRAVEL HIGHPASSHOLD') end
        BardSelos()
        Mount()
        mq.cmd('/travelto highpasshold')
        mq.delay(500)
        zoning(407)
        mq.delay('2s')
    end

    if mq.TLO.Zone.ID() ~= 407 then
        if Debug() then print('\at DEBUG - NO CAMPFIRE TRYING TO MAKE IT TO HIGHPASSHOLD') end
        mq.cmd('/travelto highpasshold')
        mq.delay(500)
        zoning(407)
    end

    if Debug() then print('\at DEBUG - DISMOUNT AND REMOVE LEV') end

    while mq.TLO.Zone.ID() ~= 407 do
        mq.delay(100)
    end

    if mq.TLO.Zone.ID() == 407 then
        mq.cmd('/dismount')
        ShrinkClicky()
        BardSelos()
        UseCloudyPotion()
        UseInvisSpell()
        mq.cmd('/removelev')
    end

    if Campfire_HighPassHold() and mq.TLO.Zone.ID() == 407 and mq.TLO.Me.Fellowship() ~= nil and mq.TLO.Me.Fellowship.Campfire() == false and not mq.TLO.Me.Hovering() and mq.TLO.SpawnCount('radius 50 fellowship')() < 3 then
        mq.cmd('/squelch /nav locyxz -132 -342 -25.20')
        moving()
    end

    while Campfire_HighPassHold() and mq.TLO.Zone.ID() == 407 and mq.TLO.Me.Fellowship() ~= nil and mq.TLO.Me.Fellowship.Campfire() == false and not mq.TLO.Me.Hovering() and mq.TLO.SpawnCount('radius 50 fellowship')() < 3 do
        print('\ayWaiting on group to drop a campfire')
        mq.delay(1000)
    end

    if Campfire_HighPassHold() and mq.TLO.Me.Fellowship() ~= nil and mq.TLO.Me.Fellowship.Campfire() == false and mq.TLO.SpawnCount('radius 50 fellowship')() > 2 then
        mq.cmd('/windowstate FellowshipWnd open')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_Subwindows tabselect 2')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_RefreshList leftmouseup')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_CampsiteKitList listselect 1')
        mq.delay(500)
        mq.cmd('/nomodkey /notify FellowshipWnd FP_CreateCampsite leftmouseup')
        mq.delay(500)
        mq.cmd('/windowstate FellowshipWnd close')
        mq.delay(500)
        print('\agDropped a Campfire')
        mq.delay(500)
    end

    mq.delay('2s')

    if Debug() then print('\at DEBUG - DISMOUNT AND REMOVE LEV') end

    mq.cmd('/dismount')
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.delay(1000)
    mq.cmd('/removelev')
    mq.cmd('/dismount')

    if Debug() then print('\at DEBUG - NAV SPAWN QUADS') end

    mq.cmd('/nav spawn quads')
    moving()
    mq.cmd('/tar quads')
    mq.delay(500)
    mq.cmd('/keypress hail')
    mq.cmd('/squelch /nav locyxz -436 -229 -12')
    moving()
    mq.cmd('/squelch /nav locyx -432 -257')
    moving()
    mq.cmd('/nav locyxz -414 -264 -11')
    moving()

    if Debug() then print('\at DEBUG - NAV SPAWN QUEEN') end

    mq.cmd('/nav spawn queen')
    moving()
    mq.cmd('/tar queen')
    mq.delay(500)
    mq.cmd('/keypress hail')
    mq.delay(500)
    mq.cmd('/nav loc -385.69 -272.41 -11')
    moving()
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/squelch /nav locyxz -436 -229 -12')
    moving()

    if Debug() then print('\at DEBUG - NAV SPAWN POKER') end

    mq.cmd('/nav spawn poker')
    moving()
    mq.cmd('/nav locyxz -124 538 -11')
    moving()
    mq.cmd('/nav locyxz -119 550 -12')
    moving()
    mq.cmd('/nav locyxz -26 407 -18')
    moving()

    ::TryAgainHighPass::

    if mq.TLO.FindItem('Drunkard\'s Stein')() ~= nil and mq.TLO.FindItem('Drunkard\'s Stein').TimerReady() == 0 and not mq.TLO.Me.Hovering() and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then print('\at DEBUG - ATTEMPTING DRUNKARD STEIN') end
        mq.cmd('/useitem "Drunkard\'s Stein"')
        mq.delay('2s')
        if mq.TLO.Zone.ID() == 407 then
            if Debug() then print('\at DEBUG - STILL IN HIGHPASSHOLD TRAVEL POK') end
            Mount()
            mq.cmd('/travelto poknowledge')
            mq.delay(500)
            zoning(202)
        end
    end

    if mq.TLO.Zone.ID() == 407 then
        if Debug() then print('\at DEBUG - STILL IN HIGHPASSHOLD TRY GATE') end
        CastGate()
        mq.delay('10s')
    end

    if mq.TLO.Me.Level() >= 105 and mq.TLO.Zone.ID() == 407 and mq.TLO.FindItem('Zueria Slide: Nektulos')() ~= nil and mq.TLO.FindItem('Zueria Slide: Nektulos').TimerReady() == 0 and not mq.TLO.Me.Hovering() and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then print('\at DEBUG - ATTEMPTING ZUERIA SLIDE') end
        mq.cmd('/useitem "Zueria Slide: Nektulos"')
        while mq.TLO.Zone.ID() == 407 and not mq.TLO.Me.Casting() do
            mq.delay(1000)
            mq.cmd('/casting "Zueria Slide: Nektulos" Item')
        end
        mq.delay('22s')
        if mq.TLO.Zone.ID() == 407 then
            goto TryAgainHighPass
        end
        zoning(25)
    else
        if Debug() then print('\at DEBUG - TRAVEL POK') end
        CastGate()
        Mount()
        mq.cmd('/travelto poknowledge')
        mq.delay(500)
        zoning(202)
    end

    if Debug() then print('\atCHECKING STATUS OF CAMPFIRE IS MY INSIGNIA READY? IF NO CAMPFIRE MOVE ON OR WAIT FOR INSIGNIA READY') end
    if mq.TLO.FindItem('Fellowship Registration Insignia')() then
        if Debug() then
            printf('Insignia Ready in %s Seconds', mq.TLO.FindItem('Fellowship Registration Insignia').TimerReady())
        end
    end

    while Campfire()
        and mq.TLO.Me.Fellowship() ~= nil
        and mq.TLO.Me.Fellowship.Campfire()
        and mq.TLO.FindItem('Fellowship Registration Insignia')()
        and mq.TLO.FindItem('Fellowship Registration Insignia').TimerReady() ~= 0
        and mq.TLO.Me.AltAbility('Gate')() == nil do
        mq.delay(1000)
    end

    if mq.TLO.Zone.ID() == 407
        and Campfire()
        and mq.TLO.Me.Fellowship() ~= nil
        and mq.TLO.Me.Fellowship.Campfire()
        and mq.TLO.FindItem('Fellowship Registration Insignia')()
        and mq.TLO.FindItem('Fellowship Registration Insignia').TimerReady() == 0
        and not mq.TLO.Me.Hovering()
        and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then print('\at DEBUG - TRY FELLOWSHIP BACK TO POK') end
        mq.cmd('/makemevisible')
        mq.cmd('/casting "Fellowship Registration Insignia" Item -maxtries|2')
        mq.delay(1000)
        if mq.TLO.Zone.ID() == 407 then
            Mount()
            if Debug() then print('\at DEBUG - FELLOWSHIP FAILED TRAVEL POK') end
            mq.cmd('/travelto poknowledge')
            mq.delay(500)
            zoning(202)
        end
    end

    if mq.TLO.Zone.ID() == 407 and mq.TLO.Me.AltAbilityReady('Throne of Heroes')() and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then print('\at DEBUG - TRY THRONE OF HEROES') end
        mq.cmd('/alt act 511')
        mq.delay(1000)
        while mq.TLO.Me.Casting() do
            mq.delay(100)
        end
        while mq.TLO.Me.CombatState() ~= 'ACTIVE' do
            mq.cmd('/alt act 511')
            mq.delay(100)
        end
        mq.delay(31000)

        if mq.TLO.Zone.ID() ~= 202 and mq.TLO.Zone.ID() ~= 344 then
            if Debug() then print('\at DEBUG - THRONE FAILED TRAVEL POK') end
            if mq.TLO.Zone.ID() == 407 then
                Mount()
            end
            if mq.TLO.Zone.ID() == 344 then
                mq.cmd('/dismount')
            end
            mq.cmd('/travelto poknowledge')
            mq.delay(500)
            zoning(202)
        end
    end

    if mq.TLO.Zone.ID() == 407 then
        mq.cmd('/dismount')
        if Debug() then print('\at DEBUG - ALL TELEPORT FAILED TRAVEL TO QEYNOS2') end
        Mount()
        if Debug() then print('\at DEBUG - TRAVEL QEYNOS2') end
        mq.cmd('/travelto qeynos2')
        mq.delay(500)
        zoning(2)
        mq.delay(500)
        mq.cmd('/dismount')
    end

    if Debug() then print('\at DEBUG - TRAVEL QEYNOS2 CHECK') end

    if mq.TLO.Zone.ID() ~= 2 then
        mq.cmd('/dismount')
        mq.cmd('/travelto qeynos2')
        mq.delay(500)
        zoning(2)
        mq.delay(500)
        mq.cmd('/dismount')
    end

    if Debug() then print('\at DEBUG - DISMOUNT') end

    mq.delay(500)
    ShrinkClicky()
    BardSelos()
    mq.cmd('/dismount')
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/nav locyxz 118 335 1')
    moving()

    if Debug() then print('\at DEBUG - TRAVEL QEYNOS') end

    mq.cmd('/travelto qeynos')
    mq.delay(500)
    zoning(1)
    ShrinkClicky()
    BardSelos()
    UseCloudyPotion()
    UseInvisSpell()
    mq.cmd('/squelch /nav locyxz -282 -230 2')
    moving()
    mq.cmd('/squelch /nav locyxz 311 -173 4')
    moving()

    if mq.TLO.Me.AltAbilityReady('Gate')() and mq.TLO.Me.ZoneBound.ID() == 202 then
        if Debug() then print('\at DEBUG - ATTEMPTING GATE') end
        mq.cmd('/alt act 1217')
        mq.delay('10s')
        repeat
            while mq.TLO.Zone.ID() ~= 202 and not mq.TLO.Me.Casting() do
                mq.delay(1000)
                mq.cmd('/alt act 1217')
                mq.delay('10s')
            end
        until mq.TLO.Zone.ID() == 202
        zoning(202)
    end

    if Philter() and mq.TLO.FindItem('Philter of Major Translocation')() and mq.TLO.Me.ZoneBound.ID() == 202 and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then print('\at DEBUG - ATTEMPTING PHILTER GATE') end
        mq.cmd('/casting "Philter of Major Translocation" Item')
        mq.delay('12s')
        repeat
            while mq.TLO.Zone.ID() ~= 202 and not mq.TLO.Me.Casting() do
                mq.delay(10500)
                mq.cmd('/casting "Philter of Major Translocation" Item')
                mq.delay('10s')
            end
        until mq.TLO.Zone.ID() == 202
        zoning(202)
    end

    if Bulwark() and mq.TLO.FindItem('Bulwark of Many Portals')() and mq.TLO.Me.ZoneBound.ID() == 202 and mq.TLO.Me.AltAbility('Gate')() == nil then
        if Debug() then print('\at DEBUG - ATTEMPTING BULWARK') end
        mq.cmd('/casting "Bulwark of Many Portals" Item')
        mq.delay('5s')
        repeat
            while mq.TLO.Zone.ID() ~= 202 and not mq.TLO.Me.Casting() do
                mq.cmd('/casting "Bulwark of Many Portals" Item')
                mq.delay('5s')
            end
        until mq.TLO.Zone.ID() == 202
        zoning(202)
    end

    if Debug() then print('\at DEBUG - TRAVEL POK') end

    mq.cmd('/travelto poknowledge')
    mq.delay(500)
    zoning(202)
    NeedPotions()

    if Debug() then print('\at DEBUG - TRAVEL FREEPORT WEST') end

    mq.cmd('/travelto freeportwest')
    mq.delay(500)
    zoning(383)

    if Debug() then print('\at DEBUG - NAV SPAWN SLICK - FINAL HAIL') end

    mq.cmd('/nav locxyz 161 2 -52')
    moving()
    mq.cmd('/tar slick')
    mq.delay(500)
    mq.cmd('/keypress hail')
    mq.delay(500)
    mq.cmd('/say paintings')
    mq.delay(500)

    local end_time = os.time()
    local elapsed = end_time - start_time
    state.last_run_time_text = tostring(elapsed) .. ' Seconds'
    print('Quest Run Time... ' .. elapsed .. ' Seconds')

    state.loop_count = state.loop_count + 1
    printf('Playing Poker completed %s times', state.loop_count)
end

local ok, err = xpcall(function()
    while state.running do
        runQuest()

        if not LOOP() then
            break
        end

        mq.doevents()
        mq.delay(10)
    end
end, debug.traceback)

shutdown()

if not ok then
    print('\ar[poker] Script crashed:')
    print('\ar' .. tostring(err))
end