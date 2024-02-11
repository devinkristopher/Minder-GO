# Minder-GO
A barcode scanner app for iOS. Minder GO is used to streamline asset scanning in the data center field environment.

Note that this app is barely out of prototype mode and is currently in development.

# Overview
Minder GO is a companion app to the Minder v2 RESTful API.  At the time, this is a proprietary project; only employees of Core Scientific may take advantage of this app without modification.  Unauthorized use or access of the Minder API is prohibited.

Minder GO is a simple camera app that recognizes barcodes, stores them in a set, applies basic string operations to the results, then allows the export of said results.

The app opens to the camera view:

![Landing Page](https://i.imgur.com/5gAuT3b.png)

Once a barcode is recognized, a haptic vibration will occur letting the user know that the barcode has been recognized; additionally, the spatial location of the barcode is shown on the screen.  The barcode is shown in the sheet area at the bottom of the screen.

![Recognized Barcode](https://i.imgur.com/eQyfxW3.png)

The user can select various formatting options, such as prepending the Minder URL to the beginning of the asset tag.  This option can be turned off if desired.

![Format Page](https://i.imgur.com/90dUnEo.png)

A preview is shown, displaying the resulting list.

![Export Page](https://i.imgur.com/vjIPJO6.png)

# Development Considerations

The primary data structure used to store scanned barcode scans is a proper set data structure.  This means that repeated values will not be added as new entries; all objects in a set are unique.  This fixes a critical issue with the traditional barcode scanners.  If an asset is scanned multiple times, the user does not have to go back to their computer to check for/remove the repeated item from a spreadsheet.  If an asset is scanned, it is added.  If there is a doubt, scanning twice will never hurt (given that a scan doesn't result in an erroneous scan, which I have not found to happen yet).  
