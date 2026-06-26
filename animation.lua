-- Winning line and placement animations

local config = require("config")

local animation = {}

local function cellCenter(cellIndex)
    local row = math.floor((cellIndex - 1) / 3)
    local col = (cellIndex - 1) % 3
    local x = config.BOARD_X + col * config.CELL_W + math.floor(config.CELL_W / 2)
    local y = config.BOARD_Y + row * config.CELL_H + math.floor(config.CELL_H / 2)
    return x, y
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

--- Draw an animated winning line through three cell indices.
--- redrawBase() is called each frame before the line is drawn (pass ui.drawBoard + header/footer).
function animation.playWinLine(monitor, winLine, redrawBase)
    if not winLine or #winLine < 3 then
        return
    end

    local x1, y1 = cellCenter(winLine[1])
    local x3, y3 = cellCenter(winLine[3])

    for frame = 1, config.WIN_LINE_FRAMES do
        local t = frame / config.WIN_LINE_FRAMES
        local pulse = (frame % 4 < 2)

        if redrawBase then
            redrawBase()
        end

        local segments = math.max(1, math.floor(t * 24))
        for s = 0, segments do
            local st = s / 24
            local px = math.floor(lerp(x1, x3, st) + 0.5)
            local py = math.floor(lerp(y1, y3, st) + 0.5)
            local color = pulse and config.colors.winLine or colors.yellow
            monitor.setBackgroundColor(color)
            monitor.setTextColor(colors.white)
            for dx = -1, 1 do
                for dy = -1, 1 do
                    if math.abs(dx) + math.abs(dy) <= 1 then
                        monitor.setCursorPos(px + dx, py + dy)
                        monitor.write(" ")
                    end
                end
            end
        end

        for _, idx in ipairs(winLine) do
            local cx, cy = cellCenter(idx)
            monitor.setBackgroundColor(config.colors.winLine)
            monitor.setTextColor(colors.white)
            for dx = -2, 2 do
                monitor.setCursorPos(cx + dx, cy)
                monitor.write("     ")
            end
        end

        sleep(config.WIN_LINE_DELAY)
    end
end

--- Brief pulse animation when placing a marker.
function animation.pulseMarker(monitor, drawMarkerFn, cellIndex, marker)
    drawMarkerFn(cellIndex, marker, true)
    sleep(config.MOVE_ANIM_DELAY)
    drawMarkerFn(cellIndex, marker, false)
end

--- Flash the entire board border on game over.
function animation.flashBorder(monitor, times, color)
    times = times or 3
    color = color or config.colors.highlight
    local bx, by = config.BOARD_X, config.BOARD_Y
    local bw, bh = config.BOARD_W, config.BOARD_H

    for _ = 1, times do
        monitor.setBackgroundColor(color)
        monitor.setTextColor(colors.white)
        for x = bx, bx + bw - 1 do
            monitor.setCursorPos(x, by)
            monitor.write(" ")
            monitor.setCursorPos(x, by + bh - 1)
            monitor.write(" ")
        end
        for y = by, by + bh - 1 do
            monitor.setCursorPos(bx, y)
            monitor.write(" ")
            monitor.setCursorPos(bx + bw - 1, y)
            monitor.write(" ")
        end
        sleep(0.15)
        monitor.setBackgroundColor(config.colors.bg)
        sleep(0.15)
    end
end

--- Animated menu title shimmer.
function animation.shimmerTitle(monitor, text, x, y, width)
    local colors_list = { colors.yellow, colors.orange, colors.red, colors.pink, colors.magenta, colors.purple }
    local offset = (os.clock() * 4) % #colors_list
    monitor.setBackgroundColor(config.colors.bg)
    monitor.setCursorPos(x, y)
    for i = 1, #text do
        local ci = (math.floor(offset + i) % #colors_list) + 1
        monitor.setTextColor(colors_list[ci])
        monitor.write(text:sub(i, i))
    end
    -- Pad rest of line
    monitor.setTextColor(config.colors.title)
    for i = #text + 1, width do
        monitor.write(" ")
    end
end

return animation
