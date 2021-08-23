local constants = {
    machineAddPort = 0xADD, -- Mnemonic port number
    machineStatusPort = 0x575, -- Mnemonic port number
    tabletInputTimeout = 10, -- seconds
    tabletBootUpTime = 4, -- seconds
    networkResponseTime = 3, -- seconds
    addressesConfigFile = "configuration.addresses",
    scalesInSeconds = {
        0,
        1,
        5,
        15,
        30,
        60,
        300,
        900,
        1800,
        3600
    }
}

return constants
