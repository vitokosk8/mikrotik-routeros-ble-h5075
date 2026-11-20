# Scheduler setup for the H5075 reader (MikroTik KNOT, RouterOS 7)
#
# Requires h5075-reader.rsc to be installed as the script "h5075-reader" first.
# The reader writes its values to the system log, so no MQTT broker is needed here.

# Run the reader every 5 seconds
/system scheduler add name=h5075-reader-sched interval=5s on-event="/system script run h5075-reader"
