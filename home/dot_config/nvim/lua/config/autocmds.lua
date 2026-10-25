-- Hebrew/English: leaving insert mode switches the Mac to English (so normal-mode keys work),
-- entering insert mode restores whatever layout you were typing in. Local Mac only.
if vim.fn.executable("macism") == 1 and not (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) then
  local english = "com.apple.keylayout.ABC"
  local insert_source = nil
  local group = vim.api.nvim_create_augroup("omachy_input_source", { clear = true })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      vim.system({ "macism" }, { text = true }, function(res)
        insert_source = vim.trim(res.stdout or "")
        if insert_source ~= "" and insert_source ~= english then
          vim.system({ "macism", english })
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      if insert_source and insert_source ~= "" and insert_source ~= english then
        vim.system({ "macism", insert_source })
      end
    end,
  })
end
