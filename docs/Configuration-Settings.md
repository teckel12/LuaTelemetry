## Taranis

Press the `Menu` button (`Shift` on X-Lite) to display the configuration options menu:

* Use the dial or +/- buttons to cycle through the menu or select the desired setting
* Press Enter/dial to select and deselect a menu option
* Press `Exit` or `RTN` to deselect a menu option or escape the configuration menu

## Horus/Jumper T16

* Must be unarmed to access the config menu when running as a widget
* Use the following (mode 2) stick controls to navigate the config menu:

![sample](https://raw.githubusercontent.com/iNavFlight/LuaTelemetry/master/assets/iNavConfigHorus.png "Horus config menu")

### Configuration menu options

![sample](https://raw.githubusercontent.com/iNavFlight/LuaTelemetry/master/assets/iNavConfig.png "Configuration menu")

!!! note
    Options without selections have either been disabled by another option setting or are not available on your transmitter or telemetry protocol.

  * **Battery View** - Total battery voltage / Cell voltage average (default: Total)
  * **Battery Alert** - All battery alerts on, off or only critical alerts (default: All)
  * **Cell Low** - Cell voltage for low battery warning (default: 3.5V) **[[help](#suggested-battery-settings)]**
  * **Cell Critical** - Cell voltage for battery critical warning (default: 3.4V) **[[help](#suggested-battery-settings)]**
  * **Cell Calculation** - Voltage to calculate cell count, 4.3V for LiPo, 4.4V for LiHV (default: 4.3V)
  * **Fuel Unit** - Match to INAV CLI value `smartport_fuel_unit` (default: Percent) **[[help](#suggested-battery-settings)]**
  * **Battery Capacity** - Set the battery capacity for Crossfire (default: 1500mAh)
  * **Fuel Low** - Fuel percentage for low battery warning (default: 30%) **[[help](#suggested-battery-settings)]**
  * **Fuel Critical** - Fuel percentage for battery critical warning (default: 20%) **[[help](#suggested-battery-settings)]**
  * **Altitude Alert** - Turn on/off the altitude alert (default: On)
  * **Max Altitude** - Altitude warning starts when over this value (default: 400' or 120m)
  * **Timer** - Show the automatic flight timer, timer1, timer2 or turn timer off (default: Auto)
  * **Tx Voltage** - Show transmitter voltage as graph and/or numerical value (default: Both or Graph)
  * **Rx Voltage** - Turn on/off the receiver voltage in the title (default: On)
  * **Variometer** - Vertical speed graph, voice notifications or off (default: Off)
  * **Vario Steps** - If Variometer is set to Voice, select the altitude steps (default: 10' or 10m)
  * **Altitude Graph** - Turn off or set altitude graph time period from 1-6 minutes (default: Off)
  * **Voice Alerts** - All voice alerts on, off or only critical alerts (default: All)
  * **Feedback** - Turn beeper and/or haptic feedback for alerts on or off (default: All)
  * **RTH Feedback** - Return to home beeper and haptic feedback on or off (default: On)
  * **HeadFree Feedback** - Head free beeper and haptic feedback on or off (default: On)
  * **RSSI Feedback** - RSSI beeper and haptic feedback on or off (default: On)
  * **AltHold Center FB** - Hepatic/audio feedback for Alt Hold center throttle position (default: Off)
  * **Speed Sensor** - Speed sensor to use, GPS or (if available) Pitot air speed (default: GPS)
  * **View Mode** - Classic, pilot, radar or altitude graph view modes (default: Classic)
  * **Roll Indicator** - Turn on/off roll indicator on Horus (default: Off)
  * **Aircraft Symbol** - Options 0 - 5 on Horus, [see below](#horusjumper-t16-aircraft-symbol-options) for options (default: 0)
  * **HUD Home Icon** - Select HUD or simple orientation for home icon on Horus (default: Off)
  * **Center Map Home** - Turn on/off centering of the radar home position on Horus (default: Off)
  * **Orientation** - Launch/pilot-based or compass-based default orientation (default: Launch)
  * **GPS HDOP View** - View the GPS accuracy (HDOP) as a Graph or Decimal (default: Graph)
  * **GPS Warning** - GPS accuracy (HDOP) to trigger warning (default: > 3.5 HDOP [at least 1 bar])
  * **GPS** - GPS coordinates as decimal or degrees/minutes format (default: Decimal)
  * **Playback Log** - Playback telemetry log files (latest 5 logs from the last 2 weeks) **[[help](../Configuration-Settings/#playback-telemetry-log-files)]**

## Suggested Battery Settings
### Voltage and Current Calibration

1. Using a multimeter, calibrate the voltage with the "Voltage Scale" in INAV configurator
1. If you have a current sensor, make sure you [calibrate it](https://www.youtube.com/watch?v=AWjblvHgjjI)

### In INAV Configurator

* Voltage source to use for alarms and telemetry: **Raw**
* Number of cells: **0** (0=auto, set if you always use the same cell count)
* Maximum cell voltage for cell count detection: **4.3**
* Minimum cell voltage: **3.4** (match "Cell Critical" in Lua Telemetry)
* Maximum cell voltage: **4.2**
* Warning cell voltage: **3.5** (match "Cell Low" in Lua Telemetry)
* Set capacity in **mAh** to battery capacity
* Warning capacity: **30%** (match "Fuel Low" in Lua Telemetry)
* Critical capacity: **10%**

### In INAV CLI (ignore for TBS Crossfire)

* `set smartport_fuel_unit = percent`
* `set report_cell_voltage = OFF` (if set to `ON` Lua Telemetry can't show total battery voltage)

### In Lua Telemetry

* Cell Low: **3.5V** (match "Warning cell voltage" in INAV)
* Cell Critical: **3.4V** (match "Minimum cell voltage" in INAV)
* Fuel Unit: **Percent**
* Fuel Low: **30%** (match "Warning capacity" in INAV)
* Fuel Critical: **20%**

## Playback Telemetry Log Files

!!!warning
    Telemetry log file playback works really well on Horus transmitters.  However, while it works on my Taranis Q X7, for others it may crash with a "**attempt to call a nil value**" or "**not enough memory**" error.  This means you're using too much memory for other things on your transmitter and it doesn't have enough memory to playback the logs.  Not switching views and not using the pilot view will use less memory, but it's possible you just won't be able to playback log files on a Taranis transmitter if you have too little memory available.

Log file playback allows you to playback the latest 5 telemetry log files from up to the last 2 weeks on the currently selected model.  You must be _unarmed_ for this to work and if you arm while playing back a log file, the playback will be terminated.

### Setup

Before you can playback a telemetry log file you need to make sure you're logging your telemetry.  By default for each telemetry sensor, the **Logs** option is already checked (unless you unchecked it).  However, it still won't log unless you setup a special function.  In the model setup on your transmitter, page to the **SPECIAL FUNCTIONS** page.  In an empty slot, create a special function that's activated from your arm switch (in my case **SF↓**).  It should look something like this:

```
SF1	SF↓	SD Logs 	0.2s
```

This will log your telemetry 5 times per second automatically every time you arm.  You can set this up on any switch you'd like, but the arm switch is most common.  You can also change the value to 0.1s to log 10 times a second or any other value you wish.  Note that the log playback will be smoother if you select a lower log frequency value.

### Playback

To playback a log file, go to the config menu and scroll to the last item.  If there's any log files in the last 2 weeks, you'll see a date (in YY-MM-DD format).  You can cycle through the dates and select the one you wish to playback (exit will unselect the menu option).

Standard playback will be at close to normal speed (note the timestamp in the title bar).  When playing back, you can use the right stick (mode 2) to fast forward (stick up), reverse (stick down), pause (hold stick right), or quit (stick left).  The further you move the stick up and down the faster the forward or reverse.  The stick center position is playback at normal speed.  When it gets to the end of the log, it will pause.

As multiple flights from the same day are recorded to the same telemetry log files, the playback will continue to the next flight (note the timestamp in the title for time jumps which will be a new flight).


## Horus/Jumper T16 aircraft symbol options

![sample](https://raw.githubusercontent.com/iNavFlight/LuaTelemetry/development/assets/AircraftSymbols.png "Horus aircraft symbols")