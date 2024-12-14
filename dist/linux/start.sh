#!/bin/bash -i

Xvfb :99 -screen 0 16x16x8 &

export DISPLAY=:99

/usr/bin/wine /app/srcds.exe -game gesource +map ge_archives -insecure -norestart +sv_lan 1





xvfb-run -s "-screen 0 16x16x8" /usr/bin/wine /app/srcds.exe -game gesource +map ge_archives -console -insecure -norestart +sv_lan 1
