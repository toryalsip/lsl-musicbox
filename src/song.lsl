// When placing this script in the object where it will be played, name the script with
// the prefix {SONG} so that the player script knows a song is contained in that script.
// Define various parameters about your song in these variables.
string songTitle = "Test 1"; // Title of the song
string songCredits = "Composed by, Arranged by"; // Put composed / arranged by message here. Script will always display this before playing.
list audioClips = []; // place UUIDs or names of the audio clips here. If using names, they must reside in the object's inventory
float maxClipDuration = 29.9; // Needs to match the length of other clips
float finalClipDuration = 29.9; // Needs to match the length of the final clip
// General variables used throughout the script
string preparingText= "Preparing music...";
vector textColor = <0.0, 1.0, 0.0>;
float OPAQUE = 1.0;
integer totalClips;
key currentId;
float soundVolume;
string looping;
integer currentClip;

default
{
    state_entry()
    {
        totalClips = llGetListLength(audioClips);
    }
    
    link_message(integer source, integer num, string msg, key id)
    {
        string scriptName = llGetScriptName();
        list params = llParseString2List(msg, ["|"], []);
        
        if (llList2String(params, 0) == scriptName)
        {
            currentId = id;
            looping = llList2String(params, 1);
            soundVolume = llList2Float(params, 2);
            list response = ["playing", songTitle, songCredits];
            llMessageLinked(LINK_THIS, 0, llDumpList2String(response, "|"), id);
            state playing;
        }
    }
}

state playing
{
    state_entry()
    {
        llSay(PUBLIC_CHANNEL, "Now playing " + songTitle);
        llSay(PUBLIC_CHANNEL, songCredits);
        integer i;
        for (i=0; i < totalClips; ++i)
        {
            llSetText(preparingText + " (" + (string)(i + 1) + "/" + (string)totalClips + ")" , textColor, OPAQUE);
            llPreloadSound(llList2String(audioClips, i));
        }
        currentClip = -1;
        llSetTimerEvent(0.5);
        llSetText("", textColor, OPAQUE);
    }
    
    link_message(integer source, integer num, string msg, key id)
    {
        if (msg == "stop")
        {
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
            llMessageLinked(LINK_THIS, 0, "done", currentId);
            state default;
        }
    }
}
