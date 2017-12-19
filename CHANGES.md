# Release History

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
* Enhanced and cleaned up config menu, centered menu on Q X7 & X9D/+
* Variometer shows if model is gaining or decreasing altitude
* Cell voltage battery view shows with two digits of precision
* Added `S` (South) to X9D/+ directional display
## v1.2.0 - 11/18/2017
* Lua Telemetry is now pre-compiled to greatly reduce memory (source still available)
* Press `Menu` button (when not armed) to modify user configuration options
* Fixed `FAILSAFE`, `RTH`, `NOT OK` & `NO TELEM` modes to flash as they should
* Barometer and magnetometer are now optional (but suggested for full functionality)
* Headfree indication on Q X7 changed to show directional indicators as dotted lines
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
* Moved head free warning on Q X7 to top center
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

