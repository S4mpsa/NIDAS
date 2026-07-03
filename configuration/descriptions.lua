local descriptions = {
    hud = "Overlays a HUD on your screen. Each AR Glass can be configured independantly. X and Y resolutions are the rendering resolution of the game window. Scale is GUI Scale: 1 = Small, 2 = Normal, 3 = Large, 4-10 = Auto",
    server = "Updates all data and handles communication between other servers. Required for most modules to work.",
    powerControl = "Emits redstone when power levels are below a certain amount. Values are set as as a percentage of the battery, 0 - 100 %. You can change the redstone mode, Normal: redstone 15 when reaches energy level. Inverted: Redstone 0 when reaches energy level.",
    machineDisplay = "Displays GregTech machine information on the screen.",
    infusion = "Automatically infuses items when it can. Should have it's own computer and run attached to an ME subsystem. Doesn't require the server module to be running. For more information on how to set the altar up, see the README file on github.",
    autostocker = "Automatically stocks items to configured levels.",
    fluidDisplay = "Configures fluid levels shown on the HUD. Must be configured by every user.",
    OreProcessing = "Automatically sorts incoming ores into their respective configurable ore processing lines."
}

return descriptions
