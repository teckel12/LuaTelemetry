### Installation

!!! tip
    To upgrade from a previous version, see the (_**much**_ shorter) [upgrade instructions](../Upgrade)

Don't be too concerned about the length of these instructions. The first two sections are about setting up telemetry in INAV and your transmitter, which for most is already completed.  Also, the instructions are for multiple transmitters, telemetry protocols and I've tried to be very descriptive so even a novice could follow along. Therefore, it's a bit verbose but proceeds quickly, I promise.

#### INAV Configurator Telemetry Setup

1. Setup SmartPort(S.Port), F.Port, D-series, or Crossfire telemetry to send to your transmitter: [INAV telemetry docs](https://github.com/iNavFlight/inav/master/docs/Telemetry.md)
1. FrSky receivers (skip for TBS Crossfire):
    1. If you have an current sensor and want to show fuel percent remaining:
        * `set smartport_fuel_unit = PERCENT`
        * Set `battery_capacity` to the mAh you want to draw from your battery
    1. If instead you want to show the current sensor's mAh:
        * `set smartport_fuel_unit = MAH`
    1. With INAV v2.0.0+, `set frsky_pitch_roll = ON` in CLI settings for accurate attitude display and pitch angle

#### Add Telemetry Sensors to Transmitter

1. With battery connected and **after GPS fix** [discover telemetry sensors](https://www.youtube.com/watch?v=n09q26Gh858) so all telemetry sensors are discovered
1. FrSky receivers (skip for TBS Crossfire):
    1. Telemetry distance sensor name `0420` (or `0007` with D-series receivers) should be changed to `Dist` and set to the desired unit: `m` or `ft`
    1. The sensors `Dist`, `Alt`, `GAlt` and `Gspd` can be changed to the desired unit: `m` or `ft` / `kmh` or `mph`
    1. If you `set frsky_pitch_roll = ON` on INAV v2.0.0+ (which I suggest) you can optionally change the following for clarification:
        * Telemetry sensor `0430` (or `0008` with D-series receivers) can be changed to `Ptch`
        * Telemetry sensor `0440` (or `0020` with D-series receivers) can be changed to `Roll`
    1. **Don't** change `Tmp1` or `Tmp2` from Celsius to Fahrenheit! They're not temps (used for flight modes and GPS info)
    1. If you don't have a current sensor, you can optionally delete or rename the `Fuel` sensor so it doesn't show in Lua Telemetry

#### Install/Setup Lua Telemetry on Transmitter

1. Download the latest [LuaTelemetry.zip](https://github.com/iNavFlight/LuaTelemetry/releases/latest) file (Note: **NOT** the source code)
1. Copy the contents of the ZIP file (`SCRIPTS` and `WIDGETS` folders) to the transmitter's SD card's root
    * Taranis:
        1. In model setup, page to `DISPLAY`
        1. Set desired screen to `Script`
        1. Select `iNav`
    * Horus/Jumper T16:
        1. Long-press `TELE` to access the user interface/views layout
        1. Select the desired view (or create a new one)
        1. Make `Layout` full screen, turn off `Top bar` and `Sliders+Trims`
        1. Select `Setup widgets`
        1. Press `Enter` till a menu appears and select `Select widget`
        1. Scroll to the `iNav` widget and press `Enter`
        1. Optionally (while still selecting the `iNAV` script), long-press `Enter`, select `Widget settings` where you can enable `Restore` (to restore your theme's colors) and set your theme's `Text` color and `Warning` color
    * Nirvana NV14:
        1. Press the Widgets icon
        1. Select the desired view
        1. Change the layout to full screen
        1. Uncheck all boxes
        1. Select `Setup widgets`, tap the screen and select `iNAV`
        1. Optionally, you can enable `Restore` (to restore your theme's colors) and set your theme's `Text` color and `Warning` color
1. Press `EXIT` or `RTN` several times to exit (back icon on Nirvana)

### Download Options
When [downloading INAV Lua Telemetry](https://github.com/iNavFlight/LuaTelemetry/releases/latest), you may notice there's several different download options at the bottom of the release.  Following are descriptions of each download option:

* **LuaTelemetry-Horus-en.zip** - Horus transmitters with English sound files only
* **LuaTelemetry-Horus.zip** - Horus transmitters with sound files for all supported languages
* **LuaTelemetry-Taranis-en.zip** - Taranis transmitters with English sound files only
* **LuaTelemetry-Taranis.zip** - Taranis transmitters with sound files for all supported languages
* **LuaTelemetry.zip** - Taranis and Horus including sound files for all supported languages
* **Source code** (zip) - ZIP compressed source code for this release - *not for transmitter install*
* **Source code** (tar.gz) - Tarball format source code for this release - *not for transmitter install*

If you just want to install without thinking about it, download and install the latest [LuaTelemetry.zip](https://github.com/iNavFlight/LuaTelemetry/releases/latest) file which includes everything and will work on both Taranis and Horus in any language. The other download options are available to save a bit of SD card space on the transmitter and to keep the install clean of unneeded files.


#### Running Lua Telemetry

* Taranis:
    1. From the main screen on your transmitter, long-press `Page` (down d-pad on X-Lite)
    1. If Lua Telemetry isn't on your first page, short-press `Page` to the Lua Telemetry screen
* Horus/Jumper T16/Nirvava NV14:
    1. From the main screen on your transmitter, press `PgUp/Dn` (swipe left on Nirvana) to the Lua Telemetry view
* [Screen Description](../Screen-Description)
* [Configuration Settings](../Configuration-Settings)
* [Tips & Common Problems](../Tips-&-Common-Problems)