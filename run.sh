#!/usr/bin/bash
############################ ENSURE SUPERUSER PRIVS ############################
if [ "$EUID" -ne 0 ]; then echo -e "\e[1m\e[93m[!]\e[0m Please run as root"; exit; fi

############################# DEPENDENCY CREATION ##############################
cwd=$(pwd)
f_plog="$cwd/log.pcap"; touch $f_plog
d_http="$cwd/http_serve"; mkdir $d_http

                  #############################################
############################### ENVIRONMENT SETUP ##############################
                  #############################################

########################## BUILD TMUX MAIN WORKSPACE ###########################
gnome-terminal --title 'WORKSPACE' --maximize --geometry 1x1+0+0 -- tmux new -s 'main'

######################### BUILD TMUX MONITOR DASHBOARD #########################
gnome-terminal --title 'MONITOR' --maximize --geometry 1x1+3840+0 -- tmux new -s 'monitor'
tmux splitw -h -t 'monitor:0.0';tmux splitw -v -t 'monitor:0.0';tmux splitw -v -t 'monitor:0.2';
tmux splitw -v -t 'monitor:0.0';tmux splitw -v -t 'monitor:0.2';tmux splitw -h -t 'monitor:0.1';
tmux resize-pane -t 'monitor:0.6' -D 15;  tmux resize-pane -t 'monitor:0.6' -R 20
tmux resize-pane -t 'monitor:0.0' -U 5;   tmux resize-pane -t 'monitor:0.2' -U 10
tmux resize-pane -t 'monitor:0.3' -U 20

tmux send-keys -t "monitor:0.0" C-z "<start VPN tunnel>"
tmux send-keys -t "monitor:0.1" C-z "ping 8.8.8.8" Enter
tmux send-keys -t "monitor:0.2" C-z "<ping off lab host>"
tmux send-keys -t "monitor:0.3" C-z "sudo tcpdump -i tun0 -w - | tee $f_plog"
tmux send-keys -t "monitor:0.4" C-z "sudo tcpdump -i tun0"
tmux send-keys -t "monitor:0.5" C-z "top" Enter
tmux send-keys -t "monitor:0.6" C-z "cd $d_http" Enter "sudo python -m SimpleHTTPServer 80" Enter

############################## ITS TIME TO PARTY ###############################
tmux send-keys -t "main:0" C-z "./scripts/kill-chain.sh" Enter
