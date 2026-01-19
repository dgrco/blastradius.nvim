local M = {}

-- Telescope-supported select with a fallback of vim.ui.select if the user
-- does not have Telescope.
function M.select(files, hash, on_select)
    local has_telescope, telescope = pcall(require, "telescope.builtin")

    if not has_telescope then
        -- Fallback to classic selector
        M.select_classic(files, on_select)
        return
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Select a file from this commit (" .. hash .. ")",
        finder = require("telescope.finders").new_table({ results = files }),
        sorter = require("telescope.config").values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            require("telescope.actions").select_default:replace(function()
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                on_select(selection[1])
            end)
            return true
        end
    }):find()
end

-- Show the classic (quickfix) file selector
function M.select_classic(files, hash, on_select)
    vim.ui.select(files, {
        prompt = "Select a file from this commit (" .. hash .. "):",
        format_item = function(item)
            return "📄 " .. item
        end,
    }, function(result)
        on_select(result)
    end)
end

-- Show a file's git diff between `hash` and its parent commit 
-- in a separate read-only buffer.
function M.show_diff(file, hash, root)
    local diff_result = vim.system(
        { "git", "show", hash, "--", file },
        { text = true, cwd = root }
    ):wait()

    local buf = vim.api.nvim_create_buf(false, true)

    if diff_result.code ~= 0 then
        local lines = "Error running git diff:\n" .. diff_result.stderr
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        return
    end

    vim.api.nvim_buf_set_name(buf, string.format("commit://%s/%s", hash:sub(1, 7), file))

    vim.cmd.vsplit()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)

    local lines = vim.split(diff_result.stdout, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, 'readonly', true)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'diff')
end

return M
