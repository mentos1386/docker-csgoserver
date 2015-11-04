FROM ubuntu
MAINTAINER Austin St. Aubin <AustinSaintAubin@gmail.com>

#### Variables ####
ENV SERVER_NAME "Counter Strike: Global Offensive Docker Server"
ENV RCON_PASS rconpass
ENV SERVER_PASS ""
ENV SERVER_LAN 0
ENV SERVER_REGION 0

# Notification Email
# (on|off)
ENV EMAIL_NOTIFICATION off
ENV EMAIL email@example.com

# STEAM LOGIN
ENV STEAM_USER anonymous
ENV STEAM_PASS ""

# Start Variables
# https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#Starting_the_Server
# [Game Modes]           gametype    gamemode
# Arms Race                  1            0
# Classic Casual             0            0
# Classic Competitive        0            1
# Demolition                 1            1
# Deathmatch                 1            2
ENV GAME_MODE 0
ENV GAME_TYPE 0
ENV DEFAULT_MAP de_dust2
ENV MAP_GROUP random_classic
ENV MAX_PLAYERS 16
ENV TICK_RATE 64
ENV GAME_PORT 27015
ENV SOURCE_TV_PORT 27020
ENV CLIENT_PORT 27005
ENV GAME_IP 0.0.0.0
ENV UPDATE_ON_START off

# Optional: Workshop Parameters
# https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators
# To get an authkey visit - http://steamcommunity.com/dev/apikey
ENV AUTH_KEY ""
ENV WS_COLLECTION_ID ""
ENV WS_START_MAP ""

# Expose Ports
EXPOSE $GAME_PORT
EXPOSE $GAME_PORT/udp
EXPOSE $SOURCE_TV_PORT/udp
EXPOSE $CLIENT_PORT/udp
#EXPOSE 1200/udp

#RUN dpkg --add-architecture i386
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -qqy wget tmux mailutils postfix lib32gcc1 \
     					 gdb ca-certificates bsdmainutils

# script refuses to run in root, create user
RUN useradd -m csgoserver
RUN adduser csgoserver sudo
USER csgoserver
WORKDIR /home/csgoserver

# download Counter-Strike: Global Offensive Dedicated Server Manager script
RUN wget http://gameservermanagers.com/dl/csgoserver
RUN chmod +x csgoserver

# Edit Server Script to hold Docker Environmental Varables
RUN sed '/emailnotification=/s/"\([^"]*\)"/"$EMAIL_NOTIFICATION"/;
         /email=/s/"\([^"]*\)"/"$EMAIL"/;
         /steamuser=/s/"\([^"]*\)"/"$STEAM_USER"/;
         /steampass=/s/"\([^"]*\)"/"$STEAM_PASS"/;
         /gamemode=/s/"\([^"]*\)"/"$GAME_MODE"/;
         /gametype=/s/"\([^"]*\)"/"$GAME_TYPE"/;
         /defaultmap=/s/"\([^"]*\)"/"$DEFAULT_MAP"/;
         /mapgroup=/s/"\([^"]*\)"/"$MAP_GROUP"/;
         /maxplayers=/s/"\([^"]*\)"/"$MAX_PLAYERS"/;
         /tickrate=/s/"\([^"]*\)"/"$TICK_RATE"/;
         /port=/s/"\([^"]*\)"/"$GAME_PORT"/;
         /sourcetvport=/s/"\([^"]*\)"/"$SOURCE_TV_PORT"/;
         /clientport=/s/"\([^"]*\)"/"$CLIENT_PORT"/;
         /ip=/s/"\([^"]*\)"/"$GAME_IP"/;
         /updateonstart=/s/"\([^"]*\)"/"$UPDATE_ON_START"/;
         /authkey=/s/"\([^"]*\)"/"$AUTH_KEY"/;
         /ws_collection_id=/s/"\([^"]*\)"/"$WS_COLLECTION_ID"/;
         /ws_start_map=/s/"\([^"]*\)"/"$WS_START_MAP"/' csgoserver

# Run Install Script
RUN ./csgoserver -autoinstall

# Edit Server Config to hold Docker Environmental Varables
RUN sed '/hostname/s/"\([^"]*\)"/"$SERVER_NAME"/;
         /rcon_password/s/"\([^"]*\)"/"$RCON_PASS"/;
         /sv_password/s/"\([^"]*\)"/"$SERVER_PASS"/;
         /sv_lan/s/"\([^"]*\)"/"$SERVER_LAN"/;
         /sv_region/s/"\([^"]*\)"/"$SERVER_REGION"/' serverfiles/csgo/cfg/csgo-server.cfg

# To edit the server.cfg or insert maps
# we will need to some work with files
# this is where it will go
# Start the server
#WORKDIR /home/csgoserver/serverfiles
#ENTRYPOINT ../csgoserver update && ./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +clientport $CLIENTPORT  +map $DEFAULTMAP -maxplayers $MAXPLAYERS

# Start the server
# https://labs.ctl.io/dockerfile-entrypoint-vs-cmd/
WORKDIR /home/csgoserver
ENTRYPOINT [ "exec ./csgoserver" ]
CMD [ "start" ]