string greeting = "Greetings! Touch me to start playing!";
float soundVolume = 1.0;
vector textColor = <0.0, 1.0, 0.0>;
float OPAQUE = 1.0;
list songs; // Songs are other scripts in the object name {SONG}song_name.
string SONG_TAG = "{SONG}";
string looping = "off";
string settingsMenuName = "[ Settings ]";
list settingsMenu = ["Volume", "Looping", "[Back]"];
integer dialogListener;
integer DIALOG_CHANNEL = -99;
float DIALOG_TIMEOUT = 30.0;
string currentSongScript;
string currentSongTitle;
string currentSongCredits;

ResetGlobalState()
{
    if (currentSongScript != "")
    {
        llResetOtherScript(currentSongScript);
    }
    currentSongScript = "";
    currentSongTitle = "";
    currentSongCredits = "";
}

GetSongs()
{
    songs = [];
    integer count = llGetInventoryNumber(INVENTORY_SCRIPT);
    while (count--)
    {
        string scriptName = llGetInventoryName(INVENTORY_SCRIPT, count);
        integer scriptNameLength = llStringLength(scriptName);
        integer tagLength = llStringLength(SONG_TAG);
        if (llGetSubString(scriptName, 0, tagLength -1) == SONG_TAG)
        {
            songs += llGetSubString(scriptName, tagLength, scriptNameLength - 1);
        }
    }
}

integer isValidFloat(string s) { return (float)(s + "1") != 0.0; }

default
{
    state_entry()
    {
        ResetGlobalState();
        GetSongs();
        llSay(PUBLIC_CHANNEL, greeting);
        llSetText("", textColor, OPAQUE);
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            GetSongs();
        }
    }  

    listen(integer chan, string name, key id, string msg)
    {

        if (chan == DIALOG_CHANNEL)
        {
            llListenRemove(dialogListener);
            llSetTimerEvent(0.0);
            if (msg == settingsMenuName && id == llGetOwner())
            {
                state configuring;
            }
            else
            {
                currentSongScript = SONG_TAG + msg;
                list params = [currentSongScript, looping, soundVolume];
                llMessageLinked(LINK_THIS, 0, llDumpList2String(params, "|"), id);
                state waiting;
            }
        }
    }

    touch(integer total_number)
    {
        key av = llDetectedKey(0);
        list dialogButtons = songs;
        if (llGetOwner() == av)
        {
            // Access to the settings menu should be limited to the owner
            dialogButtons = dialogButtons + [ settingsMenuName ];
        }
        dialogListener = llListen(DIALOG_CHANNEL, "", av, "");
        llDialog(av, "\nSelect a song", songs + [ settingsMenuName ], DIALOG_CHANNEL);
        llSetTimerEvent(DIALOG_TIMEOUT);
    }

    timer()
    {
        llListenRemove(dialogListener);
    }
}

// This state is when a message has been sent to the song script and we are waiting for confirmation that it has started playing
state waiting
{
    state_entry()
    {
        llSetTimerEvent(DIALOG_TIMEOUT);
    }
    
    link_message(integer source, integer num, string msg, key id)
    {
        list params = llParseString2List(msg, ["|"], []);
        if (llList2String(params, 0) == "playing")
        {
            currentSongTitle = llList2String(params, 1);
            currentSongCredits = llList2String(params, 2);
            llSetTimerEvent(0.0);
            state playing;
        }
    }
    
    timer()
    {
        llSay(PUBLIC_CHANNEL, "Timeout waiting for script to respond");
        state default;
    }
}

