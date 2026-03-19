---
name: actions-audio-video
description: Music playback, audio/video recording, encoding, camera, Shazam, and podcast actions
metadata:
  tags: cherri, actions, music, audio, video, camera, shazam, podcasts
---

## Music (`#include 'actions/music'`)

**shuffleMode**: `Off`, `Songs`

**repeatMode**: `None`, `One`, `All`

**musicDetail**: `Title`, `Album`, `Artist`, `Album Artist`, `Genre`, `Composer`, `Date Added`, `Media Kind`, `Duration`, `Play Count`, `Track Number`, `Disc Number`, `Album Artwork`, `Is Explicit`, `Lyrics`, `Release Date`, `Comments`, `Is Cloud Item`, `Skip Count`, `Last Played Date`, `Rating`, `File Path`, `Name`

**seekBehavior**: `To Time`, `Forward By`, `Backward By`

Get the currently playing song.
`getCurrentSong()`

Add songs to the music library.
`addToMusic(variable songs)`

Prompt the user to select music from their library.
`selectMusic(bool ?selectMultiple = false)`

Play music with optional shuffle and repeat modes.
`playMusic(variable music, shuffleMode ?shuffle, repeatMode ?repeat)`

Get a specific detail about a song.
`getMusicDetail(variable music, musicDetail detail)`

Resume playback.
`play()`

Pause playback.
`pause()`

Toggle between play and pause.
`togglePlayPause()`

Go to the previous song.
`skipBack()`

Skip to the next song.
`skipFwd()`

Seek the currently playing media to a time or by an offset.
`seek(#timerDuration timeInterval = qty(0, "sec"), seekBehavior behavior = "To Time")`

Add music to play next in the queue.
`playNext(variable music)`

Add music to the end of the playback queue.
`playLater(variable music)`

Clear the Up Next queue.
`clearUpNext()`

Add songs to a named playlist.
`addToPlaylist(text playlistName, variable songs)`

Get all songs from a playlist.
`getPlaylistSongs(variable playlistName): array`

---

## Media (`#include 'actions/media'`)

**audioQuality**: `Normal`, `Very High`

**audioStart**: `On Tap`, `Immediately`

**audioFormats**: `M4A`, `AIFF`

**audioSpeeds**: `0.5X`, `Normal`, `2X`

**shazamDetail**: `Apple Music ID`, `Artist`, `Title`, `Is Explicit`, `Lyrics Snippet`, `Lyric Snippet Synced`, `Artwork`, `Video URL`, `Shazam URL`, `Apple Music URL`, `Name`

**cameraOrientation**: `Front`, `Back`

**videoQuality**: `Low`, `Medium`, `High`

**recordingStart**: `On Tap`, `Immediately`

**podcastDetail**: `Feed URL`, `Genre`, `Episode Count`, `Artist`, `Store ID`, `Store URL`, `Artwork`, `Artwork URL`, `Name`

**encodeVideoSizes**: `640×480`, `960×540`, `1280×720`, `1920×1080`, `3840×2160`, `HEVC 1920×1080`, `HEVC 3840x2160`, `ProRes 422`

**encodeVideoSpeeds**: `0.5X`, `Normal`, `2X`

Search the App Store for apps matching a query.
`searchAppStore(text query)`

Show a product in iTunes.
`showIniTunes(variable product)`

Prompt the user to record audio with configurable quality and start mode.
`recordAudio(audioQuality ?quality = "Normal", audioStart ?start = "On Tap")`

Encode audio to a different format and/or playback speed.
`encodeAudio(variable audio, audioFormats ?format = "M4A", audioSpeeds ?speed = "Normal")`

Play a sound or audio file.
`playSound(variable input)`

Prompt the user to play music for Shazam to recognize; returns the Shazam result.
`startShazam(bool ?show = true, bool ?showError = true)`

Get a specific detail from a Shazam result.
`getShazamDetail(variable input, shazamDetail detail)`

Prompt the user to take one or more photos with the camera.
`takePhoto(number count = 1, bool showPreview = true)`

Prompt the user to record a video with configurable camera, quality, and start mode.
`takeVideo(cameraOrientation ?camera = "Front", videoQuality ?quality = "High", recordingStart ?recordingStart = "Immediately")`

Take a screenshot of the screen.
`takeScreenshot(bool ?mainMonitorOnly = false)`

Search for podcasts matching a query.
`searchPodcasts(text query)`

Get a specific detail about a podcast.
`getPodcastDetail(variable podcast, podcastDetail detail)`

Get the user's subscribed podcasts.
`getPodcasts()`

Play a podcast.
`playPodcast(variable podcast)`

Strip all metadata from a media file.
`stripMediaMetadata(variable media)`

Set metadata fields on a media file.
`setMetadata(variable media, variable ?artwork, text ?title, text ?artist, text ?album, text ?genre, text ?year)`

Encode a video to a different size, speed, and/or format.
`encodeVideo(variable video, encodeVideoSizes ?size = "Passthrough", encodeVideoSpeeds ?speed = "Normal", bool ?preserveTransparency = false)`

Prompt the user to trim a video interactively.
`trimVideo(variable video)`

Search Voice Memos by a search string.
`searchVoiceMemos(text search): array`
