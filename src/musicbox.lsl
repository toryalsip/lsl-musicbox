string greeting = "Greetings! Touch me to start playing!";
string defaultText = "Touch or say START in chat to start!";
string preparingText= "Preparing music";
string songTitle = "<SONG TITLE GOES HERE>";
vector textColor = <0.0, 1.0, 0.0>;
float OPAQUE = 1.0;
list audioClips = []; // place UUIDs or names of the audio clips here. If using names, they must reside in the object's inventory
integer totalClips;
float MAX_CLIP_DURATION = 29.9; // Needs to match the length of other clips
float finalClipDuration = 29.9; // Needs to match the length of the final clip
integer currentClip;
integer dialogListener;
integer chatListener;
integer DIALOG_CHANNEL = -99;

default
{
    state_entry()
    {
        chatListener = llListen(PUBLIC_CHANNEL, "", NULL_KEY, "");
        totalClips = llGetListLength(audioClips);
        llSay(0, greeting);
        llSetText(defaultText, textColor, OPAQUE);
    }

    listen(integer chan, string name, key id, string msg)
    {

        if (msg == "START")
        {
            state playing;
        }
    }

    touch(integer total_number)
    {
        state playing;
    }

    state_exit()
    {
        llListenRemove(chatListener);
    }
}

state playing
{
    state_entry()
    {
        chatListener = llListen(PUBLIC_CHANNEL, "", NULL_KEY, "");
        integer i;
        for (i=0; i < totalClips; ++i)
        {
            llSetText(preparingText + " (" + (string)(i + 1) + "/" + (string)totalClips + ")" , textColor, OPAQUE);
            llPreloadSound(llList2Key(audioClips, i));
        }
        llSetText("Now playing \"" + songTitle + "\"\nTouch or say STOP to stop.", textColor, OPAQUE);
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
        if (msg == "Yes" || msg == "STOP")
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
            llPlaySound(llList2Key(audioClips, currentClip), 1.0);
            llSetTimerEvent(MAX_CLIP_DURATION);
        }
        else if (currentClip +1 == totalClips)
        {
            llPlaySound(llList2Key(audioClips, currentClip), 1.0);
            llSetTimerEvent(finalClipDuration);
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
        llListenRemove(chatListener);
    }
}
