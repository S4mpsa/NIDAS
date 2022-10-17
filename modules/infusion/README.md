# FEATURES

* Allows up to ONE altar per OC currently
* Waits for the essentia to be available before starting the craft
* Nice graphical interface shows you the progress of the ongoing infusion even if you are not well versed in the magical arts

<img src="screen.png" alt="screen" width="720"/>

___
___

# SETUP GUIDE

Hi, I see you're interested in auto infusing some stuff.
Let's get right to it.

## AE2 Stuff
First of all, you're gonna make an ME subnetwork. I'm not going to explain this here as there's plenty of material on it online.

Place an ME Interface with the recipes you want to autocraft pointing to a chest. 
On the chest, place a storage bus configured to "Extract Only".
On the interface, place two more storage busses. One for items, set to "Insert Only" and one for essentia.

<img src="subnet.png" alt="subnet setup" width="720"/>

___

## The altar itself

To get this up and runnning you'll need to set up a TC4 altar with a few attachments. 

You'll need some OC parts:
* A Redstone I/O block
* A Transposer
* An Adapter

Some sort of infusion starter (Gadomancy's Infusion Claw works great, but you could use a robot or whatever)

And some AE2 parts as well: 
* An ME Toggle Bus
* An ME Interface, of course
* Some sort of Infusion Provider (recommended)
  * GTNH has the amazing Infusion Intercepter, which allows for instant essentia transfer between your drives and your matrix.
* A Crafting Storage Unit

Place the Thaumcraft 4 altar as usual.

Put the Transposer adjacent to the altar's center pedestal and the ME Interface with the desired crafts for the altar just underneath the Transposer.

On the side of the matrix, put the adapter.
You can use an MFU to connect the adapter wirelessly to the ME Interface or you can use another adapter.

Place the Claw above the runic matrix, so that it will start the infusion on activation. On the side of the claw, place the Redstone I/O block and above that I/O block, place the ME Toggle Bus in a way it can toggle the essentia can flow to the matrix.

<img src="altar.png" alt="altar setup" width="720"/>
