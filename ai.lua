-- Smart tic-tac-toe AI using minimax with alpha-beta pruning

local config = require("config")

local ai = {}

local WIN_LINES = {
    { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 },
    { 1, 4, 7 }, { 2, 5, 8 }, { 3, 6, 9 },
    { 1, 5, 9 }, { 3, 5, 7 },
}

local function copyBoard(board)
    local copy = {}
    for i = 1, 9 do
        copy[i] = board[i]
    end
    return copy
end

function ai.checkWinner(board)
    for _, line in ipairs(WIN_LINES) do
        local a, b, c = line[1], line[2], line[3]
        if board[a] ~= config.EMPTY
            and board[a] == board[b]
            and board[b] == board[c] then
            return board[a], line
        end
    end

    for i = 1, 9 do
        if board[i] == config.EMPTY then
            return nil, nil
        end
    end

    return "draw", nil
end

local function getEmptyCells(board)
    local cells = {}
    for i = 1, 9 do
        if board[i] == config.EMPTY then
            cells[#cells + 1] = i
        end
    end
    return cells
end

local function scoreResult(winner, aiPlayer)
    if winner == aiPlayer then
        return 10
    elseif winner == "draw" then
        return 0
    else
        return -10
    end
end

local function minimax(board, depth, isMaximizing, aiPlayer, humanPlayer, alpha, beta)
    local winner = ai.checkWinner(board)
    if winner then
        if winner == "draw" then
            return 0, nil
        end
        return scoreResult(winner, aiPlayer) - depth, nil
    end

    if isMaximizing then
        local bestScore = -math.huge
        local bestMove = nil
        for _, cell in ipairs(getEmptyCells(board)) do
            board[cell] = aiPlayer
            local score = minimax(board, depth + 1, false, aiPlayer, humanPlayer, alpha, beta)
            board[cell] = config.EMPTY
            if score > bestScore then
                bestScore = score
                bestMove = cell
            end
            alpha = math.max(alpha, score)
            if beta <= alpha then
                break
            end
        end
        return bestScore, bestMove
    else
        local bestScore = math.huge
        local bestMove = nil
        for _, cell in ipairs(getEmptyCells(board)) do
            board[cell] = humanPlayer
            local score = minimax(board, depth + 1, true, aiPlayer, humanPlayer, alpha, beta)
            board[cell] = config.EMPTY
            if score < bestScore then
                bestScore = score
                bestMove = cell
            end
            beta = math.min(beta, score)
            if beta <= alpha then
                break
            end
        end
        return bestScore, bestMove
    end
end

--- Choose the best move for aiPlayer on the given board.
function ai.chooseMove(board, aiPlayer, humanPlayer)
    local working = copyBoard(board)
    local _, move = minimax(working, 0, true, aiPlayer, humanPlayer, -math.huge, math.huge)
    if move then
        return move
    end

    -- Fallback: first empty cell (should never happen on non-full board)
    for i = 1, 9 do
        if board[i] == config.EMPTY then
            return i
        end
    end
    return nil
end

--- Quick heuristic move for variety on first move (still optimal).
function ai.openingMove(board, aiPlayer)
    if board[5] == config.EMPTY then
        return 5
    end
    local corners = { 1, 3, 7, 9 }
    for _, c in ipairs(corners) do
        if board[c] == config.EMPTY then
            return c
        end
    end
    return ai.chooseMove(board, aiPlayer, config.PLAYER_X)
end

function ai.getWinLines()
    return WIN_LINES
end

return ai
