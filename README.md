# GoldenEye Source Dedicated Server In Docker

GoldenEye: Source is an online multiplayer arena first-person shooter that aims to provide a faithful but expanded recreation of GoldenEye 007's multiplayer including additional game modes, re-creations of single-player levels that were not originally accessible in GoldenEye 007's multiplayer modes, and weapons which were only accessible using cheats.

[![GoldenEye Source Trailer](https://raw.githubusercontent.com/LacledesLAN/gamesvr-gesource/master/.misc/video-thumb.jpg)](https://www.youtube.com/watch?v=-E4XtdEnWx4)

This repository is maintained by [Laclede's LAN](https://lacledeslan.com). Its contents are intended to be bare-bones and used as a stock server. For examples of building a customized server from this Docker image see its related child-project [gamesvr-gesource-freeplay](https://github.com/LacledesLAN/gamesvr-gesource-freeplay). If any documentation is unclear or it has any issues please see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Linux Container

[![linux/amd64](https://github.com/LacledesLAN/gamesvr-gesource/actions/workflows/build-linux-image.yml/badge.svg?branch=master)](https://github.com/LacledesLAN/gamesvr-gesource/actions/workflows/build-linux-image.yml)

### Download

```shell
docker pull lacledeslan/gamesvr-gesource
```

### Run Self Tests

The image includes a test script that can be used to verify its contents. No changes or pull-requests will be accepted to this repository if any tests fail.


```shell
docker run --rm lacledeslan/gamesvr-gesource ./ll-tests/gamesvr-gesource.sh
```

### Run Simple, Interactive Server

```shell
docker run -it --rm --net=host lacledeslan/gamesvr-gesource ./srcds_run -game gesource +map ge_depot +sv_lan 1 +maxplayers 16
```

## Getting Started with Game Servers in Docker

[Docker](https://docs.docker.com/) is an open-source project that bundles applications into lightweight, portable, self-sufficient containers. For a crash course on running Dockerized game servers check out [Using Docker for Game Servers](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/DockerAndGameServers.md). For tips, tricks, and recommended tools for working with Laclede's LAN Dockerized game server repos see the guide for [Working with our Game Server Repos](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/WorkingWithOurRepos.md). You can also browse all of our other Dockerized game servers: [Laclede's LAN Game Servers Directory](https://github.com/LacledesLAN/README.1ST/tree/master/GameServers).

## Useful Links

* [Server Command Reference](https://wiki.geshl2.com/goldeneye/server/cmds) ([archive]())
