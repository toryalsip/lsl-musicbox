// When placing this script in the object where it will be played, name the script with
// the prefix {SONG} so that the player script knows a song is contained in that script.

string songTitle; // Title of the song
string songCredits; // Put composed / arranged by message here. Script will always display this before playing.
list audioClips; // place UUIDs or names of the audio clips here. If using names, they must reside in the object's inventory
integer totalClips;
float maxClipDuration = 29.9; // Needs to match the length of other clips
float finalClipDuration = 29.9; // Needs to match the length of the final clip
integer currentClip;
integer dialogListener;
integer DIALOG_CHANNEL = -99;
float DIALOG_TIMEOUT = 30.0;

default
{
    state_entry()
    {
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
