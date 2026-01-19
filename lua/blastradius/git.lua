local M = {}

-- Gets the Git blame's commit hash of the current line
-- Returns nil if something went wrong
function M.get_commit_for_line(bufnr, line, root)
    local line_range = line .. "," .. line
    local file_path = vim.api.nvim_buf_get_name(bufnr)
    local result = vim.system(
        { "git", "blame", "-L", line_range, "--porcelain", "--", file_path },
        { text = true, cwd = root }
    ):wait()

    if result.code ~= 0 then
        return nil, "Git blame failed:\n" .. result.stderr
    end

    local hash = result.stdout:match("^(%S+)")
    if hash == "0000000000000000000000000000000000000000" or hash:sub(1, 1) == "^" then
        return nil, "This line is not yet committed"
    end

    return hash
end

-- Returns the list of files within the commit.
-- Returns nil if something went wrong
function M.get_files_from_commit(hash, root)
    -- Check if this commit has a parent
    local parent_result = vim.system(
        { "git", "rev-list", "--parents", "-n", "1", hash },
        { text = true, cwd = root }
    ):wait()

    local parents = vim.split(parent_result.stdout, " ")

    local result = nil
    if #parents < 2 then
        -- Initial commit
        result = vim.system(
            { "git", "show", "--name-only", "--pretty=format:", hash },
            { text = true, cwd = root }
        ):wait()
    else
        result = vim.system(
            { "git", "diff", "--name-only", hash .. "^1", hash },
            { text = true, cwd = root }
        ):wait()
    end

    if result.code ~= 0 then
        return nil, "Could not get files from commit"
    end

    local files = {}

    for path in result.stdout:gmatch("[^\r\n]+") do
        table.insert(files, path)
    end

    return files
end

function M.get_commit_info(hash, root)
    -- returns { parents = {...}, is_initial = bool }
end

return M
