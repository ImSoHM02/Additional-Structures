description =
[[
-V1.0.1-
Fixed items not showing up when built.
Cleaned and optimized code.
]]

name 						= "Additional Structures"
author 						= "I'm So HM02 (Original by Silentine)"
version 					= "1.0.1"
forumthread 				= ""
icon                        = "modicon.tex"
icon_atlas                  = "modicon.xml"
api_version                 = 10
all_clients_require_mod     = true
dst_compatible              = true
client_only_mod             = false

--Configs
local Options               = {{description = "Enabled", data = true}, {description = "Disabled", data = false}}

local ICFreshness           = {{description = "Default", data = 0.25, hover = "Default"}, {description = "Half", data = 0.125, hover = "Spoils at half the rate"}, {description = "Never spoil", data = 0, hover = "Food never spoils"}, {description = "Regain freshness", data = -2, hover = "Food regains freshness slowly"}}

local CBSpoilage            = {{description = "Default (300% faster)", data = 3, hover = "Food spoils 300% faster"}, {description = "400%", data = 4, hover = "Food spoils 400% faster"}, {description = "500%", data = 5, hover = "Food spoils 500% faster"}}

local CBSanity              = {{description = "Off", data = 0, hover = "No sanity aura"}, {description = "Small", data = 1, hover = "Small sanity aura"}, {description = "Medium", data = 2, hover = "Medium sanity aura"}, {description = "Large", data = 3, hover = "Large sanity aura"}}

local Empty                 = {{description = "", data = 0}}

local function Title(title) --Allows use of an empty label as a header
return {name=title, options=Empty, default=0,}
end

local SEPARATOR             = Title("")
 
configuration_options       =
{
    Title("Ice Chest"),
	{
        name = "icechest_config",
        label = "Freshness",
        options = ICFreshness,
        default = 0.25,
    },

    Title("Compost Box"),
    {
        name = "compostbox_config",
        label = "Spoilage Rate",
        options = CBSpoilage,
        default = 3,
    },

    {
        name = "cbsanityaura",
        label = "Sanity Aura",
        options = CBSanity,
        default = 1,
    },
}