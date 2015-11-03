#FROM debian
FROM ubuntu
MAINTAINER Saruhan Karademir
 
ENV MAP_DEFAULT de_dust2
ENV PLAYERS_MAX 16
ENV PORT 27015
ENV CLIENT_PORT 27005
ENV SERVER_NAME servername
ENV RCON_PASS rconpass

# Expose Ports
EXPOSE $PORT
EXPOSE $PORT/udp
EXPOSE $CLIENTPORT/udp
EXPOSE $CLIENTPORT
EXPOSE 1200/udp

#### Variables ####
# Notification Email
# (on|off)
ENV email_notification off
ENV email email@example.com

# Steam login
ENV steam_user anonymous
ENV steam_pass

# Start Variables
# https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#Starting_the_Server
# [Game Modes]           gametype    gamemode
# Arms Race                  1            0
# Classic Casual             0            0
# Classic Competitive        0            1
# Demolition                 1            1
# Deathmatch                 1            2
gamemode="0"
gametype="0"
defaultmap="de_dust2"
mapgroup="random_classic"
maxplayers="16"
tickrate="64"
port="27015"
sourcetvport="27020"
clientport="27005"
ip="0.0.0.0"
updateonstart="off"

Workshop Parameters
# Optional: Workshop Parameters
# https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators
# To get an authkey visit - http://steamcommunity.com/dev/apikey
# authkey=""
# ws_collection_id=""
# ws_start_map=""

# https://developer.valvesoftware.com/wiki/Command_Line_Options#Source_Dedicated_Server
fn_parms(){
parms="-game csgo -usercon -strictportbind -ip ${ip} -port ${port} +clientport ${clientport} +tv_port ${sourcetvport} -tickrate ${tickrate} +map ${defaultmap} +servercfgfile ${servercfg} -maxplayers_override ${maxplayers} +mapgroup ${mapgroup} +game_mode ${gamemode} +game_type ${gametype} +host_workshop_collection ${ws_collection_id} +workshop_start_map ${ws_start_map} -authkey ${authkey}"
}
















 
#RUN dpkg --add-architecture i386
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -qqy wget tmux mailutils postfix lib32gcc1 && \
    apt-get install -qqy gdb ca-certificates bsdmainutils
 
# script refuses to run in root, create user
RUN useradd -m csserver
RUN adduser csserver sudo
USER csserver
WORKDIR /home/csserver
 
# download Counter-Strike: Global Offensive Dedicated Server Manager script
RUN wget http://gameservermanagers.com/dl/csgoserver
RUN chmod +x csgoserver
 
# Install the server (interactive script requires piping of input)
# Likes to fail so I run it twice
#RUN printf "y\ny\nn\ny\ny\ny\ny\nn\n${SERVERNAME}\n${RCONPASS}\n" | ./csgoserver install
RUN ./csgoserver -autoinstall
 
# To edit the server.cfg or insert maps
# we will need to some work with files
# this is where it will go

# Start the server
WORKDIR /home/csgoserver/serverfiles
ENTRYPOINT ../csgoserver update && ./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +clientport $CLIENTPORT  +map $DEFAULTMAP -maxplayers $MAXPLAYERS
