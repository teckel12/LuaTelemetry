### Currently supported ([language submissions encouraged!](Multilingual-Support/#adding-new-language))

  - [ ] Czech (cz)
  - [ ] Dutch (nl)
  - [X] English (en)
  - [X] French (fr)
  - [X] German (de)
  - [ ] Hungarian (hu)
  - [ ] Italian (it)
  - [ ] Polish (pl)
  - [ ] Portuguese (pt)
  - [ ] Russian (ru)
  - [ ] Slovak (sk)
  - [X] Spanish (es)
  - [ ] Swedish (se)

### How to select a supported language
Lua Telemetry uses the OpenTX settings for multilingual support.  If language voice files or language translation file doesn't exist, Lua Telemetry will default to English.

* To change the voice prompts you set the `Voice Language` setting on the `RADIO SETUP` menu.  You'll need to cycle power to your transmitter for Lua Telemetry to see the change.

* For the flight modes and config menu translation, you need to be running OpenTX firmware with the desired Menu Language.  From the OpenTX Companion:
1. Go to `Settings` (the gear icon)
1. Select the desired `Menu Language`
1. Download firmware
1. Write firmware to radio.

### Adding new language
To add support for one of the above languages, follow these steps:

1. Language voice files need to be created.  Here's is a [list of the 32 voice files required](https://github.com/iNavFlight/LuaTelemetry/tree/development/dist/SCRIPTS/TELEMETRY/iNav/en)
1. A `lang_XX.lua` language translation file needs to be created.  Here's an example of the German translation file: [lang_de.lua](https://github.com/iNavFlight/LuaTelemetry/development/src/iNav/lang_de.lua) (note the maximum character length comments)

The voice and translation files can be submitted in a PR or you can [create a feature request issue](https://github.com/iNavFlight/LuaTelemetry/issues/new/choose) and attach the files and I'll take care of it.  Either way, be prepared to possibly do some tweaking if the translation lengths are too long.