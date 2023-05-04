## lsl-musicbox
Simple script you can place inside an object to play back audio clips in a sequence.

### Setup
#### 1. Add audio clips to the object
First break your song into separate audio clips and upload each individual clip. These must meet Second Life's [functional spec requirements](https://wiki.secondlife.com/wiki/Sound_Clips).
- 30(.000) seconds maximum
- PCM WAV format, 16-bit, 44.1 kHz, mono / stereo (Downmixed to mono by the viewer at upload time)

Although you do not have to, I recommend you name your songs in a way that they will sort alphabetically in the order you want them to play. Ex: My Song 01, My Song 02, My Song 03.

#### 2. Create a `CONFIG` notecard

#### 3. Add the `musicbox.lsl` script to your object.

### Playing music
To start playing, touch the object or say `START` in chat. The script will preload any clips and then start playing.

To stop playing, touch the object and select `Yes` from the dialog or say `STOP` in chat.
