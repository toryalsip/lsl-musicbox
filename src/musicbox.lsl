string greeting = "Greetings! Touch me to start playing!";
string defaultText = "Touch to start!";
string preparingText= "Preparing music...";
string songTitle = "<SONG TITLE GOES HERE>";
vector textColor = <0.0, 1.0, 0.0>;
float OPAQUE = 1.0;
list audioClips = []; // place UUIDs or names of the audio clips here. If using names, they must reside in the object's inventory
integer totalClips;
float MAX_CLIP_DURATION = 29.9; // Needs to match the length of other clips
float finalClipDuration = 29.9; // Needs to match the length of the final clip
integer currentClip;

default
{
    state_entry()
    {
        totalClips = llGetListLength(audioClips);
        llSay(0, greeting);
        llSetText(defaultText, textColor, OPAQUE);
    }

    touch_start(integer total_number)
    {
        state playing;
    }
}

state playing
{
    state_entry()
    {

        llSetText(preparingText, textColor, OPAQUE);        
        integer i;
        for (i=0; i < totalClips; ++i)
        {
            llPreloadSound(llList2Key(audioClips, i));
        }
        llSetText("Now playing \"" + songTitle + "\"", textColor, OPAQUE);
        currentClip = -1;
        llSetTimerEvent(0.5);
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
}
