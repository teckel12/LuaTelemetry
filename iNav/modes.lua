-- Modes: t=text / f=flags for text / w=wave file
local modes = {
  { t="NO TELEM",  f=3, w=false },
  { t="HORIZON",   f=0, w="hrznmd.wav" },
  { t="ANGLE",     f=0, w="anglmd.wav" },
  { t="ACRO",      f=0, w="acromd.wav" },
  { t=" NOT OK ",  f=3, w=false },
  { t="READY",     f=0, w="ready.wav" },
  { t="POS HOLD",  f=0, w="poshld.wav" },
  { t="3D HOLD",   f=0, w="3dhold.wav" },
  { t="WAYPOINT",  f=0, w="waypt.wav" },
  { t="PASSTHRU",  f=0, w=false },
  { t="   RTH   ", f=3, w="rtl.wav" },
  { t="FAILSAFE",  f=3, w="fson.wav" }
}

return modes[...]