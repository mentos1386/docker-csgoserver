docker-csgoserver Dockerfile
===========

Counter-Strike: Global Offensive Dedicated Server Docker Image

This dockerfile uses the Daniel Gibbs' [linux game server mangers cs:go script](http://gameservermanagers.com/lgsm/csgoserver/) to start an instance of cs:go server. Settings passed onto the server during runtime (such as default map and servername) are environment variables that can be overridden when creating the Docker instance.

TODO:
* Instructions
* A mechanism to copy maps and deeper config files into the new instances. (probably through ADD commands)