---
name: "\U0001F4A5 Attempt to call a nil value"
about: Are you getting the message "Attempt to call a nil value"?
title: ''
labels: support
assignees: teckel12
---

If you're getting an `Attempt to call a nil value` error, it either means you don't have the `luac` build option checked for your OpenTX/JumperTX firmware or you're out of memory on your transmitter.  The Taranis series has very little free memory to work with for Lua scripts, so this error is quite common.  There's a few things that typically cause this error which are listed below:

1) Be sure the OpenTX/JumperTX firmware on your transmitter includes the `luac` build option, video instructions linked here:

https://youtu.be/nYeB0IXT-10?t=283

2) When installing Lua Telemetry, be sure to download the latest LuaTelemetry.zip linked here:

https://github.com/iNavFlight/LuaTelemetry/releases/latest

Also, please see the following instructions for correct installation:

https://github.com/iNavFlight/LuaTelemetry/wiki/Installation

3) Another possible reason for this error is that you're trying to use other Lua scripts on the same model. While you can have multiple Lua scripts for the same model, there's not much memory to work with on the Taranis transmitters. For example, if you're trying to use the Betaflight Tx lua script as well as Lua Telemetry, you'll probably run out of memory.  If VTx control is desired, try using the OSD menu which allows you to change VTx settings right on the OSD.

4) Too many unused models. Each model slot setup in your transmitter takes up valuable memory.  Many times models are backed up to tweak settings without deleting the backups when finished.  By deleting unused models, memory is freed that can be used for other things, like Lua scripts.

As this is a common issue that I've tried to cover in the Wiki, I would appreciate if you could let me know how the instructions could be improved to avoid any confusion.

Thanks!