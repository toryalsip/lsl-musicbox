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
                llSay(PUBLIC_CHANNEL, "Playing " + msg);
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
        llInstantMessage(llGetOwner(), "Settings menu timed out.");
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
        llInstantMessage(llGetOwner(), "Settings menu timed out.");
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
        llInstantMessage(llGetOwner(), "Settings menu timed out.");
        llListenRemove(dialogListener);
        state default;
    }
}
