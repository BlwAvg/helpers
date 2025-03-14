# JetKVM HID Modifier

The built-in HID reset option can trigger Endpoint Detection and Response (EDR) systems. It appears that resetting the HID does not modify the **"USB Composite Device"** information, making it detectable by security systems.

These steps allows you to modify the HID (Human Interface Device) information of your NanoKVM's composite device, helping to bypass EDR detection.

************************************************************************************************************
⚠️ **Warning & Disclaimer** 
This software is provided **"as is"**, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the authors or contributors be held liable for any claim, damages, or other liabilities arising from the use of this software.

This project is intended for **educational purposes only**. The authors do not condone or support any misuse of this software.

This project is **not affiliated, associated, authorized, endorsed by, or in any way officially connected with Sipeed** or any of its subsidiaries or affiliates. All product and company names are trademarks of their respective holders.
************************************************************************************************************

### 1. Determine Alternative HID IDs you want to use
Use [DeviceHunt.com](https://devicehunt.com/view/type/usb/vendor/046D). This link defaults to Logitech, but uses whatever you want.

### 2. Change the hid on the Nano KVM
NOTE ⚠ Make up your own serial number before running these commands.
```sh
echo 0x046D > /sys/kernel/config/usb_gadget/jetkvm/idVendor
echo 0xb305 > /sys/kernel/config/usb_gadget/jetkvm/idProduct
echo "***MAKE UP SERIAL HERE***" > /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/serialnumber
echo "Logitech, Inc." > /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/manufacturer
echo "BT Mini-Receiver" > /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/product
```
### 3. Restart the JetKVM
```sh
reboot
```

## Default Settings
```
# cat /sys/kernel/config/usb_gadget/jetkvm/idVendor
0x1d6b
# cat /sys/kernel/config/usb_gadget/jetkvm/idProduct
0x0044

# cat /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/serialnumber
55cce811c26a8628
# cat /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/manufacturer
JetKVM
# cat /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/product
JetKVM USB Emulation Device
```

**Restore Default Settings**
```sh
echo 0x1d6b > /sys/kernel/config/usb_gadget/jetkvm/idVendor
echo 0x0044 > /sys/kernel/config/usb_gadget/jetkvm/idProduct
echo "55cce811c26a8628" > /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/serialnumber
echo "JetKVM" > /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/manufacturer
echo "JetKVM USB Emulation Device" > /sys/kernel/config/usb_gadget/jetkvm/strings/0x409/product
```
