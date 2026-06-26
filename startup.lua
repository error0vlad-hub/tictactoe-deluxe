-- Tic Tac Toe Deluxe - Startup
-- Place on a CC:Tweaked computer connected to a 4x8 Advanced Monitor wall and a speaker.

local programDir = fs.getDir(shell.getRunningProgram())
if programDir ~= "" then
    package.path = programDir .. "/?.lua;" .. package.path
end

local config = require("config")
local tictactoe = require("tictactoe")

local function findMonitor()
    local candidates = {}

    local function tryAdd(name, wrapped)
        if wrapped.isColor and wrapped.isColor() then
            local w, h = wrapped.getSize()
            candidates[#candidates + 1] = {
                name = name,
                monitor = wrapped,
                w = w,
                h = h,
            }
        end
    end

    if peripheral.getNames then
        for _, name in ipairs(peripheral.getNames()) do
            if peripheral.getType(name) == "monitor" then
                tryAdd(name, peripheral.wrap(name))
            end
        end
    else
        for _, side in ipairs({ "top", "bottom", "left", "right", "front", "back" }) do
            if peripheral.isPresent(side) and peripheral.getType(side) == "monitor" then
                tryAdd(side, peripheral.wrap(side))
            end
        end
    end

    if #candidates == 0 then
        return nil, nil, "No Advanced Monitor found. Connect a 4x8 color monitor wall."
    end

    -- Prefer exact 4x8 wall dimensions
    for _, c in ipairs(candidates) do
        if c.w == config.MONITOR_W and c.h == config.MONITOR_H then
            return c.monitor, c.name, nil
        end
    end

    -- Accept largest color monitor
    table.sort(candidates, function(a, b)
        return (a.w * a.h) > (b.w * b.h)
    end)

    local best = candidates[1]
    if best.w ~= config.MONITOR_W or best.h ~= config.MONITOR_H then
        print("Warning: Expected monitor size " .. config.MONITOR_W .. "x" .. config.MONITOR_H)
        print("Found " .. best.name .. " at " .. best.w .. "x" .. best.h)
        print("Adjust MONITOR_UNITS in config.lua if needed.")
        -- Adapt config to actual monitor size at runtime
        config.MONITOR_W = best.w
        config.MONITOR_H = best.h
        config.BOARD_X = math.floor((config.MONITOR_W - config.BOARD_W) / 2) + 1
        config.BOARD_Y = config.HEADER_H + math.floor(
            (config.MONITOR_H - config.HEADER_H - config.FOOTER_H - config.BOARD_H) / 2
        ) + 1
        config.buttons.menu.y = config.MONITOR_H - 12
        config.buttons.restart.y = config.MONITOR_H - 12
        config.buttons.restart.x = config.MONITOR_W - 33
        config.MENU_BTN_X = math.floor((config.MONITOR_W - config.MENU_BTN_W) / 2) + 1
    end

    return best.monitor, best.name, nil
end

local function findSpeaker()
    if peripheral.find then
        return peripheral.find("speaker")
    end

    for _, side in ipairs({ "left", "right", "top", "bottom", "front", "back" }) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "speaker" then
            return peripheral.wrap(side)
        end
    end

    return nil
end

local function main()
    term.clear()
    term.setCursorPos(1, 1)
    print("Tic Tac Toe Deluxe")
    print("Initializing...")

    local monitor, monitorName, err = findMonitor()
    if not monitor then
        print("ERROR: " .. err)
        print("Build a 4 wide x 8 tall Advanced Monitor wall (104x160).")
        return
    end

    monitor.setBackgroundColor(config.colors.bg)
    monitor.setTextColor(config.colors.white)

    local speaker = findSpeaker()
    if speaker then
        print("Speaker found.")
    else
        print("No speaker found - running silent.")
    end

    print("Monitor: " .. monitorName)
    local mw, mh = monitor.getSize()
    print("Size: " .. mw .. "x" .. mh)
    print("Starting game...")

    tictactoe.init(monitor, monitorName, speaker)
    tictactoe.run()
end

main()
