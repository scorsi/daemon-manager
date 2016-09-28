#!/bin/sh
### BEGIN INIT INFO
# Provides:          my_daemon
# Required-Start:    networking
# Required-Stop:     networking
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: my_daemon
# Description:       This file should be used to start and stop my_daemon.
### END INIT INFO

# Using LSB functions
. /lib/lsb/init-functions

# Process name
NAME=my_daemon
# Path
PATH=/sbin:/usr/sbin:/bin:/usr/bin
# Deamon File
DAEMON=/usr/bon/my_daemon.sh
# Log file
LOGFILE=/var/log/my_daemon.log
# Pid file
PIDFILE=/var/run/my_daemon.pid
# User who executs daemon
USER=root


### Functions
# Usage
d_usage () {
  echo "Usage: $0 {start|stop|restart|reload|status}"
}
# Stop daemon
d_stop () {
  if [ -e $PIDFILE ]
  then
    status_of_proc -p $PIDFILE $NAME "Stoppping the $NAME process" && status="0" || status="$?"
    if [ "$status" = 0 ]
    then
      start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE
      /bin/rm -rf $PIDFILE
    fi
  else
    log_daemon_msg "$NAME process is not running"
    log_end_msg 0
  fi
}
# Start daemon
d_start () {
  if [ -e $PIDFILE ]
  then
    echo "$NAME is already executed"
  else
    /bin/touch $PIDFILE
    log_daemon_msg "Starting the process" "$NAME"
    start-stop-daemon --background --name $NAME --start --quiet --oknodo --pidfile $PIDFILE --make-pidfile --exec $DAEMON --chuid $USER
    log_end_msg $?
  fi
}
###

# Test if the Daemon exists
test -x $DAEMON || exit 5

if [ $# = 0 ]
then
  d_usage
  exit 2
fi

case $1 in
  start|stop)
    # Start or Stop the daemon.
    d_${1}
    ;;
  restart)
    # Stop the daemon
    d_stop
    # Wait
    sleep 2
    # Start the daemon
    d_start
    ;;
  status)
    # Check the status of the process.
    if [ -e $PIDFILE ]
    then
      status_of_proc -p $PIDFILE $DAEMON "$NAME process" && exit 0 || exit $?
    else
      log_daemon_msg "$NAME Process is not running"
      log_end_msg 0
    fi
    ;;
  reload)
    # Reload the process. Basically sending some signal to a daemon to reload
    # it configurations.
    if [ -e $PIDFILE ]
    then
      start-stop-daemon --stop --signal USR1 --quiet --pidfile $PIDFILE --name $NAME
      log_success_msg "$NAME process reloaded successfully"
    else
      log_failure_msg "$PIDFILE does not exists"
    fi
    ;;
  *)
    # For invalid arguments, print the usage message.
    d_usage
    exit 2
    ;;
esac
