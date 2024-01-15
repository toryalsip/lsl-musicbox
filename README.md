## lsl-musicbox
Simple script you can place inside an object to play back audio clips in a sequence.

### Setup
#### 1. Add audio clips to the object
First break your song into separate audio clips and upload each individual clip. These must meet Second Life's [functional spec requirements](https://wiki.secondlife.com/wiki/Sound_Clips).
- 30(.000) seconds maximum
- PCM WAV format, 16-bit, 44.1 kHz, mono / stereo (Downmixed to mono by the viewer at upload time)

Although you do not have to, I recommend you name your songs in a way that they will sort alphabetically in the order you want them to play. Ex: My Song 01, My Song 02, My Song 03.

#### 2. Create a notecard for your song
The notecard contains pipe-delimited values. You will need to set these based on your audio clips.
- `finalClipDuration`: Specifies the length of the last clip on the list. This defaults to 29.9 seconds, but most final clips are unlikely to be this so you'll probably want to set this.
- `maxClipDuration`: Specifies how long the audio clips are (except for the last one on the list) in seconds. Defaults to 29.9 seconds. If you create your clips to be this length you do not need to send this.
- `audioClips`: A comma-separated list of the names of the clips in the order they are to be played. The clips need to be in the object's inventory to work.
- `looping`: (optional) on/off Determines if the song plays continuously in a loop.

After you have created the notecard, give it a name. This should be the song title, as the script will use the name of the notecard for this purpose.

Example notecard.
```
finalClipDuration|12.2
audioClips|Clip 1,Clip 2,Clip 3,Clip 4
looping|off
```

#### 3. Add the `musicbox.lsl` script to your object.

### Playing music
To start playing, touch the object or say `START` in chat. The script will preload any clips and then start playing.

To stop playing, touch the object and select `Yes` from the dialog or say `STOP` in chat.
