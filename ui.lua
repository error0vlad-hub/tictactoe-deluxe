-- UI rendering and touch hit-testing for Tic Tac Toe Deluxe

local config = require("config")
local sprites = require("sprites")
local animation = require("animation")
local save = require("save")

local ui = {}

local monitor = nil
local monitorName = nil

function ui.setMonitor(mon, name)
    monitor = mon
    monitorName = name
    monitor.setBackgroundColor(config.colors.bg)
    monitor.setTextColor(config.colors.white)
end

function ui.getMonitorName()
    return monitorName
end

function ui.getMonitor()
    return monitor
end

function ui.clear()
    monitor.setBackgroundColor(config.colors.bg)
    monitor.setTextColor(config.colors.white)
    for y = 1, config.MONITOR_H do
        monitor.setCursorPos(1, y)
        monitor.write(string.rep(" ", config.MONITOR_W))
    end
end

function ui.centerText(text, y, color, bg)
    color = color or config.colors.white
    bg = bg or config.colors.bg
    local x = math.floor((config.MONITOR_W - #text) / 2) + 1
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(color)
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

function ui.drawHLine(y, x1, x2, color, char)
    char = char or " "
    color = color or config.colors.grid
    monitor.setBackgroundColor(color)
    monitor.setTextColor(colors.white)
    for x = x1, x2 do
        monitor.setCursorPos(x, y)
        monitor.write(char)
    end
end

function ui.drawVLine(x, y1, y2, color, char)
    char = char or " "
    color = color or config.colors.grid
    monitor.setBackgroundColor(color)
    monitor.setTextColor(colors.white)
    for y = y1, y2 do
        monitor.setCursorPos(x, y)
        monitor.write(char)
    end
end

function ui.drawBox(x, y, w, h, borderColor, fillColor)
    fillColor = fillColor or config.colors.bg
    borderColor = borderColor or config.colors.gridBright

    monitor.setBackgroundColor(fillColor)
    monitor.setTextColor(colors.white)
    for dy = 1, h do
        monitor.setCursorPos(x, y + dy - 1)
        monitor.write(string.rep(" ", w))
    end

    ui.drawHLine(y, x, x + w - 1, borderColor)
    ui.drawHLine(y + h - 1, x, x + w - 1, borderColor)
    ui.drawVLine(x, y, y + h - 1, borderColor)
    ui.drawVLine(x + w - 1, y, y + h - 1, borderColor)
end

function ui.drawButton(btn, pressed)
    local bg = pressed and config.colors.buttonHover or config.colors.button
    ui.drawBox(btn.x, btn.y, btn.w, btn.h, config.colors.buttonBorder, bg)
    local labelX = btn.x + math.floor((btn.w - #btn.label) / 2)
    local labelY = btn.y + math.floor(btn.h / 2)
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(config.colors.buttonText)
    monitor.setCursorPos(labelX, labelY)
    monitor.write(btn.label)
end

function ui.hitTestButton(btn, tx, ty)
    return tx >= btn.x and tx < btn.x + btn.w
        and ty >= btn.y and ty < btn.y + btn.h
end

function ui.getMenuButtonRect(index)
    local btn = config.menuButtons[index]
    if not btn then
        return nil
    end
    local y = config.MENU_BTN_START_Y + btn.yOffset * config.MENU_BTN_SPACING
    return {
        x = config.MENU_BTN_X,
        y = y,
        w = config.MENU_BTN_W,
        h = config.MENU_BTN_H,
        label = btn.label,
        id = btn.id,
    }
end

function ui.drawMenuButton(index, hovered)
    local rect = ui.getMenuButtonRect(index)
    if not rect then
        return
    end
    local bg = hovered and config.colors.menuAccent or config.colors.menuBg
    ui.drawBox(rect.x, rect.y, rect.w, rect.h, config.colors.buttonBorder, bg)
    local lx = rect.x + math.floor((rect.w - #rect.label) / 2)
    local ly = rect.y + math.floor(rect.h / 2)
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(config.colors.buttonText)
    monitor.setCursorPos(lx, ly)
    monitor.write(rect.label)
end

function ui.hitTestMenu(tx, ty)
    for i = 1, #config.menuButtons do
        local rect = ui.getMenuButtonRect(i)
        if ui.hitTestButton(rect, tx, ty) then
            return rect.id, i
        end
    end
    return nil, nil
end

function ui.drawMainMenu(hoveredIndex)
    ui.clear()

    animation.shimmerTitle(monitor, "TIC TAC TOE DELUXE", 1, 3, config.MONITOR_W)
    ui.centerText("Touch a button to play", 6, config.colors.subtitle)

    sprites.drawTitleIcon(monitor, "X", 20, 12)
    sprites.drawTitleIcon(monitor, "O", config.MONITOR_W - 34, 12)

    ui.drawHLine(22, 10, config.MONITOR_W - 10, config.colors.gridBright, "-")
    ui.drawHLine(48, 10, config.MONITOR_W - 10, config.colors.gridBright, "-")

    for i = 1, #config.menuButtons do
        ui.drawMenuButton(i, hoveredIndex == i)
    end

    local stats = save.get()
    ui.centerText(
        string.format("Games played: %d  |  AI: %d  |  PvP: %d",
            stats.total_games, stats.ai_games, stats.pvp_games),
        config.MONITOR_H - 6,
        config.colors.stats
    )
end

function ui.drawStatsScreen()
    ui.clear()
    ui.centerText("STATISTICS", 4, config.colors.title)
    ui.drawHLine(6, 8, config.MONITOR_W - 8, config.colors.gridBright, "-")

    local s = save.get()
    local lines = {
        "",
        "  PLAYER VS AI",
        string.format("    X (You) wins:  %d", s.pvai_x_wins),
        string.format("    O (AI) wins:   %d", s.pvai_o_wins),
        string.format("    Draws:         %d", s.pvai_draws),
        "",
        "  TWO PLAYERS",
        string.format("    X wins:        %d", s.pvp_x_wins),
        string.format("    O wins:        %d", s.pvp_o_wins),
        string.format("    Draws:         %d", s.pvp_draws),
        "",
        string.format("  Total games:     %d", s.total_games),
    }

    local startY = 10
    for i, line in ipairs(lines) do
        local color = config.colors.panelText
        if line:match("^  PLAYER") or line:match("^  TWO") or line:match("^  Total") then
            color = config.colors.highlight
        end
        monitor.setBackgroundColor(config.colors.bg)
        monitor.setTextColor(color)
        monitor.setCursorPos(12, startY + i - 1)
        monitor.write(line)
    end

    local backBtn = {
        x = math.floor((config.MONITOR_W - 30) / 2),
        y = config.MONITOR_H - 14,
        w = 30,
        h = 5,
        label = " BACK TO MENU ",
        id = "back",
    }
    ui.drawButton(backBtn)
    return backBtn
end

function ui.hitTestStatsBack(tx, ty)
    local backBtn = {
        x = math.floor((config.MONITOR_W - 30) / 2),
        y = config.MONITOR_H - 14,
        w = 30,
        h = 5,
    }
    return ui.hitTestButton(backBtn, tx, ty)
end

function ui.drawHeader(mode, currentPlayer, gameOver, winner, turnLabel)
    monitor.setBackgroundColor(config.colors.bg)

    animation.shimmerTitle(monitor, "TIC TAC TOE DELUXE", 1, 2, config.MONITOR_W)

    local modeText = "Two Players"
    if mode == config.MODE_PVAI then
        modeText = "Player vs AI"
    end
    ui.centerText(modeText, 5, config.colors.subtitle)

    local statusColor = config.colors.white
    local statusText = turnLabel or ""

    if gameOver then
        if winner == "draw" then
            statusText = "DRAW GAME!"
            statusColor = config.colors.draw
        elseif winner == config.PLAYER_X then
            statusText = "X WINS!"
            statusColor = config.colors.playerX
        elseif winner == config.PLAYER_O then
            statusText = "O WINS!"
            statusColor = config.colors.playerO
        end
    else
        if currentPlayer == config.PLAYER_X then
            statusColor = config.colors.playerX
            statusText = statusText ~= "" and statusText or "X's turn"
        else
            statusColor = config.colors.playerO
            statusText = statusText ~= "" and statusText or "O's turn"
        end
    end

    ui.centerText(statusText, 7, statusColor)

    if mode == config.MODE_PVAI then
        ui.centerText("You are X  |  AI is O", 9, config.colors.dim)
    else
        ui.centerText("Player 1: X  |  Player 2: O", 9, config.colors.dim)
    end
end

function ui.drawGrid()
    local bx, by = config.BOARD_X, config.BOARD_Y
    local cw, ch = config.CELL_W, config.CELL_H

    ui.drawBox(bx, by, config.BOARD_W, config.BOARD_H, config.colors.gridBright, config.colors.panel)

    for i = 1, 2 do
        local vx = bx + i * cw
        ui.drawVLine(vx, by, by + config.BOARD_H - 1, config.colors.gridBright)
        local hy = by + i * ch
        ui.drawHLine(hy, bx, bx + config.BOARD_W - 1, config.colors.gridBright)
    end
end

function ui.cellRect(cellIndex)
    local row = math.floor((cellIndex - 1) / 3)
    local col = (cellIndex - 1) % 3
    return {
        x = config.BOARD_X + col * config.CELL_W,
        y = config.BOARD_Y + row * config.CELL_H,
        w = config.CELL_W,
        h = config.CELL_H,
    }
end

function ui.hitTestCell(tx, ty)
    for i = 1, 9 do
        local r = ui.cellRect(i)
        if tx >= r.x and tx < r.x + r.w and ty >= r.y and ty < r.y + r.h then
            return i
        end
    end
    return nil
end

function ui.drawCellMarker(cellIndex, marker, pulse)
    local r = ui.cellRect(cellIndex)
    sprites.drawMarker(monitor, marker, r.x, r.y, r.w, r.h, pulse)
end

function ui.drawBoard(board, pulseCell)
    ui.drawGrid()
    for i = 1, 9 do
        if board[i] ~= config.EMPTY then
            ui.drawCellMarker(i, board[i], pulseCell == i)
        end
    end
end

function ui.drawFooter()
    local s = save.get()
    local statsLine = string.format(
        "Stats  X:%d  O:%d  Draws:%d  Total:%d",
        s.pvai_x_wins + s.pvp_x_wins,
        s.pvai_o_wins + s.pvp_o_wins,
        s.pvai_draws + s.pvp_draws,
        s.total_games
    )
    ui.centerText(statsLine, config.MONITOR_H - 15, config.colors.stats)

    ui.drawButton(config.buttons.menu, false)
    ui.drawButton(config.buttons.restart, false)
end

function ui.drawGameScreen(mode, board, currentPlayer, gameOver, winner, turnLabel, pulseCell)
    ui.drawHeader(mode, currentPlayer, gameOver, winner, turnLabel)
    ui.drawBoard(board, pulseCell)
    ui.drawFooter()
end

function ui.hitTestGameButtons(tx, ty)
    if ui.hitTestButton(config.buttons.menu, tx, ty) then
        return "menu"
    end
    if ui.hitTestButton(config.buttons.restart, tx, ty) then
        return "restart"
    end
    return nil
end

function ui.flashButton(btnId)
    local btn = config.buttons[btnId]
    if btn then
        ui.drawButton(btn, true)
        sleep(0.1)
        ui.drawButton(btn, false)
    end
end

return ui
