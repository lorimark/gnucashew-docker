
#
# this will run the gnucashew-demo
#
# If the demo dies internally, the docker will automatically restart
#  because of the 'unless-stopped' option.  But, the terminal will
#  drop out back to the host console.  So, the container is still
#  running (and restarting internally if it dieing).  So, to re-run
#  the image, the previous one must be stopped.
#
# This script first tries to stop the container in case it's still
#  running, then just runs the server like normal.
#

docker rm -f gnucashew-demo

docker run                             \
  --name gnucashew-demo                \
  --restart unless-stopped             \
  -it                                  \
  --net host                           \
  -v /data/Gnucash58Test.gnucash:/opt/gnucashew-dev/build/sqlite3data.gnucash \
  -e GNUCASHEW_PORT=8091               \
  -w /opt/gnucashew-dev/build          \
  gnucashew-docker bash ../run.sh

# the container should restart unless we stop it with a 'docker stop'

