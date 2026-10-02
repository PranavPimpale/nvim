return {
    "vyfor/cord.nvim",

    opts = {
        display = {
            theme = "minecraft",
            flavor = "dark",

            -- Show both the Minecraft datapack icon
            -- and the Neovim/editor icon
            view = "full",

            swap_fields = false,
            swap_icons = false,
        },

        timestamp = {
            enabled = true,
        },

        idle = {
            enabled = true,
            timeout = 300000,
            show_status = true,
        },

        advanced = {
            discord = {
                reconnect = {
                    enabled = true,
                },
            },
        },
    },
}
