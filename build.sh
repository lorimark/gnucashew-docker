#
# this builds the gnucashew-docker image
#  note, that inside Dockerfile there is
#  a 'nocache' value in there that you
#  can increment if you simply want the
#  docker to rebuild as some intermediate
#  step.
#
# When you want to rebuild the whole image
#  from the start, there is a '--no-cache'
#  option that you can add to the build-line.
#
#
docker build -t gnucashew-docker .

# --no-cache