state playing
{
    touch(integer total_number)
    {
        key av = llDetectedKey(0);
        llSetTimerEvent(DIALOG_TIMEOUT);
        dialogListener = llListen(DIALOG_CHANNEL, "", av, "");
        string dialogMessage = "Currently playing " + currentSongTitle + "\n" + currentSongCredits + "\n\nStop playing?";
        llDialog(av, dialogMessage, ["Yes", "No"], DIALOG_CHANNEL);
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        llSetTimerEvent(0.0);
        llListenRemove(dialogListener);
        if (msg == "Yes")
        {
            state default;
        }
    }
    
    link_message(integer source, integer num, string msg, key id)
    {
        if (msg == "done")
        {
            currentSongScript = ""; // This is to prevent the script from being reset when we go back to the default state
            state default;
        }
    }
    
    timer()
    {
        llListenRemove(dialogListener);
    }
}

// Used to access the configuration menu and various submenu items
state configuring
{
    state_entry()
    {
        // As we limit access to this feature to just the owner, it is reasonable to assume the dialog listener
        // should be bound to their av key
        key av = llGetOwner();
        dialogListener = llListen(DIALOG_CHANNEL, "", av, "");
        string settingsMessage = "Current settings\n" +
            "\tVolume: " + (string)soundVolume + "\n" +
            "\tLooping: " + looping + "\n\nSelect a setting to change";
        llDialog(av, settingsMessage, settingsMenu, DIALOG_CHANNEL);
        llSetTimerEvent(DIALOG_TIMEOUT);
    }
    
    listen(integer chan, string name, key id, string msg)
    {

        if (chan == DIALOG_CHANNEL)
        {
            llListenRemove(dialogListener);
            llSetTimerEvent(0.0);
            if (msg == "Volume")
            {
                state configure_volume;
            }
            else if (msg == "Looping")
            {
                state configure_looping;
            }
            else
            {
                state default;
            }
        }
    }
    
    timer()
    {
        llOwnerSay("Settings menu timed out.");
        llListenRemove(dialogListener);
        state default;
    }
}

state configure_volume
{
    state_entry()
    {
        // As we limit access to this feature to just the owner, it is reasonable to assume the dialog listener
        // should be bound to their av key
        key av = llGetOwner();
        dialogListener = llListen(DIALOG_CHANNEL, "", av, "");
        llTextBox(av, "Enter sound volume (between 0.0 and 1.0)", DIALOG_CHANNEL);
        llSetTimerEvent(DIALOG_TIMEOUT);
    }
    
    listen(integer chan, string name, key id, string msg)
    {

        if (chan == DIALOG_CHANNEL)
        {
            llListenRemove(dialogListener);
            llSetTimerEvent(0.0);
            if (isValidFloat(msg))
            {
                float inputValue = (float)msg;
                if (inputValue >= 0.0 && inputValue <= 1.0)
                {
                    soundVolume = inputValue;
                }
                else
                {
                    llInstantMessage(id, "Please enter a valid number between 0.0 and 1.0");
                }
            }
            else
            {
                llInstantMessage(id, "Please enter a valid number between 0.0 and 1.0");
            }
            state configuring;
        }
    }
    
    timer()
    {
        llOwnerSay("Settings menu timed out.");
        llListenRemove(dialogListener);
        state default;
    }
}

state configure_looping
{
    state_entry()
    {
        // As we limit access to this feature to just the owner, it is reasonable to assume the dialog listener
        // should be bound to their av key
        key av = llGetOwner();
        dialogListener = llListen(DIALOG_CHANNEL, "", av, "");
        llDialog(av, "Looping is currently set to " + looping + ". Turn on or off?", ["on", "off", "[Back]"], DIALOG_CHANNEL);
        llSetTimerEvent(DIALOG_TIMEOUT);
    }
    
    listen(integer chan, string name, key id, string msg)
    {

        if (chan == DIALOG_CHANNEL)
        {
            llListenRemove(dialogListener);
            llSetTimerEvent(0.0);
            if (msg != "[Back]")
            {
                looping = msg;
            }
            state configuring;
        }
    }
    
    timer()
    {
        llOwnerSay("Settings menu timed out.");
        llListenRemove(dialogListener);
        state default;
    }
}
