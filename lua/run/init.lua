-- modulo hello-world
require "run.command"

local M = {}

M.LOCAL_CONFIG = ".vim/run.json"
M.CALL_METHOD = vim.fn["MonkeyTerminalExec"]
M.LAST_COMMAND = nil

function M.run(label)
    if M.has_local_config() then
        M.run_with_config(label)
    else
        M.run_without_config(label)
    end
end

function M.run_with_config(label)
    if label ~= nil then
        label = label:gsub("%s+", "")
    end
    local config = M.load_local_config()

    if config["version"] ~= "2.0.0" then
        print("Only supports version 2.0.0")
    end

    local task
    -- if no label is given get the first task (default)
    if label == nil or label == "" then
        task = config.tasks[0] or config.tasks[1]
    end

    -- try to match group
    if task == nil then
        for _, t in ipairs(config.tasks) do
            if t.type == label then
                task = t
                break
            end
        end
    end
    -- try to match label
    if task == nil then
        for _, t in ipairs(config.tasks) do
            if t.label == label then
                task = t
                break
            end
        end
    end
    if task then
        M.run_task(task)
    else
        print("Query not found: "..label)
    end
end

function M.run_task(task)
    local command = M.format_command(task.command)
    M.run_command(command)
end

function M.run_without_config(label)
    local command

    if label == nil or label == "" then
        label = vim.bo.filetype
    end

    command = Command[label]
    command = M.format_command(command)
    M.run_command(command)
end

function M.run_last_command()
    if M.LAST_COMMAND == nil then
        M.run()
    else
        M.run_command(M.LAST_COMMAND)
    end
end

function M.run_command(command)
    if command ~= nil then
        M.LAST_COMMAND = command
    end
    M.CALL_METHOD(command)
end

function M.format_command(command)
    local filename = vim.fn["expand"]("%")
    return command:gsub("%%", filename)
end
function M.file_exists(file_name)
  local f = io.open(file_name, "rb")
  if f then f:close() end
  return f ~= nil
end

function M.has_local_config()
    return M.file_exists(M.LOCAL_CONFIG)
end

function M.load_local_config()
    local file = io.open(M.LOCAL_CONFIG, "rb") -- r read mode and b binary mode

    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return vim.fn['json_decode'](content)
end

function M.create_local_config()
    local f = io.open(M.LOCAL_CONFIG, 'w')
    local ft = vim.bo.filetype
    local command = Command[ft] or ""
    f:write('{"version":"2.0.0", "tasks":[{"label": "Run tests", "type": "run", "command": "'.. command ..'", "windows": { "command": "'.. command ..'"}, "presentation": { "reveal": "always", "panel": "new" } } ] }')
    f:close()
end

function M.open_or_create_local_config()
    if not M.has_local_config() then
        M.create_local_config()
    end
    M.open_local_config()
end

function M.open_local_config()
    vim.cmd(":e "..M.LOCAL_CONFIG)
end

function M.run_menu()
    -- TODO: get tasks and call window with tasks
    local config = M.load_local_config()
end


function M.create_command()
  vim.cmd("command! -bang -nargs=* Run lua require('run').run(<q-args>)")
  vim.cmd("command! -bang -nargs=* RunLast lua require('run').run_last_command()")
  vim.cmd("command! -bang -nargs=* RunLocalConfig lua require('run').open_or_create_local_config()")
  vim.cmd("command! -bang -nargs=* RunMenu lua require('run.whid').whid()")
end

function M.init()
  M.create_command()
end

return M
