# **NIDAS** - Networked Information Display &amp; Automation Software
    NIDAS runs as a program over the OpenOS shell.

    The program is mostly developed for use with the GregTech: New Horizons modpack.

Check out [our wiki](https://github.com/S4mpsa/NIDAS/wiki) for more information!

# **Installation**
* Download and run the `setup` file from the OC shell:
    ```shell
    wget -f https://raw.githubusercontent.com/S4mpsa/NIDAS/master/setup.lua && setup
    ```

# **Main Features**
## **AR HUD (OpenGlasses)**
### **Power monitor**
* Displays current power status: 
  * Total capacity
  * Current capacity
  * Input / Output rate
  * Time to full or empty based on the rate.

### **Toolbar decoration**
* Provides an overlay for the toolbar, displaying both the in game time and real world time.

### **Notifications**
* Displays a HUD notification of important events, such as machines needing maintenance.

### **Gregtech machine maintenance overlay**
* Notifies of maintenance need on the HUD and displays an in-world location helper.

## **Machine monitoring**
Tracks machine information:
  * Names 
  * Recipe progress 
  * Efficiency
  * Power usage
  * Number of issues.

  * Locations
    
        Each machine has to be individually configured for location support.

    `Local servers` can display the data on a connected screen, while the `main server` provides HUD notifications of maintenace from all `local servers`.

## **Automated Infusions**
  * Checks for a pattern that maches the items in an ME subnetwork
  * Checks for the required essentia for the infusion
  * Infuses

# **Configuration options**
## **System**
* Color scheme with support for custom colors. Each of the three colors are configurable.
* Screen resolution.
* Primary screen: Choose which one of the screens connected to the computer is the primary screen.
* Autorun: Choose whether the program should run as soon as the computer boots. There is a `run` button for running it manually.
* Multicasting: Choose whether you want to have all connected screens display the same image.
* Developer mode: Show debug information such as allocated memory.

## **Server**
* Choose if the server is the central server in the system, the one that is connected to the power buffer and controls the glasses.
* Choose which of the connected machines is the power buffer. We will soon suggest a power buffer based on the `sensorInformation` the machines gives us.

## **HUD**
* Name the owner of the glasses.
* Change the rendering resolution.
* Chose GUI scale on the video options of the game: 1 for Small, 2 for Medium, ,3 for Large and 4 for Auto.
* Choose your timezone offset so the real world clock displays your time correctly.

    (If the offset is negative, you must type the number first and then press -, blame @S4mpsa for that)

## **Power**
* Set the redstone component which controls the power.
* Configure the thresholds at which the power generators whould be turned on or off.
