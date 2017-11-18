-- Modes: t=text / f=flags for text / w=wave file
local modes = {
  { t="NO TELEM",  f=3, w=false },
  { t="HORIZON",   f=0, w="hrznmd" },
  { t="ANGLE",     f=0, w="anglmd" },
  { t="ACRO",      f=0, w="acromd" },
  { t=" NOT OK ",  f=3, w=false },
  { t="READY",     f=0, w="ready" },
  { t="POS HOLD",  f=0, w="poshld" },
  { t="3D HOLD",   f=0, w="3dhold" },
  { t="WAYPOINT",  f=0, w="waypt" },
  { t="PASSTHRU",  f=0, w=false },
  { t="   RTH   ", f=3, w="rtl" },
  { t="FAILSAFE",  f=3, w="fson" }
}

return modes[...]