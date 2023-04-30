## lsl-musicbox
Simple script you can place inside an object to play back audio clips in a sequence.

### Setup
1. Add the audio clips you want to play in the object, or make note of their UUIDs
2. Add the `musicbox.lsl` contents to your object.
3. Update the `songTitle` variable to the song that will be played
4. Add the list of clip names or UUIDss in the order they are to be played
5. Set `finalClipDuration` to the duration of the last clip in seconds

### Playing music
Just touch the object, and the script will preload any clips and then start playing.
