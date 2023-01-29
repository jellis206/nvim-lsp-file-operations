local utils = require("lsp-file-operations.utils")
local log = require("lsp-file-operations.log")

local M = {}

M.applyRenameFileCallback = function(data)
  local source_uri, is_dir = utils.get_absolute_path(data.old_name)
  -- currently tsserver does not support renaming directories
  if is_dir then
    return
  end
  local target_uri, _ = utils.get_absolute_path(data.new_name)
  -- TODO apply file filters before sending request.
  -- Probably tsserver should be intrested only in *.ts and *.js files
  for _, client in pairs(vim.lsp.get_active_clients({ name = "tsserver" })) do
    local params = {
      command = "_typescript.applyRenameFile",
      arguments = {
        {
          sourceUri = source_uri,
          targetUri = target_uri,
        },
      }
    }

    log.debug("Sending tsserver workspace/executeCommand request", params)
    -- TODO get timeout from config
    local resp = client.request_sync("workspace/executeCommand", params, 1000)
    log.debug("Got tsserver workspace/executeCommand response", resp)
  end
end

return M
