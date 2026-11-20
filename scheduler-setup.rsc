# Scheduler setup for the HS075 reader (MikroTik KNOT, RouterOS 7)
#
# Requires hs075-reader.rsc to be installed as the script "hs075-reader" first.
# The reader writes its values to the system log, so no MQTT broker is needed here.

# Run the reader every 5 seconds
/system scheduler add name=hs075-reader-sched interval=5s on-event="/system script run hs075-reader"
