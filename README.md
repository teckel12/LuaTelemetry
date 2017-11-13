# SmartPort/INAV Telemetry Flight Status - v1.1.8

#### Taranis Q X7
![sample](http://www.leethost.com/link_pics/iNav1.png "launch/pilot-based model orientation and location indicators")
![sample](http://www.leethost.com/link_pics/iNav2.png "Compass-based direction indicator")

#### Taranis X9D, X9D Plus & X9E
![sample](http://www.leethost.com/link_pics/iNav3.png?1 "View on Taranis X9D, X9D Plus & X9E")

## Features

* Launch/pilot-based model orientation and location indicators (great for lost orientation/losing sight of your model)
* Compass-based direction indicator (with compass on multirotor or fixed wing with GPS)
* Bar gauges for Fuel (% battery mAh capacity remaining), Battery voltage, RSSI strength, Transmitter battery (and Altitude for X9D, X9D Plus & X9E transmitters)
* Display and voice alerts for flight modes and flight mode modifiers (altitude hold, heading hold, home reset, etc.)
* Voice notifications for % battery remaining (based on current), voltage low/critical, high altitude, lost GPS, ready to arm, armed, disarmed, etc.
* GPS information: Satellites locked, GPS altitude, GPS coordinates
* Display of current/maximum: Altitude, Distance, Speed and Current
* Display of current/minimum: Battery voltage, RSSI strength
* Display of current Fuel (% battery mAh capacity remaining), Receiver voltage and flight timer
* Speed and distance values are displayed in metric or imperial based on transmitter's telemetry settings

## Requirements

* [OpenTX v2.2.0+](http://www.open-tx.org/) running on Taranis Q X7, X9D, X9D Plus or X9E
* SmartPort telemetry compatible receiver: X4R(SB), X8R, XSR, R-XSR, XSR-M, XSR-E, etc. (*NOT* D-series receivers)
* [INAV v1.7.3+](https://github.com/iNavFlight/inav/releases) running on your flight controller
* GPS
* Suggested for full functionality but not required: altimeter (barometer), magnetometer (compass) and current sensors

> Note: This Lua Telemetry script **requires** SmartPort telemetry as noted above.
> Lua Telemetry **won't work with Crossfire** for example because it uses proprietary sensor names/formatting and missing sensor information that Lua Telemetry needs.

## Setup

#### In INAV Configurator

1. Setup SmartPort telemetry to send to your transmitter - [INAV telemetry docs](https://github.com/iNavFlight/inav/blob/master/docs/Telemetry.md#smartport-sport-telemetry)
2. If you have an amperage sensor (which I highly suggest), configure `battery_capacity` to the mAh you want to draw from your battery and set `smartport_fuel_percent = ON` in CLI settings (allows proper calibration of fuel used percentage)

#### From Transmitter

1. With battery connected and **after GPS fix** [discover telemetry sensors](https://www.youtube.com/watch?v=n09q26Gh858) so all telemetry sensors are discovered
2. Telemetry distance sensor name **must** be changed from `0420` to `Dist` and set to the desired unit: `m` or `ft`
3. The sensors `Dist`, `Alt`, `GAlt` & `Gspd` can be changed to the desired unit: `m` or `ft` / `kmh` or `mph`
4. **Don't** change `Tmp1` or `Tmp2` from Celsius to Fahrenheit! They're not really temperatures but used for flight modes and GPS information

#### INAV Lua Telemetry Screen Setup

1. Download the Lua Telemetry ZIP file by clicking the top-right green `Clone or download` button and select `Download ZIP`
2. From the downloaded ZIP file, copy the `iNav.lua` file to the transmitter's SD card's `\SCRIPTS\TELEMETRY\` folder
3. Also from the ZIP file, copy the `iNav` folder to the transmitter's SD card's `\SCRIPTS\TELEMETRY\` folder
4. In model setup, page to `DISPLAY`, set desired screen to `Script`, and select `iNav`

## Notice

If you get the message **Script Panic not enough memory** you've run out of memory on your transmitter.
This happens if you have too many Lua scripts running (this includes model, function, and telemetry scripts).
It's also possible that you have less memory to work with when running firmware that uses more memory (for example, using firmware that includes multimodule support if you're not using it).
Using transmitter firmware with `luac` included will reduce memory usage and increase the telemetry screen speed.

## Usage

#### Screen Description
![sample](http://www.leethost.com/link_pics/iNav4.png "Screen description")

* From transmitter's main screen, hold the `Page` button to show custom screens, page to the iNav screen
* Flashing values indicate a warning (for example: no telemetry, battery low, altitude too high)
* To flip between max/min and current values, use the dial or +/- buttons
* To flip between compass-based direction and launch/pilot-based orientation and location, use the dial or +/- buttons
* The launch/pilot-based orientation view is useful if model orientation is unknown
* If model is further than 25 feet away, the launch/pilot-based view will show the direction of the model based upon launch/pilot position and orientation (useful to locate a lost model)
* The script gives voice feedback for flight modes, battery levels, and warnings (no need to manually set this up)
* Voice alerts will play in background even if iNav Lua Telemetry screen is not displayed

#### User Setting

At the top of the `iNav.lua` file a value can be modified to change how the battery voltage is displayed.

* **SHOW_CELL** `false` = Show total battery voltage / `true` = Show cell average (default = `false`)
* **WAVPATH** Path on your transmitter's SD card to the Lua Telemetry sound files (default = `"/SCRIPTS/TELEMETRY/iNav/"`)

## Tips & Notes

* Between flights (before armed), long-press the Enter/dial and select `Reset telemetry` to reset telemetry values
* Designed for multirotor models, but should be valuable for fixed wing (fixed wing feedback appreciated)
* Optional (but highly suggested) current sensor needed for fuel and current displays
* Uses transmitter settings for RSSI warning/critical levels for bar gauge range and audio/haptic warnings
* Uses transmitter settings for transmitter voltage min/max for battery bar gauge in screen title
* If you're not getting model distance data, change your telemetry distance sensor name from `0420` to `Dist`
* INAV v1.8+ is required for `Home reset` voice notification

## Release History

#### v1.1.8
* Fixed `FAILSAFE`, `RTH`, `NOT OK` & `NO TELEM` modes to flash as they should
* Altimeter (barometer) and magnetometer (compass) are now optional (but still suggested for full functionality)
* Split script up into multiple pieces to help reduce memory usage
* Additional easy to change constants at the top of the `iNav.lua` file
* Startup message/version and error if not running OpenTX v2.2.0 or later
#### v1.1.7
* Fix for the default unit type of the `Dist` (`0420`) sensor
#### v1.1.6
* On home reset, reset GPS home position, orientation and distance
* Option to display average battery cell voltage instead of total voltage
* Extra digit for data on X9D & X9D Plus transmitters
* Variable cleanup saving memory
#### v1.1.5 - 10/20/2017
* Voice notification for `Home Reset` with INAV v1.8+
* Moved head free warning on Q X7 to top center
* Values convert from decimal to integer when larger to allow for more room
* Better text centering and right justification technique
* Cleaned up code saving more memory
#### v1.1.4 - 10/13/2017
* More accurate max altitude alerts and altitude flashes when above max altitude
* Long-press <Enter> resets values (suggest doing this between flights before armed)
#### v1.1.3 - 10/10/2017
* Shows metric or imperial values based on transmitter telemetry settings
#### v1.1.2 - 10/06/2017
* Lots of refactoring which greatly reduced memory usage
* Re-enabled altitude bar gauge for X9D, X9D Plus & X9E transmitters
* Better information layout if no current sensor is present
* Refactored GPS lock calculation to prevent script syntax errors
#### v1.1.1 - 09/28/2017
* Refactored code to reduce memory
* Removed altitude bar gauge for X9D, X9D Plus & X9E transmitters (used too much memory?)
#### v1.1.0 - 09/22/2017
* Repo moved to INAVFlight
* Screen formatting for Taranis X9D, X9D Plus & X9E
#### v1.0.0 - 09/19/2017
* Initial release

## License

[MIT](https://github.com/iNavFlight/LuaTelemetry/blob/master/LICENSE)