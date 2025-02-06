# NanoKVM HID Modifier

The built-in HID reset option can trigger Endpoint Detection and Response (EDR) systems. It appears that resetting the HID does not modify the **"USB Composite Device"** information, making it detectable by security systems.

These steps allows you to modify the HID (Human Interface Device) information of your NanoKVM's composite device, helping to bypass EDR detection.

1. Figure out what HID information you want to use. DeviceHunt.com is great. The link pulls up the HID information for Logitech.
    - `https://devicehunt.com/view/type/usb/vendor/046D`

2. Stops the usb device
    - `echo "" | tee /sys/kernel/config/usb_gadget/g0/UDC`

3. Change the hid on the Nano KVM - MAKE UP YOUR OWN SERIAL NUMBER

    - `echo 0x046D > /sys/kernel/config/usb_gadget/g0/idVendor`

    - `echo 0xb305 > /sys/kernel/config/usb_gadget/g0/idProduct`

    - `echo "***MAKE UP SERIAL NUMBER***" > /sys/kernel/config/usb_gadget/g0/strings/0x409/serialnumber`

    - `echo "Logitech, Inc." > /sys/kernel/config/usb_gadget/g0/strings/0x409/manufacturer`

    - `echo "BT Mini-Receiver" > /sys/kernel/config/usb_gadget/g0/strings/0x409/product`

5. This starts the USB device again.
   - `echo "4340000.usb" | tee /sys/kernel/config/usb_gadget/g0/UDC`

## Default Settings
```
# cat /sys/kernel/config/usb_gadget/g0/idVendor 
0x3346
# cat /sys/kernel/config/usb_gadget/g0/idProduct 
0x1009

# cat /sys/kernel/config/usb_gadget/g0/strings/0x409/serialnumber 
0123456789ABCDEF
# cat /sys/kernel/config/usb_gadget/g0/strings/0x409/manufacturer 
sipeed
# cat /sys/kernel/config/usb_gadget/g0/strings/0x409/product 
NanoKVM
```

**Restore Default Settings**

`echo 0x3346 > /sys/kernel/config/usb_gadget/g0/idVendor`

`echo 0x1009 > /sys/kernel/config/usb_gadget/g0/idProduct`


`echo "0123456789ABCDEF" > /sys/kernel/config/usb_gadget/g0/strings/0x409/serialnumber`

`echo "sipeed" > /sys/kernel/config/usb_gadget/g0/strings/0x409/manufacturer`

`echo "NanoKVM" > /sys/kernel/config/usb_gadget/g0/strings/0x409/product`
