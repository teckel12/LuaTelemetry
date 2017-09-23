# Lua Telemetry Flight Status Screen for INAV/Taranis

#### Taranis Q X7
![sample](http://www.leethost.com/link_pics/iNav1.png "Launch-based model orientation and location indicators")
![sample](http://www.leethost.com/link_pics/iNav2.png "Compass-based direction indicator")

#### Taranis X9D, X9D+ & X9E
![sample](http://www.leethost.com/link_pics/iNav3.png "View on Taranis X9D, X9D+ & X9E")

## Features

* Launch-based model orientation and location indicators (great for lost orientation or if you lose site of your model)
* Compass-based direction indicator
* Bar graphs for Fuel (% battery mAh capacity remaining), Battery voltage, RSSI strength, Tx battery (and Altitude for X9D, X9D+ & X9E transmitters)
* Display and speech notifications of flight modes and other flight status information (altitude hold, heading hold, etc.)
* Speech notifications for % battery remaining (based on current), voltage low/critical, high altitude, lost GPS, ready to arm, armed, disarmed, etc.
* GPS information: Satellites locked, GPS altitude, GPS coordinates
* Display of current/maximum: Altitude, Distance, Speed and Current
* Display of current/minimum: Battery voltage, RSSI strength
* Display of current Fuel (% battery mAh capacity remaining), Rx voltage and automatic flight timer

## Requirements

* [OpenTX v2.2.0](http://www.open-tx.org/) running on Taranis Q X7, X9D, X9D+ & X9E
* A FrSky receiver that supports telemetry, such as X4R(SB), X8R, XSR, R-XSR, XSR-M, XSR-E, etc.
* [INAV v1.7.3+](https://github.com/iNavFlight/inav/releases) running on your flight controller
* GPS, altimeter, and compass sensors

#### Notes

* Designed to work on a Taranis Q X7, X9D, X9D+ & X9E (currently only tested on Q X7)
* Designed for a multirotor model, but should be valuable for fixed wing (fixed wing feedback would be appreciated)
* Optional amperage sensor needed for fuel and current displays
* Uses Taranis settings for RSSI warning/critical levels for graph and audio/vibration warnings
* Uses Taranis settings for transmitter voltage min/max for battery graphic in screen title

## Setup

#### In INAV Configurator

1. Setup telemetry to send to your transmitter - [INAV telemetry docs](https://github.com/iNavFlight/inav/blob/master/docs/Telemetry.md)
2. If you have an amperage sensor, configure `battery_capacity` and set `smartport_fuel_percent = ON` in CLI settings

#### From Transmitter

1. Discover telemetry sensors after GPS fix so all telemetry sensors are discovered
2. Telemetry distance sensor name must be changed from `0420` to `Dist`
3. Sensors must be changed to US measurements (m to ft, km/h to mph, etc) for proper calibration

#### INAV Lua Script Setup

1. Copy `iNav.lua` file to Taranis SD card's `\SCRIPTS\TELEMETRY\` folder
2. Copy `iNav` folder to Taranis SD card's `\SCRIPTS\TELEMETRY\` folder
3. In model setup, page to `DISPLAY`, set desired screen to `Script`, and select `iNav`

## Usage

#### Screen Description
![sample](http://www.leethost.com/link_pics/iNav4.png "Screen description")

From the Taranis main screen, hold the `Page` button to show custom screens, then page to the screen you set to show iNav.
Flashing values are either because there's no telemetry or a warning.
To flip between max/min values and current values, use the dial or +/- buttons.
To flip between compass-based direction and launch-based orientation and location, use the dial or +/- buttons.
If model is further than 25 feet away, the launch direction view will show the direction of the model based upon launch position and orientation.
This can be used to locate a lost model, using the launch-based model location indicator and distance.
The launch-based orientation view is useful if model orientation is unknown.
The script gives audio feedback for flight modes, battery levels, and warnings (no need to manually set this up for each model).
Audio feedback will play in background even if iNav LuaTelemetry screen is not displayed.

## Release History

#### v1.1 - 09/22/2017
* Repo moved to INAVFlight
* Screen formatting for Taranis X9D, X9D+ & X9E
#### v1.0 - 09/19/2017
* Initial release

## Todo

* Automatically switch between metric and imperial (currently fixed to imperial)
* Possible option to display value of timer instead of automatic flight timer built into script
* Options for when speech/sound files play (may be too chatty for some)
