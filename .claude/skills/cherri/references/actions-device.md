---
name: actions-device
description: Device, settings, network, location, and accessibility actions
metadata:
  tags: cherri, actions, device, settings, network, location, a11y
---

This file covers five includes:

- `#include 'actions/device'` — device info, battery, orientation, power
- `#include 'actions/settings'` — brightness, volume, DND, focus, wallpaper, appearance
- `#include 'actions/network'` — Wi-Fi, cellular, IP address, SSH
- `#include 'actions/location'` — GPS, maps, weather
- `#include 'actions/a11y'` — accessibility settings

---

## Device (`#include 'actions/device'`)

**deviceDetail**: `Device Name`, `Device Hostname`, `Device Model`, `Device Is Watch`, `System Version`, `Screen Width`, `Screen Height`, `Current Volume`, `Current Brightness`, `Current Appearance`

**deviceUsageType**: `all`, `app`, `website`

**usageDuration**: `today`, `yesterday`, `lastWeek`, `thisWeek`, `thisMonth`, `thisYear`, `specifiedDay`, `inBetween`

Get a detail about the current device.
`getDeviceDetail(deviceDetail detail)`

Get content currently on-screen.
`getOnScreenContent()`

Get the current orientation of the device.
`getOrientation(): text`

Lock the device screen. Requires iOS 17+.
`lockScreen()`

Power off the device. Requires iOS 17+.
`shutdown()`

Power off the device, then power it on again. Requires iOS 17+.
`reboot()`

Vibrate the device. iOS/iPadOS only.
`vibrate()`

Get the current level of charge of the device battery.
`getBatteryLevel()`

Determine if the device is currently connected to a charger. Requires iOS 16.2+.
`connectedToCharger(): bool`

Determine if the device is currently charging. Requires iOS 16.2+.
`isCharging(): bool`

Get website and app activity for screen time reporting.
`getDeviceUsage(deviceUsageType usageType = "all", variable ?device, usageDuration during = "today", text ?startTime, text ?endTime)`

---

## Settings (`#include 'actions/settings'`)

**FocusUntil**: `Turned Off`, `Time`, `I Leave`, `Event Ends`

Set the screen brightness.
`setBrightness(float brightness)`

Set the system volume.
`setVolume(float volume)`

Turn on Do Not Disturb.
`DNDOn()`

Turn off Do Not Disturb.
`DNDOff()`

Toggle Do Not Disturb on or off.
`toggleDND()`

Get the current Focus Mode.
`getFocusMode()`

Set the appearance to Light mode.
`lightMode()`

Set the appearance to Dark mode.
`darkMode()`

Set the device wallpaper to the given image.
`setWallpaper(variable input)`

Get all device wallpapers. iOS/iPadOS only, requires iOS 16.2+.
`getAllWallpapers(): array`

Get the current device wallpaper. iOS/iPadOS only, requires iOS 16.2+.
`getWallpaper()`

---

## Network (`#include 'actions/network'`)

**wifiDetail**: `Network Name`, `BSSID`, `Wi-Fi Standard`, `RX Rate`, `TX Rate`, `RSSI`, `Noise`, `Channel Number`, `Hardware MAC Address`

**cellularDetail**: `Carrier Name`, `Radio Technology`, `Country Code`, `Is Roaming Abroad`, `Number of Signal Bars`

**SSHScriptAuthType**: `Password`, `SSH Key`

**IPTypes**: `IPv4`, `IPv6`

Get a detail about the current Wi-Fi network.
`getWifiDetail(wifiDetail detail)`

Get a detail about the current cellular network.
`getCellularDetail(cellularDetail detail)`

Connect to a file server at the given URL.
`connectToServer(text url)`

Run an SSH script using the provided connection details.
`runSSHScript(text script, variable input, text host, text port, text user, SSHScriptAuthType authType, text password)`

Get the user's external IP address.
`getExternalIP(IPTypes ?type = "IPv4"): text`

Get the user's local IP address.
`getLocalIP(IPTypes ?type = "IPv4"): text`

Determine if the user is currently online.
`isOnline()`

---

## Location (`#include 'actions/location'`)

**locationDetail**: `Name`, `URL`, `Label`, `Phone Number`, `Region`, `ZIP Code`, `State`, `City`, `Street`, `Altitude`, `Longitude`, `Latitude`

**weatherForecastTypes**: `Daily`, `Hourly`

**weatherDetail**: `Name`, `Air Pollutants`, `Air Quality Category`, `Air Quality Index`, `Sunset Time`, `Sunrise Time`, `UV Index`, `Wind Direction`, `Wind Speed`, `Precipitation Chance`, `Precipitation Amount`, `Pressure`, `Humidity`, `Dewpoint`, `Visibility`, `Condition`, `Feels Like`, `Low`, `High`, `Temperature`, `Location`, `Date`

Create a location value from a variable.
`location(variable location)`

Create a location value representing the user's current location.
`currentLocation()`

Get the user's current GPS location.
`getCurrentLocation()`

Get a specific detail about a location.
`getLocationDetail(variable location, locationDetail detail)`

Extract addresses from the given input.
`getAddresses(variable input)`

Create a location value from a street address.
`streetAddress(text addressLine1, text addressLine2, text city, text state, text country, number zipCode)`

Open a location in the Maps app.
`openInMaps(variable location)`

Get a Maps link for a location.
`getMapsLink(variable location)`

Get the halfway point between two locations.
`getHalfwayPoint(variable firstLocation, variable secondLocation)`

Get the current weather for a location.
`getCurrentWeather(text ?location = "Current Location")`

Get a weather forecast for a location.
`getWeatherForecast(weatherForecastTypes ?type = "Daily", text ?location = "Current Location")`

Get a specific detail from a weather forecast.
`getWeatherDetail(variable weather, weatherDetail detail)`

Add a location to the Weather app.
`addWeatherLocation(variable location)`

Remove a location from the Weather app.
`removeWeatherLocation(variable location)`

---

## Accessibility (`#include 'actions/a11y'`)

**backgroundSound**: `BalancedNoise`, `BrightNoise`, `DarkNoise`, `Ocean`, `Rain`, `Stream`

**textSizes**: `Accessibility Extra Extra Extra Large`, `Accessibility Extra Extra Large`, `Accessibility Extra Large`, `Accessibility Large`, `Accessibility Medium`, `Extra Extra Extra Large`, `Extra Extra Large`, `Extra Large`, `Default`, `Medium`, `Small`, `Extra Small`

**soundRecognitionOperations**: `pause`, `activate`, `toggle`

Set the background sound that plays.
`setBackgroundSound(backgroundSound ?sound = "BalancedNoise")`

Set the volume of background sounds.
`setBackgroundSoundsVolume(float volume)`

Set the system text size.
`setTextSize(textSizes size)`

Enable, pause, or toggle Sound Recognition. iOS/iPadOS only, requires iOS 18+.
`setSoundRecognition(soundRecognitionOperations ?operation = "activate")`

Trigger the Magnifier "Describe This" feature. iOS/iPadOS only, requires iOS 18+.
`magnifierDescribe()`

Open the Magnifier Reader. iOS/iPadOS only, requires iOS 18+.
`magnifierReader()`

Start Magnifier Point & Speak. iOS/iPadOS only, requires iOS 18+.
`magnifierPointAndSpeak()`
