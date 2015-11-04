docker-csgoserver Dockerfile
===========

Counter-Strike: Global Offensive Dedicated Server Docker Image

This dockerfile uses the Daniel Gibbs' [linux game server mangers cs:go script](http://gameservermanagers.com/lgsm/csgoserver/) to start an instance of cs:go server. Settings passed onto the server during runtime (such as default map and servername) are environment variables that can be overridden when creating the Docker instance.

```
docker run -p 27015:27015 -p 27015:27015/udp -e EMAIL_NOTIFICATION='off' -e EMAIL='email@example.com' -e STEAM_USER='anonymous' -e STEAM_PASS='' -e GAME_MODE='0' -e GAME_TYPE='0' -e DEFAULT_MAP='de_dust2' -e MAP_GROUP='random_classic' -e MAX_PLAYERS='16' -e TICK_RATE='64' -e GAME_PORT='27015' -e SOURCE_TV_PORT='27020' -e CLIENT_PORT='27005' -e GAME_IP='0.0.0.0' -e UPDATE_ON_START='off' -e AUTH_KEY='' -e WS_COLLECTION_ID='' -e WS_START_MAP='' -e SERVER_NAME='Counter Strike: Global Offensive Docker Server' -e RCON_PASS='rconpass' -e SERVER_PASS='' -e SERVER_LAN='0' -e SERVER_REGION='0' --name docker-csgoserver -d austinsaintaubin/docker-csgoserver
```

TODO:
* Instructions
* A mechanism to copy maps and deeper config files into the new instances. (probably through ADD commands)