key notecardQueryId; //Identifier for the dataserver event
integer notecardLine; //Initialize the counter value at 0
key notecardKey; //Store the notecard's key, so we don't read it again by accident.
string greeting = "Greetings! Touch me to start playing!";
string preparingText= "Preparing music...";
string songTitle;
float soundVolume = 1.0;
vector textColor = <0.0, 1.0, 0.0>;
float OPAQUE = 1.0;
list songs; // Each notecard will be treated as a song
list audioClips; // place UUIDs or names of the audio clips here. If using names, they must reside in the object's inventory
integer totalClips;
float maxClipDuration = 29.9; // Needs to match the length of other clips
float finalClipDuration = 29.9; // Needs to match the length of the final clip
string looping = "off";
string settingsMenuName = "[ Settings ]";
list settingsMenu = ["Volume", "Looping", "[Back]"];
integer currentClip;
integer dialogListener;
integer DIALOG_CHANNEL = -99;
float DIALOG_TIMEOUT = 30.0;

GetSongs()
{
    songs = [];
    integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
    while (count--)
    {
        songs += llGetInventoryName(INVENTORY_NOTECARD, count);
    }
}

integer ReadSongNotecard()
{
    key configKey = llGetInventoryKey(songTitle);
    if (configKey == NULL_KEY)
    {
        llSay(PUBLIC_CHANNEL, "Notecard '" + songTitle + "' missing or unwritten."); //Notify user.
        return FALSE; //Don't do anything else.
    }
    //This notecard has already been read - call to read was made in error, so don't do anything. (Notecards are assigned a new key each time they are saved.)

    llSay(PUBLIC_CHANNEL, "Reading config, please wait..."); //Notify user that read has started.
    audioClips = [];
    totalClips = 0;
    notecardLine = 0;

    notecardKey = configKey;
    notecardQueryId = llGetNotecardLine(songTitle, notecardLine);
    return TRUE;
}

ParseConfigLine(string data)
{
    list items = llParseString2List(data, ["|"], []);
    string itemName = llList2String(items, 0);
    string itemValue = llList2String(items, 1);
    if (itemName == "finalClipDuration")
        finalClipDuration = (float)itemValue;
    else if (itemName == "maxClipDuration")
        maxClipDuration = (float)itemValue;
    else if (itemName == "audioClips")
    {
        audioClips = llCSV2List(itemValue);
        totalClips = llGetListLength(audioClips);
    }
}

integer isValidFloat(string s) { return (float)(s + "1") != 0.0; }

default
{
    state_entry()
    {
        GetSongs();
        llSay(0, greeting);
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
                songTitle = msg;
                state reading;
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

state reading
{
    state_entry()
    {
        llSetText("Reading notecard \"" + songTitle + "\"", textColor, OPAQUE);
        if (!ReadSongNotecard())
        {
            state default;
        }
    }

    dataserver(key query_id, string data)
    {
        if (query_id == notecardQueryId)
        {
            if (data == EOF) //Reached end of notecard (End Of File).
            {
                llSay(PUBLIC_CHANNEL, "Done reading notecard!"); //Notify user.
                state playing;
            }
            else
            {
                ParseConfigLine(data); //Add the line being read to a new entry on the list.
                ++notecardLine; //Increment line number (read next line).
                notecardQueryId = llGetNotecardLine(songTitle, notecardLine); //Query the dataserver for the next notecard line.
            }
        }
    }
}

state playing
{
    state_entry()
    {
        integer i;
        for (i=0; i < totalClips; ++i)
        {
            llSetText(preparingText + " (" + (string)(i + 1) + "/" + (string)totalClips + ")" , textColor, OPAQUE);
            llPreloadSound(llList2String(audioClips, i));
        }
        llSetText("", textColor, OPAQUE);
        currentClip = -1;
        llSetTimerEvent(0.5);
    }

    touch(integer total_number)
    {
        key av = llDetectedKey(0);
        dialogListener = llListen(DIALOG_CHANNEL, "", av, "");
        llDialog(av, "\nStop playing?", ["Yes", "No"], DIALOG_CHANNEL);
    }

    listen(integer chan, string name, key id, string msg)
    {
        if (msg == "Yes")
        {
            llStopSound();
            state default;
        }
    }

    timer()
    {
        currentClip += 1;
        if (currentClip + 1 < totalClips)
        {
            llPlaySound(llList2String(audioClips, currentClip), soundVolume);
            llSetTimerEvent(maxClipDuration);
        }
        else if (currentClip +1 == totalClips)
        {
            llPlaySound(llList2String(audioClips, currentClip), soundVolume);
            llSetTimerEvent(finalClipDuration);
            if (looping == "on") {
                currentClip = -1;
            }
        }
        else
        {
            llSetTimerEvent(0.0);
            state default;
        }
    }

    state_exit()
    {
        llListenRemove(dialogListener);
    }
}
