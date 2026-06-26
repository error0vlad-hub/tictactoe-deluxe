-- Configuration for Tic Tac Toe Deluxe (4x8 Advanced Monitor wall)

local config = {}

-- Monitor wall layout: 4 monitors wide x 8 monitors tall
config.MONITOR_UNITS_W = 4
config.MONITOR_UNITS_H = 8
config.UNIT_W = 26
config.UNIT_H = 20
config.MONITOR_W = config.MONITOR_UNITS_W * config.UNIT_W   -- 104
config.MONITOR_H = config.MONITOR_UNITS_H * config.UNIT_H   -- 160

-- File paths
config.STATS_FILE = "tictactoe_stats.dat"

-- Players
config.PLAYER_X = "X"
config.PLAYER_O = "O"
config.EMPTY = " "

-- Game modes
config.MODE_PVAI = "pvai"
config.MODE_PVP = "pvp"

-- UI layout
config.HEADER_H = 10
config.FOOTER_H = 16
config.BOARD_MARGIN_X = 4

config.CELL_W = 32
config.CELL_H = 44
config.BOARD_W = config.CELL_W * 3
config.BOARD_H = config.CELL_H * 3
config.BOARD_X = math.floor((config.MONITOR_W - config.BOARD_W) / 2) + 1
config.BOARD_Y = config.HEADER_H + math.floor(
    (config.MONITOR_H - config.HEADER_H - config.FOOTER_H - config.BOARD_H) / 2
) + 1

-- Colors
config.colors = {
    bg           = colors.black,
    title        = colors.yellow,
    subtitle     = colors.lightBlue,
    playerX      = colors.red,
    playerO      = colors.cyan,
    grid         = colors.gray,
    gridBright   = colors.lightGray,
    button       = colors.blue,
    buttonText   = colors.white,
    buttonHover  = colors.lightBlue,
    buttonBorder = colors.white,
    winLine      = colors.lime,
    menuBg       = colors.purple,
    menuAccent   = colors.pink,
    stats        = colors.orange,
    dim          = colors.gray,
    highlight    = colors.yellow,
    panel        = colors.gray,
    panelText    = colors.white,
    draw         = colors.magenta,
}

-- Button definitions (x, y, w, h, label, id)
config.buttons = {
    menu = {
        x = 6,
        y = config.MONITOR_H - 12,
        w = 28,
        h = 5,
        label = " MENU ",
        id = "menu",
    },
    restart = {
        x = config.MONITOR_W - 33,
        y = config.MONITOR_H - 12,
        w = 28,
        h = 5,
        label = " RESTART ",
        id = "restart",
    },
}

-- Main menu button layout
config.menuButtons = {
    { id = "pvai",  label = " Player vs AI ", yOffset = 0 },
    { id = "pvp",   label = " Two Players ",  yOffset = 1 },
    { id = "stats", label = " Statistics ",   yOffset = 2 },
    { id = "quit",  label = " Quit ",         yOffset = 3 },
}

config.MENU_BTN_W = 40
config.MENU_BTN_H = 5
config.MENU_BTN_X = math.floor((config.MONITOR_W - config.MENU_BTN_W) / 2) + 1
config.MENU_BTN_START_Y = 58
config.MENU_BTN_SPACING = 8

-- Animation
config.WIN_LINE_FRAMES = 24
config.WIN_LINE_DELAY = 0.08
config.MOVE_ANIM_DELAY = 0.05
config.AI_THINK_DELAY = 0.35

-- Sound notes (instrument, volume, pitch)
config.sounds = {
    click     = { instrument = "bit",      volume = 1.0, pitch = 1.5 },
    placeX    = { instrument = "pling",    volume = 1.0, pitch = 1.2 },
    placeO    = { instrument = "pling",    volume = 1.0, pitch = 0.8 },
    win       = { instrument = "bell",     volume = 1.0, pitch = 1.0 },
    lose      = { instrument = "bass",     volume = 1.0, pitch = 0.5 },
    draw      = { instrument = "flute",    volume = 1.0, pitch = 1.0 },
    menuOpen  = { instrument = "chime",    volume = 1.0, pitch = 1.3 },
    error     = { instrument = "cowbell",  volume = 0.8, pitch = 0.3 },
}

return config
