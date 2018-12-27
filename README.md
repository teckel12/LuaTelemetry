## INAV Lua Telemetry Flight Status for Taranis/Horus - v1.5.0

### FrSky SmartPort(S.Port), D-series and F.Port telemetry on all Taranis and Horus transmitters

[![Build Status](https://travis-ci.com/iNavFlight/LuaTelemetry.svg?branch=master)](https://travis-ci.com/iNavFlight/LuaTelemetry)

## Interface

#### [Video of Lua Telemetry](https://youtu.be/YaUgywuT1YM)

#### Classic view

![sample](assets/iNavQX7.png "Classic view on Q X7 and X-Lite")&nbsp;&nbsp;
![sample](assets/iNavX9D.png "Classic view on Taranis X9D, X9D+ and X9E")

#### Pilot (glass cockpit) view for fixed wing pilots

![sample](assets/iNavQX7pilot.png "Pilot view on Q X7 and X-Lite")&nbsp;&nbsp;
![sample](assets/iNavX9Dpilot.png "Pilot view on Taranis X9D, X9D+ and X9E")

#### Radar (map) view

![sample](assets/iNavQX7radar.png "Radar view on Q X7 and X-Lite")&nbsp;&nbsp;
![sample](assets/iNavX9Dradar.png "Radar view on Taranis X9D, X9D+ and X9E")

#### Horus view

![sample](assets/iNavHorus.png "View on Horus transmitters")

## Features

* Works with all FrSky telemetry receivers (X-series, R9 series and D-series) and all FrSky Taranis transmitters
* Launch/pilot-based model orientation and location indicators (great for lost orientation/losing sight of your model)
* Compass-based direction indicator (with compass on multirotor or fixed-wing with GPS)
* Pilot (glass cockpit) view which includes attitude indicator as well as pilot-familiar layout of additional data
* Radar (map) view shows model in relationship to home position, can be displayed either as launch/pilot-based or compass-based orientation
* Bar gauges for Fuel (% battery mAh capacity remaining), Battery voltage, RSSI strength, Transmitter battery, GPS accuracy (HDOP), Variometer (and Altitude for X9D, X9D+ and X9E transmitters)
* Display and voice alerts for flight modes and flight mode modifiers (altitude hold, heading hold, home reset, etc.)
* Voice notifications for % battery remaining (based on current), voltage low/critical, high altitude, lost GPS, ready to arm, armed, disarmed, etc.
* GPS info: Satellites locked, GPS accuracy (HDOP), GPS altitude, GPS coordinates. Also logs the last GPS location (reviewed from the config menu)
* If VTx control is desired, use [Taranis VTx](https://github.com/teckel12/Taranis-VTx) which uses less memory and allows for Lua Telemetry and VTx scripts to run together
* Display of current/maximum: Altitude, Distance, Speed and Current
* Display of current/minimum: Battery voltage, RSSI strength
* Title display of model name, flight timer, transmitter voltage and receiver voltage
* Menu configuration options can be changed from inside the script and are unique to each model on the transmitter
* Speed and distance values are displayed in metric or imperial based on transmitter's telemetry settings
* Voice files, modes and config menu in English, German, French or Spanish (more languages to follow)

## Requirements

* [OpenTX v2.2.0+](http://www.open-tx.org/) running on Taranis Q X7/Q X7S, X9D/X9D+, X9E, X-Lite, Horus X10/X10S or X12S (OpenTX v2.2.2+ is suggested)
* FrSky X-series, R9 series or D-series telemetry receiver: X4RSB, X8R, XSR, R-XSR, XSR-M, XSR-E, RX4R, RX6R, XM, XM+, R9, R9 Slim, R9 Slim+, R9 Mini, R9 MM, D8R-II plus, D8R-XP, D4R-II, etc.
* [INAV v1.7.3+](https://github.com/iNavFlight/inav/releases) running on your flight controller (INAV v2.0+ is suggested for full functionality)
* GPS - If you're looking for a GPS module, I suggest the [Beitian BN-880](https://www.banggood.com/UBLOX-NEO-M8N-BN-880-Flight-Control-GPS-Module-Dual-Module-Compass-p-971082.html)

## Suggested Sensors

* Altimeter/barometer (GPS altitude used if barometer not present)
* Magnetometer/compass for multi-rotor (fixed-wing craft use GPS for directional info)
* Current/amperage (for fuel gauge)

## Notes

* INAV v2.0+ is required for FrSky D-series telemetry and proper GPS accuracy (HDOP) display
* If using pilot view and INAV v2.0+, set `frsky_pitch_roll = ON` in CLI settings for more accurate attitude display
* INAV v1.9.1+ is required for F.Port compatibility
* INAV v1.8+ is required for `Home reset` voice notification
* OpenTX v2.2.2 (release version) is required for compatibility with Taranis X-Lite transmitter
* [Crossfire](https://github.com/iNavFlight/LuaTelemetry/issues/36) is not currently supported due to missing flight modes that are critical to Lua Telemetry

## Setup

* [Lua Telemetry Wiki](https://github.com/iNavFlight/LuaTelemetry/wiki)
* [Download latest release](https://github.com/iNavFlight/LuaTelemetry/releases/latest)
* [Installation Instructions](https://github.com/iNavFlight/LuaTelemetry/wiki/Installation)
* [Installation: Horus Widget](https://github.com/iNavFlight/LuaTelemetry/wiki/Installation:-Horus-Widget)
* [Upgrade Instructions](https://github.com/iNavFlight/LuaTelemetry/wiki/Upgrade)

## Information & Settings

* [Screen Description](https://github.com/iNavFlight/LuaTelemetry/wiki/Screen-Description)
* [Configuration Settings](https://github.com/iNavFlight/LuaTelemetry/wiki/Configuration-Settings)
* [Suggested Battery Settings](https://github.com/iNavFlight/LuaTelemetry/wiki/Suggested-Battery-Settings)
* [Change Log - Release History](https://github.com/iNavFlight/LuaTelemetry/wiki/Change-Log)

## Support

* [Tips & Common Problems](https://github.com/iNavFlight/LuaTelemetry/wiki/Tips-&-Common-Problems)
* [Support Issues](https://github.com/iNavFlight/LuaTelemetry/issues?q=is%3Aissue)

## Other

* [Upgrade to Development Build](https://github.com/iNavFlight/LuaTelemetry/wiki/Upgrade-to-Development-Build)
* [Multilingual Support](https://github.com/iNavFlight/LuaTelemetry/wiki/Multilingual-Support)
* [License](https://github.com/iNavFlight/LuaTelemetry/blob/master/LICENSE)
