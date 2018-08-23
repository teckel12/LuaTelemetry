---
name: "\U0001F4A5 Not enough memory error"
about: Are you getting a "not enough memory error"?

---

If you're getting a `not enough memory error` it means you're out of memory on your transmitter.  The Taranis series has very little free memory to work with for Lua Scripts, so this error is quite common.  But, there are a few things that typically cause the error that can be avoided.  These are outlined in the Lua Telemetry README file and listed below:

1) You must use the release ZIP file for installation and not the Lua script file in the `src` folder.  The script in the `src` folder is not compiled and there's not enough memory on the Taranis transmitter to compile the script.  Please see the following instructions for correct installation:

https://github.com/iNavFlight/LuaTelemetry/wiki/Installation

2) The other possible problem is that you're trying to use other Lua scripts on the same model. While you can have multiple scripts on the same model, there's not much memory to work with on the Taranis transmitters. For example, if you're trying to use the Betaflight Tx lua script as well as Lua Telemetry, you'll probably run out of memory.  If VTx control is desired, use Taranis VTx from the following link which uses less memory and allows for Lua Telemetry and VTx scripts to run together:

https://github.com/teckel12/Taranis-VTx

3) Too many unused models. Each model slot setup in your transmitter takes up valuable memory.  Many times models are backed up to tweak settings without deleting the backups when finished.  By deleting unused models, memory is freed that can be used for other things, like Lua scripts.

As this is a common issue that seems clear by the error message, is covered in the README file, and not a direct result of Lua Telemetry, I would appreciate it if you could let me know how the instructions could be improved to avoid any confusion.

Thanks!