local isPlaying = false
local currentClip = 0
local settings = {
    greeting = "Greetings! Touch me to start playing!",
    preparingText = "Preparing music...",
    soundVolume = 1.0,
    textColor = vector(0.0,1.0,0.0),
    audioClips = {
        --{ name = "Example 1", duration = 29.9 },
        --{ name = "Example 2", duration = 29.9 },
        --{ name = "Example 3", duration = 8.0 }
    }
}

function stopPlaying()
    ll.SetText("" , settings.textColor, 1.0)
    ll.StopSound()
    ll.SetTimerEvent(0)
    isPlaying = false
    ll.Say(PUBLIC_CHANNEL, "Stopped playing")
end

function startPlaying()
    currentClip = 0
    preloadSounds(settings.audioClips)
    ll.SetText("" , settings.textColor, 1.0)
    ll.SetTimerEvent(0.5)
    isPlaying = true
end

-- Preloading clips allows us to have them ready to play immediately
function preloadSounds(clips)
    local totalClips = #clips
    ll.Say(PUBLIC_CHANNEL, "Preparing music...")
    for index, clip in ipairs(clips) do
        ll.SetText(`{settings.preparingText} ({index}/{totalClips})` , settings.textColor, 1.0)
        ll.PreloadSound(clip.name)
    end
end

function timer()
    currentClip += 1
    local clip = settings.audioClips[currentClip]
    if clip then
        ll.PlaySound(clip.name, settings.soundVolume)
        ll.SetTimerEvent(clip.duration)
    else
        stopPlaying()
    end
end

function state_entry()
    ll.Say(PUBLIC_CHANNEL, settings.greeting)
end

function touch_start(total_number)
   if isPlaying then
      stopPlaying()
   else
       startPlaying()
   end
end

-- Simulate the state_entry event
state_entry()
