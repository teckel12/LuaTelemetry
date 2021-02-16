# Release History
## v1.7.2 - 08/25/2019
- [Playback log files](../Configuration-Settings/#playback-telemetry-log-files) (may run out of memory on Taranis)
- Runs without luac or lua build options (broke in v1.7.1)
- Refactored code for higher speed and reduced memory usage
- Fix for french translation of OpenTX with the `RxBt` sensor labeled `BtRx`
- Crossfire: Add vertical speed option
- Crossfire: Fix for Q X7 Tx battery options
- Crossfire: Fix distance calculation errors
- Crossfire: Resolved edge-case yaw issue due to Crossfire rollover bug
- Horus: Home indicator now shows as a HUD indicator instead of a simple direction icon
- Horus: Uses vertical speed (if available) for better vertical placement of flight path vector icon
- Horus: Adds flight path vector support to S.Port/F.Port TELEMETRY (will require a yet to be released version of INAV) 
- Detect X9 Lite transmitter correctly

## v1.7.1 - 06/29/2019
- Uses "flat earth" algebra for faster orientation/distance calculation
- Crossfire on Horus: Option for flight path vector indicator
- Crossfire: Resolved default orientation bug
- Horus: Nice 15% speedup 
- Horus: Show satellite and HDOP (on S.Port) on config menu
- Horus: Changes to the config menu controls
- Horus: Trim 6 can be used while flying to switch between launch and compass-based orientation
- Horus: Added alternative location for speed and altitude units when certain options are enabled
- Horus: Distance value in radar always shows current distance (doesn't change when min/max is being viewed)
- Crossfire: Show total current drawn after flight when min/max is selected even if fuel % is usually shown
- Crossfire: Slightly better audio messages when exiting RTH
- Moved some things around and made a few functions to reduce memory usage
- Simplified things by using getRSSI() for both S.Port and Crossfire
- X9D: Altitude graph inverted so altitude values are grey and minute markers are dotted black
- Added automatic development mode for testing

## v1.7.0 - 06/03/2019
* Logs altitude graph in background so changing views doesn't halt altitude graph
* Refactored config options which saved a ton of memory
* Total rewrite of artificial horizon and pitch ladder, faster and better looking
* Horus: Optional roll indicator at top of attitude indicator
* Horus: 5 different aircraft symbols on attitude indicator (preview in config menu)
* Added support for [Jumper T16](https://www.jumper.xyz/) transmitter (operates just like Horus)
* Resolved bug that caused RSSI to always show 99dB on pilot, radar and altitude views
* Resolved bug that caused low voltage voice warning to occur too often if voltage was erratic 
* Horus: Resolved bug which caused `disabled` message to appear
* Report when GPS lock is lost, not sure when this was mistakenly removed
* Style changes to variometer on Horus and on Taranis pilot, map, and altitude views
* Q X7: Cleaned up distance, altitude and GPS coordinate data below altitude graph

## v1.6.1 - 03/29/2019
* Added new option for altitude graph (additional view on Taranis / map overlay on Horus)
* Config option to set max cell voltage for calculating cell count (primary use: LiHV batteries)
* Horus: Fix display bug that caused disabled error
* Horus: Further optimized view for faster rendering
* Crossfire: Better fuel percentage estimation when battery isn't full
* Update language files for new config menu options

## v1.6.0 - 01/21/2019
* Adds Crossfire support (requires INAV v2.1.0 or later)
* Horus: Enhanced display speed (up to 40% faster)
* Horus: Script variables initialize on flight/telemetry reset
* Compatible with Betaflight using FrSky X or R9 series receivers (with reduced functionality) and TBS Crossfire support with Betaflight 4.0+

## v1.5.1 - 01/04/2019
* Fixed draw error and HDOP graph on Q X7
* Fixed setting `View Mode` and `GPS HDOP View` on Taranis
* Restore color options fixed on Horus widget
* Warning message when not a full-screen widget on Horus
* Changed Horus widget option names to fit within 10 character limit

## v1.5.0 - 12/29/2018
* Added support for Horus transmitters
* Updated Spanish voice files
* Fixed km/h in radar view

## v1.4.3 - 11/13/2018
* Added French language voice files, modes and config menu (thanks @d00bld0ze)
* Added Spanish language voice files, modes and config menu (thanks @fmartinezo)
	* [Other language submissions encouraged!](../Multilingual-Support/)
* Instead of a single configuration shared by all models, it now uses a unique configuration for each model (be sure folder `\SCRIPTS\TELEMETRY\iNav\cfg` exists on the transmitter's SD card)
* Radar view UI tweaks
* Pitch added to QX7 display on radar view
* Heading hold indicator consistent for all views
* Better cell voltage value based on A4 sensor
* Better rounding for pitch and avoids ugly `-0°`
* Consolidated several complex routines into shared functions
* Uses Travis ci for pull request testing and future unit tests

## v1.4.2 - 09/28/2018

* New radar view shows model in relationship to home position, can be displayed either as launch/pilot-based or compass-based orientation
* Added German language voice files, modes and config menu (thanks @Peschi90). [Other language submissions encouraged!](../Multilingual-Support)
* New feature gives feedback when altitude hold is activated and throttle position is in neutral hover position (vibrate when entering neutral hover position and beep when exiting)
* Cycle through views by short-pressing `Enter`
* Config menu now works with X9E transmitter
* Resolve battery warnings when no current sensor is present
* Refactored to speed up script (uses a bit more memory as a result however)
* Created build script for Companion (should keep all files in sync)

## v1.4.1 - 08/25/2018

* Min/max values after flight added to pilot view
* For speed reasons, background and widget scripts moved back to core script, something in OpenTX 2.2.2 caused a great slow-down when loading scripts

## v1.4.0 - 08/21/2018

* Pilot view (glass cockpit) which includes attitude indicator as well as pilot-familiar layout of additional data
* Shows GPS fix accuracy (HDOP) as strength indicator graph or decimal value (required INAV 2.0.0)
* You can customize when weak GPS fix accuracy (HDOP) triggers alert
* Allows speed sensor selection between GPS speed or pitot sensor's air speed (if available)
* GPS coordinates and altitude are displayed before launch even if there's no GPS fix
* Fuel can report mAh or mWh used instead of percent fuel remaining (percent highly suggested for fuel level alerts)
* The setup, config menu and views loads as separate scripts, greatly reducing memory used
* Variometer graph now correctly uses vertical speed as source instead of Z-axis accelerometer
* Config option under Variometer to also report altitude as voice notifications
* X9D display now uses gray when appropriate to enhance view clarity
* Disable config setting (and set to default) if sensor isn't present
* Config menu wraps from top to bottom (and vice versa) to more easily locate desired config option, also remembers last menu option
* Config menu supports button hold-repeat on X9D and X9D+ to make changes easier
* Config menu fuel percentage warning and critical changed to 1% steps to increase flexibility
* Only shows the last good GPS coordinates instead of the last 5 to reduce complexity (didn't provide more useful info either)
* Removed `getLastPos()` function dependency which is faster, cleans up code and could allow Horus support
* Fixed an issue with "NO TELEM" and "THR WARN" being displayed incorrectly
* Cleaned up readme, broke up into Wiki pages

## v1.3.1 - 05/29/2018

* Support added for the X-Lite transmitter (requires OpenTX v2.2.2)
* Option to set the low and critical warning level for fuel percentage remaining
* Option to display the transmitter voltage as a graph and/or the numerical value
* Modified how battery cell count is calculated
* Can now set cell critical voltage to as low as 2.6v to support 18650 batteries
* Slightly adjusted display positioning to show greater GPS accuracy on QX7 and X-Lite transmitters

## v1.3.0 - 05/13/2018

* Compatibility with new F.Port protocol (requires INAV v1.9.1+)
* Support added for D-series receivers with telemetry (requires INAV v2.0+)
* Option to show GPS coordinates as degrees and minutes or in geocoding format instead of the previous decimal only
* Shows `THR WARN` if not okay to fly and throttle isn't at minimum position
* If distance sensor name is the default `0420`, the max distance now displays correctly
* Updated data digits to display before truncating unit of measure

## v1.2.5 - 04/28/2018

* Uses GPS for launch-based altitude if barometer isn't present
* No longer requires `0420` sensor to be renamed `Dist`
* Better error handling, specially if `iNav` folder doesn't exist
* Renamed PASSTHRU mode MANUAL and add audio file for manual mode
* Correct altitude unit designation in configuration when barometer isn't present
* Adjustment to data display for min/max indicator

## v1.2.4 - 04/17/2018

* Satellite and altitude hold are now icons
* Added flashing notification for headfree mode on QX7 (already existed on X9D)
* Smarter unit designation resulting in a cleaner display (ft = ', MPH & km/h)

## v1.2.3 - 12/19/2017

* Logs the last 5 unique GPS coordinates
* Updated readme screenshots to show variometer
* Release history is now here instead of in readme file

## v1.2.2 - 12/09/2017

* Last 5 GPS coordinates can be reviewed from the config menu
* Resolved issue where if telemetry was lost/recovered it would incorrectly give voice alerts for flight modes/engines armed/disarmed
* Config menu can be accessed at any time, even when armed

## v1.2.1 - 12/01/2017

* Lots of new/changed config settings (press `Menu` button to access) - **Please review!**
* Enhanced and cleaned up config menu, centered menu on QX7 & X9D/+
* Variometer shows if model is gaining or decreasing altitude
* Cell voltage battery view shows with two digits of precision
* Added `S` (South) to X9D/+ directional display

## v1.2.0 - 11/18/2017

* Lua Telemetry is now pre-compiled to greatly reduce memory (source still available)
* Press `Menu` button (when not armed) to modify user configuration options
* Fixed `FAILSAFE`, `RTH`, `NOT OK` & `NO TELEM` modes to flash as they should
* Barometer and magnetometer are now optional (but suggested for full functionality)
* Headfree indication on QX7 changed to show directional indicators as dotted lines
* Startup message/version and error if not running OpenTX v2.2.0 or later

## v1.1.7 - 11/02/2017

* Fix for the default unit type of the `Dist` (`0420`) sensor

## v1.1.6 - 11/01/2017

* On home reset, reset GPS home position, orientation and distance
* Option to display average battery cell voltage instead of total voltage
* Extra digit for data on X9D & X9D+ transmitters
* Variable cleanup saving memory

## v1.1.5 - 10/20/2017

* Voice notification for `Home Reset` with INAV v1.8+
* Moved head free warning on QX7 to top center
* Values convert from decimal to integer when larger to allow for more room
* Better text centering and right justification technique
* Cleaned up code saving more memory

## v1.1.4 - 10/13/2017

* More accurate max altitude alerts and altitude flashes when above max altitude
* Long-press <Enter> resets values (suggest doing this between flights before armed)

## v1.1.3 - 10/10/2017

* Shows metric or imperial values based on transmitter telemetry settings

## v1.1.2 - 10/06/2017

* Lots of refactoring which greatly reduced memory usage
* Re-enabled altitude bar gauge for X9D, X9D+ & X9E transmitters
* Better information layout if no current sensor is present
* Refactored GPS lock calculation to prevent script syntax errors

## v1.1.1 - 09/28/2017

* Refactored code to reduce memory
* Removed altitude bar gauge for X9D, X9D+ & X9E transmitters (used too much memory?)

## v1.1.0 - 09/22/2017

* Repository moved to INAVFlight
* Screen formatting for Taranis X9D, X9D+ & X9E

## v1.0.0 - 09/19/2017

* Initial release