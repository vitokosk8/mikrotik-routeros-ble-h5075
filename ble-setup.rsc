# BLE configuration for HS075 / GVH5075 sensors on MikroTik KNOT (RouterOS 7)
#
# Replace the MAC addresses and the random-static address with your own values.
# Requires the iot package and a KNOT with built-in Bluetooth.

# Local BLE identity of the KNOT
/iot bluetooth set bt1 name=bt1 random-static-address=E3:55:D9:1E:57:10

# Advertisers are not needed for reading sensors; leave them disabled unless you use them
/iot bluetooth advertisers set bt1 disabled=yes

# Scanner: receive only advertisements from the whitelisted addresses
/iot bluetooth scanners set bt1 disabled=no filter-policy=whitelist interval=10ms window=10ms

# Whitelist: the HS075 sensors use public (IEEE-assigned) addresses
/iot bluetooth whitelist add address=A4:C1:38:8B:3D:15 address-type=public device=bt1 comment=hs075-1
/iot bluetooth whitelist add address=A4:C1:38:01:D9:6E address-type=public device=bt1 comment=hs075-2

# Check the received advertisements
/iot bluetooth scanners advertisements print where address=A4:C1:38:8B:3D:15
