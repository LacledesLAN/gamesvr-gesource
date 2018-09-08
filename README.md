# GoldenEye Source Dedicated Server In Docker

GoldenEye: Source is an online multiplayer arena first-person shooter that aims to provide a faithful and also expanded re-creation of GoldenEye 007's multiplayer including additional game modes, re-creations of single-player levels that were not originally accessible in GoldenEye 007's multiplayer modes, and weapons which were only accessible using cheats.

[![GoldenEye Source Trailer](https://raw.githubusercontent.com/LacledesLAN/gamesvr-gesource/master/.misc/video-thumb.jpg)](https://www.youtube.com/watch?v=-E4XtdEnWx4)

## Linux Container

[![Build Status](https://travis-ci.org/LacledesLAN/gamesvr-gesource.svg?branch=master)](https://travis-ci.org/LacledesLAN/gamesvr-gesource)
[![](https://images.microbadger.com/badges/image/lacledeslan/gamesvr-gesource.svg)](https://microbadger.com/images/lacledeslan/gamesvr-gesource "Get your own image badge on microbadger.com")

### Download

```shell
docker pull lacledeslan/gamesvr-srcds-gesource:linux
```

### Run Self Tests

```shell
docker run --rm lacledeslan/gamesvr-gesource ./ll-tests/gamesvr-gesource.sh
```

### Run Simple, Interactive Server

```shell
docker run -it --rm --net=host lacledeslan/gamesvr-gesource /bin/bash -c "export MALLOC_CHECK_=0 && ./srcds_run -game ge_depot +map ge_archives +sv_lan 1 +maxplayers 16"
```
