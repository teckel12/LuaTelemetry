# Upgrade INAV Telemetry
## Already have Lua Telemetry installed
If you're already running Lua Telemetry, you can quickly upgrade to the latest release version by following these simple steps:

1. Download the latest [LuaTelemetry.zip](https://github.com/iNavFlight/LuaTelemetry/releases/latest) file (Note: **NOT** the source code)
1. Copy the contents of the ZIP file (`SCRIPTS` and `WIDGETS` folders) to the transmitter's SD card's root

![](http://www.leethost.com/link_pics/master.png)

And you're ready to go!

## Upgrade to development build

> **Please note:** These instructions are for upgrading from a previous version of Lua Telemetry.  If you haven't yet installed Lua Telemetry, you'll need to first do a full installation and then follow these instructions.

Typically, the development branch of Lua Telemetry is fairly bug free.  For the most part, features are added and tested before merging to development.  Current status of development branch:

[![Build Status](https://travis-ci.com/iNavFlight/LuaTelemetry.svg?branch=development)](https://travis-ci.com/iNavFlight/LuaTelemetry)

To upgrade to the development build, use the following instructions:

1. Download [LuaTelemetry-development.zip](https://github.com/iNavFlight/LuaTelemetry/archive/development.zip)
1. Open or extract the `LuaTelemetry-development.zip` file
1. Open the `LuaTelemetry-development` folder and navigate to the `dist` folder
1. Copy the contents of the `dist` folder (`SCRIPTS` and `WIDGETS` folders) to the transmitter's SD card's root

![](http://www.leethost.com/link_pics/development.png)

You'll also sometimes need the latest INAV build to go along with the development branch of Lua Telemetry.  So it's also a good idea to [upgrade INAV](https://github.com/iNavFlight/inav/releases) to the latest release.  If there's ever an issue, you can roll back to the latest release by following the [upgrade](../Upgrade) instructions.