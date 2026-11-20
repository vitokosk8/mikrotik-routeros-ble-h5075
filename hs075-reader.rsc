# HS075 BLE thermo-hygrometer reader for MikroTik KNOT (RouterOS 7)
#
# Decodes the advertisements of Govee-format thermo-hygrometers (sold as HS075,
# advertised as GVH5075_xxxx) received by the KNOT BLE scanner, and writes
# temperature, humidity and battery to the system log.
#
# Log line format (topic "hs075", one line per sensor):
#   hs075-1: temperature=27.9 C humidity=63.5 % battery=100 % last-seen=2026-11-20 17:02:51
#
# Setup: see ble-setup.rsc (whitelist and scanner)
# Run:   /system script run hs075-reader
# Scheduled every 5 seconds by the scheduler in mqtt-setup.rsc (or a dedicated scheduler entry)
#
# Manufacturer data (AD type 0xFF, company ID 0xEC88, 6 payload bytes):
#   byte 0    : 0x00 in every capture so far
#   bytes 1-3 : 24-bit value V
#               temperature (C) = (V / 1000) / 10
#               humidity (%)    = (V % 1000) / 10
#   byte 4    : battery level (%)
#   byte 5    : unused
#
# Known limitations:
#   - Negative temperatures are not decoded yet.
#   - Stale readings are not filtered; the last-seen field shows the advertisement time.

:local sensors {"A4:C1:38:8B:3D:15"="hs075-1"; "A4:C1:38:01:D9:6E"="hs075-2"}

# Converts a lowercase hex string into a decimal number.
:local hexToNum do={
    :local result 0
    :local digits "0123456789abcdef"
    :for i from=0 to=([:len $1] - 1) do={
        :local digit [:find $digits [:pick $1 $i ($i + 1)]]
        :set result (($result * 16) + $digit)
    }
    :return $result
}

:foreach mac,name in=$sensors do={
    # Advertisement entries for this sensor; the last entry is used as the newest one.
    :local ids [/iot bluetooth scanners advertisements find where address=$mac]

    :if ([:len $ids] > 0) do={
        :local last [:pick $ids ([:len $ids] - 1)]
        :local data [/iot bluetooth scanners advertisements get $last data]
        :local adTime [/iot bluetooth scanners advertisements get $last time]

        # Manufacturer AD structure: length 0x09, type 0xFF, company ID 0xEC88 (little endian 88 ec).
        :local pos [:find $data "09ff88ec"]

        :if ([:typeof $pos] = "num") do={
            :local start ($pos + 8)
            :local value [$hexToNum [:pick $data ($start + 2) ($start + 8)]]
            :local battery [$hexToNum [:pick $data ($start + 8) ($start + 10)]]

            # Integer arithmetic only: RouterOS parses decimal literals such as 0.1 as IP addresses.
            :local tempTenths ($value / 1000)
            :local humTenths ($value - ($tempTenths * 1000))

            :local tempStr (($tempTenths / 10) . "." . ($tempTenths - (($tempTenths / 10) * 10)))
            :local humStr (($humTenths / 10) . "." . ($humTenths - (($humTenths / 10) * 10)))

            :log info ($name . ": temperature=" . $tempStr . " C humidity=" . $humStr . " % battery=" . $battery . " % last-seen=" . $adTime)
        }
    }
}
