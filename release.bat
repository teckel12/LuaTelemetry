@echo off
cd dist

rm ..\..\LuaTelemetry-Taranis-English.zip
rm ..\..\LuaTelemetry-Taranis-Multi.zip
rm ..\..\LuaTelemetry-Horus-English.zip
rm ..\..\LuaTelemetry-Horus-Multi.zip

zip -9 -q -r ..\..\LuaTelemetry-Taranis-English.zip SCRIPTS/* -x *.lua -x *.dat -x SCRIPTS/TELEMETRY/iNav/pics/* -x SCRIPTS/TELEMETRY/iNav/de/* -x SCRIPTS/TELEMETRY/iNav/es/* -x SCRIPTS/TELEMETRY/iNav/fr/*
zip -9 -q -r ..\..\LuaTelemetry-Taranis-Multi.zip SCRIPTS/* -x *.lua -x *.dat -x SCRIPTS/TELEMETRY/iNav/pics/*
zip -9 -q -r ..\..\LuaTelemetry-Horus-English.zip SCRIPTS/* WIDGETS/* -x *.lua -x *.dat -x SCRIPTS/TELEMETRY/iNav/pics/* -x SCRIPTS/TELEMETRY/iNav/de/* -x SCRIPTS/TELEMETRY/iNav/es/* -x SCRIPTS/TELEMETRY/iNav/fr/*
zip -9 -q -r ..\..\LuaTelemetry-Horus-Multi.zip SCRIPTS/* WIDGETS/* -x *.lua -x *.dat -x SCRIPTS/TELEMETRY/iNav/pics/*

zip -9 -q ..\..\LuaTelemetry-Taranis-English.zip SCRIPTS/TELEMETRY/iNav.lua
zip -9 -q ..\..\LuaTelemetry-Taranis-Multi.zip SCRIPTS/TELEMETRY/iNav.lua
zip -9 -q ..\..\LuaTelemetry-Horus-English.zip SCRIPTS/TELEMETRY/iNav.lua WIDGETS/iNav/main.lua
zip -9 -q ..\..\LuaTelemetry-Horus-Multi.zip SCRIPTS/TELEMETRY/iNav.lua WIDGETS/iNav/main.lua

cd ..