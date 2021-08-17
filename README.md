# **NIDAS** - Networked Information Display &amp; Automation Software
    This is a program to run on OpenComputers computers that run the OpenOS OS.

    This program has it's use on the GTNH modpack, but might be useful for other modpacks as well.

# **Features**
## **AR HUD (OpenGlasses)**
### **Power monitor**
* Displays current power status: How much power does the buffer support, how much power it has right now, the rate of change, 
and how long will it take until it's full or empty considering the current rate of change.
    
    (Only works for the LSC, but other kinds of buffers will be added later)

### **Toolbar decoration**
* Provides a nice overlay for your toolbar that indicates ingame time as well as real world time.

### **Notifications**
* Notifies the player of important events such as machines needing maintenance. 

    It's a work in progress right now and isn't on the official, "stable" release.

### **Machine overlay**
    Displays an overlay on the controller of a machine that needs maintenance for easier locating it

## **Machine monitoring**
    As of now, the server keeps machine names, locations, progress, efficiency, power usage, and number of problems.

    It recognizes newly added machines to the network, but doesn't read machines that are added while the computer is off.

    However, we don't display those yet. There will soon be a nice pretty screen that has all or most of that information on local servers.

    The main server will only show the maintenance statuses of machines.

## **Configuration screen**
There are many things that can be configured.

### **System configuration**
* Color scheme with support for custom colors. Each of the three colors on the interface are configurable to your liking.
* Screen resolution.
* Primary screen: Choose which one of the screens connected to the computer is the primary screen.
* Autorun: Choose whether the program should run as soon as the computer boots. There is a `run` button for running it manually.
* Multicasting: Choose whether you want to have all connected screens display the same image.
* Developer mode: Show debug information such as allocated memory.

### **Server configuration**
* Choose if the server is the central server in the system, the one that is connected to the power buffer and controls the glasses.
* Choose which of the connected machines is the power buffer. We will soon suggest a power buffer based on the `sensorInformation` the machines gives us.

### **HUD configuration**
* Name the owner of the glasses.
* Chose the resolution Minecraft is running at
* Chose GUI scale on the video options of the game: 1 for small, 2 for medium, ,3 for large and 4 for auto.
* Choose your timezone offset so the real world clock displays your time correctly. 
    (If the offset is negative, you must type the number first and then press minus, blame @S4mpsa for that)

### **Power configuration**
* Set the redstone component which controls the power
* Configure the thresholds at which the power generators whould be turned on or off

# **Requirements**
    To run this on your OC computer, you must have a tier 3 server to accomodate all the components we use.

## **Components**
* Internet card
    * Important for the installation and update of this program.
    * Is also used on the toolbar overlay to get the current real world time.
* Tier 2 wireless network card
    * Is used for communication between different servers on the system.
* Memory sticks
    * The more the merrier.
    * We haven't calculated how much we need, but if you can build an OC, you can probably craft planty of those.
    * Aim for the highest tier available.
* Component busses
    * The more the merrier
    * If you can build an OC, you can probably craft planty of those.
    * They're needed to connect machines components. The more machines you have on your network, the more of these you'll need.
    * Aim for the highest tier available.
* Disk
    * We only use one tier 3 disk and evverything works fine so far.
* Tier 3 graphics card
    * For displaying nice colors and getting touch events.

# **Installation**
    Glad you got this far.
    Let's install this thing.
* Download the `setup` file through the OC shell:
    ```shell
    wget https://raw.githubusercontent.com/S4mpsa/NIDAS/master/setup.lua -f
    ```
* Run `setup` on your machine:
    ```
    setup
    ```

* Enjoy

## **OCEmu**
    So you're a bit of a dev yourself and want to contribute with this project?
    Nice.

    Things are not working perfectly with OCEmu because it's hard to emulate the components. We're open to contributions of any kind, not just regarding OCEmu.


# **Configuration**
    To get things up and running, you'll need to set some things up.
* Server
    * Place the main server first.
        (It could be later, but then you gotta change the setting that says it's the main server on it and on the local server you placed first).
    * Chose the component that is the power buffer.
        (See new machines below).
    * Place the local server second.
* Drone
    * The drone is used to get the machine locations so that we can put an overlay on the machine controller in case there's a maintenance issue.
    * Place it by a charger so it doesn't run out of battery.
    * Place your drone with the following components in it:
        * Internet card for setting up and updating.
        * Tier 2 network card for communicating with the server.
        * Location upgrade to get the location of the waypoints.
        * Some RAM.
        * A disk.
        * A keyboard (Important, don't forget this).
        * A graphics card.
        * A CPU.
        * Some screen.
        * Card holder upgrade.
    * Install the program just like you did for the server.
    * Whenever you place your drone in a new location, it'll prompt you for that location. Use its terminal to give it that information.
* New machines
    * Place down a waypoint 4 blocks below the machine controller.
    * (Optional): Name the waypoint. This will be the name of the machine in the system.
    * (Optional): Give it a redstone signal.
    * Place the adapter on the machine controller (You can use an MFU for that, so you don't need the adpter to be adjacent to the controller).
    * Remove the waypoint after 10 seconds.
* Glasses
    * Place down a glasses terminal.
    * Bind you glasses to it.
    * Configure the glasses through the configuration screen on the main server.

It's recommended you go through all of the settings after you set things up to get the interfaces to your liking.
