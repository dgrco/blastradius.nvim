local git = require("blastradius.git")
local ui = require("blastradius.ui")

local M = {}

function M.setup()
    vim.keymap.set("n", "<leader>gb", function ()
        -- 1. get commit hash for current line
        local root = vim.fs.root(0, { ".git" })
        if not root then
            vim.notify("You are not inside a Git repository.")
            return
        end

        local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
        local hash, err = git.get_commit_for_line(0, current_line_num, root)
        if err then
            vim.notify(err)
            return
        end

        -- 2. get files from that commit
        local files = git.get_files_from_commit(hash, root)

        -- 3. show them
        ui.select(files, hash, function(file)
            ui.show_diff(file, hash, root)
        end)
    end, { desc = "BlastRadius line" })
end

return M
