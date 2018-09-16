# Lua Telemetry Flight Status for INAV/Taranis - v1.4.2

### FrSky SmartPort(S.Port), D-series, and F.Port telemetry on Taranis QX7, X-Lite, X9D, X9D+ and X9E transmitters

## Screenshots

#### Classic view on Taranis QX7 and X-Lite

![sample](assets/iNavQX71.png "Launch/pilot-based model orientation and location indicators")&nbsp;&nbsp;
![sample](assets/iNavQX72.png "Compass-based direction indicator")

#### Classic view on Taranis X9D, X9D+ and X9E

![sample](assets/iNavX9D.png "Classic view on Taranis X9D, X9D+ and X9E")

#### Pilot view for fixed wing pilots

![sample](assets/iNavQX7pilot.png "Pilot view on QX7 and X-Lite")&nbsp;&nbsp;
![sample](assets/iNavX9Dpilot.png "Pilot view on Taranis X9D, X9D+ and X9E")

## Features

* Works with all FrSky telemetry receivers (X-series, R9 series and D-series) and all FrSky Taranis transmitters
* Launch/pilot-based model orientation and location indicators (great for lost orientation/losing sight of your model)
* Compass-based direction indicator (with compass on multirotor or fixed-wing with GPS)
* Pilot view (glass cockpit) which includes attitude indicator as well as pilot-familiar layout of additional data
* Bar gauges for Fuel (% battery mAh capacity remaining), Battery voltage, RSSI strength, Transmitter battery, GPS accuracy (HDOP), Variometer (and Altitude for X9D, X9D+ and X9E transmitters)
* Display and voice alerts for flight modes and flight mode modifiers (altitude hold, heading hold, home reset, etc.)
* Voice notifications for % battery remaining (based on current), voltage low/critical, high altitude, lost GPS, ready to arm, armed, disarmed, etc.
* GPS info: Satellites locked, GPS accuracy (HDOP), GPS altitude, GPS coordinates. Also logs the last GPS location (reviewed from the config menu)
* If VTx control is desired, use [Taranis VTx](https://github.com/teckel12/Taranis-VTx) which uses less memory and allows for Lua Telemetry and VTx scripts to run together
* Display of current/maximum: Altitude, Distance, Speed and Current
* Display of current/minimum: Battery voltage, RSSI strength
* Title display of model name, flight timer, transmitter voltage and receiver voltage
* Menu configuration options can be changed from inside the script
* Speed and distance values are displayed in metric or imperial based on transmitter's telemetry settings

## Requirements

* [OpenTX v2.2.0+](http://www.open-tx.org/) running on Taranis QX7, X9D, X9D+, X9E or X-Lite (with release OpenTX v2.2.2+) Suggested: OpenTX 2.2.2 release
* FkSky X-series, R9 series or D-series telemetry receiver: X4RSB, X8R, XSR, R-XSR, XSR-M, XSR-E, R9, R9 Slim, R9M, D8R-II plus, D8R-XP, D4R-II, etc.
* [INAV v1.7.3+](https://github.com/iNavFlight/inav/releases) running on your flight controller (INAV v2.0+ is suggested for full functionality)
* GPS - If you're looking for a GPS module, I suggest the [Beitian BN-880](https://www.banggood.com/UBLOX-NEO-M8N-BN-880-Flight-Control-GPS-Module-Dual-Module-Compass-p-971082.html)

## Suggested Sensors

* Altimeter/barometer (GPS altitude used if barometer not present)
* Magnetometer/compass for multi-rotor (fixed-wing craft use GPS for directional info)
* Current/amperage (for fuel gauge)

## Notes

* INAV v2.0+ is required for FkSky D-series telemetry and proper GPS accuracy (HDOP) display
* If using pilot view and INAV v2.0+, set `frsky_pitch_roll = ON` in CLI settings for more accurate attitude display
* INAV v1.9.1+ is required for F.Port compatibility
* INAV v1.8+ is required for `Home reset` voice notification
* OpenTX v2.2.2 (release version) is required for compatibility with Taranis X-Lite transmitter
* Crossfire is **NOT** supported due to missing telemetry data required by Lua Telemetry
    * Lua Telemetry can't fix this, Crossfire has missing flight mode info Lua Telemetry requires
* FrSky Horus transmitters are not currently supported due to the missing draw flags: `ERASE` and `FORCED`

## Setup

* [Lua Telemetry Wiki](https://github.com/iNavFlight/LuaTelemetry/wiki)
* [Download latest release](https://github.com/iNavFlight/LuaTelemetry/releases/latest)
* [Installation Instructions](https://github.com/iNavFlight/LuaTelemetry/wiki/Installation)
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
* [License](https://github.com/iNavFlight/LuaTelemetry/blob/master/LICENSE)
