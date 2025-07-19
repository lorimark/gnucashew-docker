
echo "running"
cd /opt/gnucashew-dev/build
./gnucashew-bin /data/LorimarkSolutions-5.11.gnucash \
  --pid-file=gnucashew-bin-dev.pid \
  --config=../src/wt_config.xml \
  --approot="../approot" \
  --docroot="../docroot;.,/images,/resources,/styles,/themes,/dox" \
  --errroot="../errroot" \
  --http-listen 0.0.0.0:8089 \



