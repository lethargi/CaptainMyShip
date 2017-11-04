local Config = {}

Config.Author = "tangowrangler"
Config.ModName = "CaptainMyShip"
Config.version = {
    major=0, minor=0, patch = 0,
    string = function()
        return  Config.version.major .. '.' ..
                Config.version.minor .. '.' ..
                Config.version.patch
    end
}

Config.Settings = {}

return Config
