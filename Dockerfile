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

# Install Packages
#RUN dpkg --add-architecture i386
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -qqy wget nano tmux lib32gcc1 \
                         gdb ca-certificates bsdmainutils
# Install Postfix Package OR https://hub.docker.com/r/catatnight/postfix/
# RUN debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com" && \
#     debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'" && \
#     apt-get install -y postfix mailutils

# FIX ( perl: warning: Please check that your locale settings: )
# http://ubuntuforums.org/showthread.php?t=1346581
RUN locale-gen en_US en_US.UTF-8 hu_HU hu_HU.UTF-8
RUN dpkg-reconfigure locales

# script refuses to run in root, create user
RUN useradd -m csgoserver
RUN adduser csgoserver sudo
USER csgoserver
WORKDIR /home/csgoserver

# Download Counter-Strike: Global Offensive Dedicated Server Manager script
# https://raw.githubusercontent.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
RUN wget http://gameservermanagers.com/dl/csgoserver
RUN chmod +x csgoserver

# Edit Server Script to hold Docker Environmental Varables
RUN sed -i '/emailnotification=/s/"\([^"]*\)"/"$EMAIL_NOTIFICATION"/' csgoserver
RUN sed -i '/email=/s/"\([^"]*\)"/"$EMAIL"/' csgoserver
RUN sed -i '/steamuser=/s/"\([^"]*\)"/"$STEAM_USER"/' csgoserver
RUN sed -i '/steampass=/s/"\([^"]*\)"/"$STEAM_PASS"/' csgoserver
RUN sed -i '/gamemode=/s/"\([^"]*\)"/"$GAME_MODE"/' csgoserver
RUN sed -i '/gametype=/s/"\([^"]*\)"/"$GAME_TYPE"/' csgoserver
RUN sed -i '/defaultmap=/s/"\([^"]*\)"/"$DEFAULT_MAP"/' csgoserver
RUN sed -i '/mapgroup=/s/"\([^"]*\)"/"$MAP_GROUP"/' csgoserver
RUN sed -i '/maxplayers=/s/"\([^"]*\)"/"$MAX_PLAYERS"/' csgoserver
RUN sed -i '/tickrate=/s/"\([^"]*\)"/"$TICK_RATE"/' csgoserver
RUN sed -i '/port=/s/"\([^"]*\)"/"$GAME_PORT"/' csgoserver
RUN sed -i '/sourcetvport=/s/"\([^"]*\)"/"$SOURCE_TV_PORT"/' csgoserver
RUN sed -i '/clientport=/s/"\([^"]*\)"/"$CLIENT_PORT"/' csgoserver
RUN sed -i '/ip=/s/"\([^"]*\)"/"$GAME_IP"/' csgoserver
RUN sed -i '/updateonstart=/s/"\([^"]*\)"/"$UPDATE_ON_START"/' csgoserver
RUN sed -i '/authkey=/s/"\([^"]*\)"/"$AUTH_KEY"/' csgoserver
RUN sed -i '/ws_collection_id=/s/"\([^"]*\)"/"$WS_COLLECTION_ID"/' csgoserver
RUN sed -i '/ws_start_map=/s/"\([^"]*\)"/"$WS_START_MAP"/' csgoserver
# RUN cat csgoserver  # DEBUG

# Run Install Script
RUN ./csgoserver auto-install

# Edit Server Config to hold Docker Environmental Varables
RUN wget https://raw.githubusercontent.com/dgibbs64/linuxgsm/master/CounterStrikeGlobalOffensive/cfg/lgsm-default.cfg --output-document=csgo-server.cfg && mkdir serverfiles/csgo/cfg/ -p && mv csgo-server.cfg serverfiles/csgo/cfg/
RUN sed -i '/hostname/s/"\([^"]*\)"/"$SERVER_NAME"/' serverfiles/csgo/cfg/csgo-server.cfg
RUN sed -i '/rcon_password/s/"\([^"]*\)"/"$RCON_PASS"/' serverfiles/csgo/cfg/csgo-server.cfg
RUN sed -i '/sv_password/s/"\([^"]*\)"/"$SERVER_PASS"/' serverfiles/csgo/cfg/csgo-server.cfg
RUN sed -i '/sv_lan/s/"\([^"]*\)"/"$SERVER_LAN"/' serverfiles/csgo/cfg/csgo-server.cfg
RUN sed -i '/sv_region/s/"\([^"]*\)"/"$SERVER_REGION"/' serverfiles/csgo/cfg/csgo-server.cfg
# RUN cat serverfiles/csgo/cfg/csgo-server.cfg  # DEBUG

# To edit the server.cfg or insert maps
# we will need to some work with files
# this is where it will go
# Start the server
#WORKDIR /home/csgoserver/serverfiles
#ENTRYPOINT ../csgoserver update && ./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +clientport $CLIENTPORT  +map $DEFAULTMAP -maxplayers $MAXPLAYERS

# Start the server
# https://labs.ctl.io/dockerfile-entrypoint-vs-cmd/
# http://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile
# http://kimh.github.io/blog/en/docker/gotchas-in-writing-dockerfile-en/
# http://www.markbetz.net/2014/03/17/docker-run-startup-scripts-then-exit-to-a-shell/
# ENTRYPOINT [ "exec ./csgoserver" ]
# ENTRYPOINT [ "exec ./csgoserver" ]

# ENTRYPOINT [ "csgoserver" ]
# CMD start

# ENV DOCKER_ENTRYPOINT_COMMAND ./csgoserver
ENV DOCKER_CMD_COMMAND ./csgoserver
# ENTRYPOINT $ENTRYPOINT
# CMD [ "./csgoserver", "start" ]

# CMD bash -C './csgoserver start';'bash'
# CMD bash -C './csgoserver';'bash'
# CMD bash -C './csgoserver; ./csgoserver start';'bash'
# CMD bash -C "$DOCKER_CMD_COMMAND";'bash'
# CMD bash -C "$DOCKER_CMD_COMMAND";'bash'
CMD exec ./csgoserver details && $DOCKER_CMD_COMMAND && bash