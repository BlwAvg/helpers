# NanoKVM HID Modifier

This tool allows you to modify the HID (Human Interface Device) information of your NanoKVM's composite device.

⚠️ **Warning:** Resetting the HID may trigger Endpoint Detection and Response (EDR) systems. However, altering this information can help bypass most EDR capabilities by making the device appear as a different or new HID.

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

