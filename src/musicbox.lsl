string greeting = "Greetings! Touch me to start playing!";
string defaultText = "Touch to start!";
string preparingText= "Preparing music...";
string songTitle = "<SONG TITLE GOES HERE>";
vector textColor = <0.0, 1.0, 0.0>;
float OPAQUE = 1.0;
list audioClips = []; // place UUIDs or names of the audio clips here. If using names, they must reside in the object's inventory
float finalClipDuration = 8.0;

default
{
    state_entry()
    {
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
        for (i=0; i < llGetListLength(audioClips); ++i)
        {
            llPreloadSound(llList2Key(audioClips, i));
        }
        llSetText("Now playing \"" + songTitle + "\"", textColor, OPAQUE);
        for (i=0; i < llGetListLength(audioClips); ++i)
        {
            llPlaySound(llList2Key(audioClips, i), 1.0);
            if (i < llGetListLength(audioClips))
            {
                llSleep(29.9);
            }
            else
            {
                llSleep(finalClipDuration);
            }
        }
        
        state default;
    }
}
