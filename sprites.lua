-- Large pixel-art X and O sprites for board cells

local config = require("config")

local sprites = {}

-- Each sprite is a grid of { char, fg, bg } pixels.
-- " " with bg draws a colored block; char with fg draws text.

local function solid(bg)
    return { char = " ", fg = colors.white, bg = bg }
end

local function pixel(char, fg, bg)
    return { char = char, fg = fg, bg = bg or colors.black }
end

local function transparent()
    return { char = " ", fg = colors.white, bg = colors.black }
end

-- 16x16 base X pattern (scaled up when drawn)
local X_PATTERN = {
    "X...............",
    ".X.............X",
    "..X...........X.",
    "...X.........X..",
    "....X.......X...",
    ".....X.....X....",
    "......X...X.....",
    ".......X.X......",
    "........X.......",
    ".......X.X......",
    "......X...X.....",
    ".....X.....X....",
    "....X.......X...",
    "...X.........X..",
    "..X...........X.",
    ".X.............X",
}

local O_PATTERN = {
    "..OOOOOOOOOO....",
    ".OOOOOOOOOOOOO..",
    "OOOO........OOOO",
    "OOO..........OOO",
    "OO............OO",
    "OO............OO",
    "OO............OO",
    "OO............OO",
    "OO............OO",
    "OO............OO",
    "OO............OO",
    "OO............OO",
    "OOO..........OOO",
    "OOOO........OOOO",
    ".OOOOOOOOOOOOO..",
    "..OOOOOOOOOO....",
}

local function patternToGrid(pattern, fgColor, bgColor)
    local grid = {}
    for row = 1, #pattern do
        grid[row] = {}
        local line = pattern[row]
        for col = 1, #line do
            local ch = line:sub(col, col)
            if ch == "X" or ch == "O" then
                grid[row][col] = solid(fgColor)
            elseif ch == "." then
                grid[row][col] = transparent()
            else
                grid[row][col] = pixel(ch, fgColor, bgColor)
            end
        end
    end
    return grid
end

function sprites.getXGrid(color)
    return patternToGrid(X_PATTERN, color or config.colors.playerX, colors.black)
end

function sprites.getOGrid(color)
    return patternToGrid(O_PATTERN, color or config.colors.playerO, colors.black)
end

--- Draw a sprite grid scaled to fit within width/height at (ox, oy).
function sprites.drawGrid(monitor, grid, ox, oy, maxW, maxH)
    local srcH = #grid
    local srcW = #grid[1]
    local scaleX = math.max(1, math.floor(maxW / srcW))
    local scaleY = math.max(1, math.floor(maxH / srcH))
    local scale = math.min(scaleX, scaleY)
    local drawW = srcW * scale
    local drawH = srcH * scale
    local startX = ox + math.floor((maxW - drawW) / 2)
    local startY = oy + math.floor((maxH - drawH) / 2)

    for row = 1, srcH do
        for sy = 0, scale - 1 do
            local py = startY + (row - 1) * scale + sy
            for col = 1, srcW do
                local p = grid[row][col]
                for sx = 0, scale - 1 do
                    local px = startX + (col - 1) * scale + sx
                    monitor.setCursorPos(px, py)
                    monitor.setBackgroundColor(p.bg)
                    monitor.setTextColor(p.fg)
                    monitor.write(p.char)
                end
            end
        end
    end
end

--- Draw X or O marker in a board cell.
function sprites.drawMarker(monitor, marker, cellX, cellY, cellW, cellH, pulse)
    local ox = cellX + 1
    local oy = cellY + 1
    local innerW = cellW - 2
    local innerH = cellH - 2

    if marker == config.PLAYER_X then
        local color = config.colors.playerX
        if pulse then
            color = colors.orange
        end
        sprites.drawGrid(monitor, sprites.getXGrid(color), ox, oy, innerW, innerH)
    elseif marker == config.PLAYER_O then
        local color = config.colors.playerO
        if pulse then
            color = colors.lightBlue
        end
        sprites.drawGrid(monitor, sprites.getOGrid(color), ox, oy, innerW, innerH)
    end
end

--- Draw decorative title X/O for menus.
function sprites.drawTitleIcon(monitor, marker, x, y)
    if marker == "X" then
        sprites.drawGrid(monitor, sprites.getXGrid(config.colors.playerX), x, y, 14, 14)
    else
        sprites.drawGrid(monitor, sprites.getOGrid(config.colors.playerO), x, y, 14, 14)
    end
end

return sprites
