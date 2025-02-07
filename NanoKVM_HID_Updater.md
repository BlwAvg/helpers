# NanoKVM HID Modifier

The built-in HID reset option can trigger Endpoint Detection and Response (EDR) systems. It appears that resetting the HID does not modify the **"USB Composite Device"** information, making it detectable by security systems.

These steps allows you to modify the HID (Human Interface Device) information of your NanoKVM's composite device, helping to bypass EDR detection.

************************************************************************************************************
⚠️ **Warning & Disclaimer** 
This software is provided **"as is"**, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the authors or contributors be held liable for any claim, damages, or other liabilities arising from the use of this software.

This project is intended for **educational purposes only**. The authors do not condone or support any misuse of this software.

This project is **not affiliated, associated, authorized, endorsed by, or in any way officially connected with Sipeed** or any of its subsidiaries or affiliates. All product and company names are trademarks of their respective holders.
************************************************************************************************************

**NOTE:** These changes are lost on boot. Check the boot section for updating /etc/init.d/S03usbdev

1. Figure out what HID information you want to use. DeviceHunt.com is great. The link pulls up the HID information for Logitech.
    - `https://devicehunt.com/view/type/usb/vendor/046D`

2. Stop the usb device
    - `echo "" | tee /sys/kernel/config/usb_gadget/g0/UDC`

3. Change the hid on the Nano KVM - MAKE UP YOUR OWN SERIAL NUMBER

    - `echo 0x046D > /sys/kernel/config/usb_gadget/g0/idVendor`

    - `echo 0xb305 > /sys/kernel/config/usb_gadget/g0/idProduct`

    - `echo "***MAKE UP SERIAL NUMBER***" > /sys/kernel/config/usb_gadget/g0/strings/0x409/serialnumber`

    - `echo "Logitech, Inc." > /sys/kernel/config/usb_gadget/g0/strings/0x409/manufacturer`

    - `echo "BT Mini-Receiver" > /sys/kernel/config/usb_gadget/g0/strings/0x409/product`

5. This starts the USB device again.
   - `echo "4340000.usb" | tee /sys/kernel/config/usb_gadget/g0/UDC`

6. (Optional) While on the CLI I like to make some personal changes
   - Update the device to use local/preffered DNS `echo "nameserver LOCAL_DNS_IP" > /etc/resolv.conf` 
   - Change the root password `passwd`

## Boot update - /etc/init.d
The files which updates the USB Composite HID is /etc/init.d/S03usbdev. Use Vi to update the section show below with whatever values you would have above. Note there is a duplicate of this section above that is commented out `#` This section can be safetly ignored.
```
    echo 0x3346 > idVendor
    echo 0x1009 > idProduct
    mkdir strings/0x409
    echo '0123456789ABCDEF' > strings/0x409/serialnumber
    echo 'sipeed' > strings/0x409/manufacturer
    echo 'NanoKVM' > strings/0x409/product
```

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
