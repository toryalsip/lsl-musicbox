## lsl-musicbox

Simple script you can place inside an object to play back audio clips in a sequence.

### Setup

#### 1. Add audio clips to the object

First break your song into separate audio clips and upload each individual clip. These must meet Second Life's [functional spec requirements](https://wiki.secondlife.com/wiki/Sound_Clips).

- 30(.000) seconds maximum
- PCM WAV format, 16-bit, 44.1 kHz, mono / stereo (Downmixed to mono by the viewer at upload time)

Although you do not have to, I recommend you name your songs in a way that they will sort alphabetically in the order you want them to play. Ex: My Song 01, My Song 02, My Song 03.

#### 2. Create your song script

Use the `song.lsl` script as a template. You will want to change the following variables.

- `songTitle`: The name of the song. This can be longer if need be
- `songCredits`: Put information like who wrote the song, arranger, and copyright info.
- `audioClips`: A list of the names of the clips or their UUIDs in the order they are to be played. If using names, then the clips need to be in the object's inventory to work.
- `maxClipDuration`: Specifies how long the audio clips are (except for the last one on the list) in seconds. Defaults to 29.9 seconds. If you create your clips to be this length you do not need to send this.
- `finalClipDuration`: Specifies the length of the last clip on the list. This defaults to 29.9 seconds, but most final clips are unlikely to be this so you'll probably want to set this.

After you have created the script, name it with the prefix `{SONG}` followed by a shortened name of the song. This will appear on the menu button, so try not to make it too long.

#### 3. Add the `player.lsl` script and your song script to your object.

### Playing music

To start playing, touch the object. Select the song you want to play and it will start.

To stop playing, touch the object and select `Yes` from the dialog.

### Settings Menu

The script also has an administrative menu which you can use to do the following

- Volume: Used to set the volume that the music box will play in
- Looping: Used to toggle music looping on and off.
