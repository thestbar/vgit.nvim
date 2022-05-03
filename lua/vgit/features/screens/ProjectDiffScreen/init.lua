local fs = require('vgit.core.fs')
local loop = require('vgit.core.loop')
local icons = require('vgit.core.icons')
local Scene = require('vgit.ui.Scene')
local Feature = require('vgit.Feature')
local utils = require('vgit.core.utils')
local Window = require('vgit.core.Window')
local console = require('vgit.core.console')
local project_diff_preview_setting = require(
  'vgit.settings.project_diff_preview'
)
local CodeView = require('vgit.ui.views.CodeView')
local FoldableListView = require('vgit.ui.views.FoldableListView')
local Query = require('vgit.features.screens.ProjectDiffScreen.Query')
local Mutation = require('vgit.features.screens.ProjectDiffScreen.Mutation')

local ProjectDiffScreen = Feature:extend()

function ProjectDiffScreen:constructor()
  local scene = Scene()
  local query = Query()
  local mutation = Mutation()

  return {
    name = 'Project Diff Screen',
    scene = scene,
    query = query,
    mutation = mutation,
    layout_type = nil,
    code_view = CodeView(scene, query, {
      height = '80vh',
      width = '100vw',
    }, {
      elements = {
        header = true,
        footer = false,
      },
    }),
    foldable_list_view = FoldableListView(scene, query, {
      height = '100vh',
      width = '100vw',
      row = '80vh',
    }, {
      elements = {
        header = true,
        footer = false,
      },
      get_list = function(list)
        if not list then
          return nil
        end

        local foldable_list = {}

        for key in pairs(list) do
          local entries = list[key]

          foldable_list[#foldable_list + 1] = {
            open = true,
            value = key,
            items = utils.list.map(entries, function(entry)
              local file = entry.file
              local filename = file.filename
              local filestatus = file.status:to_string()
              local value = string.format('%s %s', filename, filestatus)
              local icon, icon_hl = icons.file_icon(filename, file.filetype)

              local list_entry = {
                id = entry.id,
                value = value,
              }

              if icon then
                list_entry.icon_before = {
                  icon = icon,
                  hl = icon_hl,
                }
              end

              return list_entry
            end),
          }
        end

        return foldable_list
      end,
    }),
  }
end

function ProjectDiffScreen:trigger_keypress(key, ...)
  self.scene:trigger_keypress(key, ...)

  return self
end

ProjectDiffScreen.stage_file = loop.debounce(
  loop.async(function(self)
    local _, filename = self.query:get_filename()

    if not filename then
      return self
    end

    self.mutation:stage_file(filename)

    self.foldable_list_view:evict_cache()

    loop.await_fast_event()
    self.query:fetch(self.layout_type)
    loop.await_fast_event()

    self.foldable_list_view:render()

    local list_item = self.foldable_list_view:get_current_list_item()

    self.query:set_id(list_item.id)

    self.code_view:render():navigate_to_mark(1)

    return self
  end),
  15
)

ProjectDiffScreen.unstage_file = loop.debounce(
  loop.async(function(self)
    local _, filename = self.query:get_filename()

    if not filename then
      return self
    end

    self.mutation:unstage_file(filename)

    self.foldable_list_view:evict_cache()

    loop.await_fast_event()
    self.query:fetch(self.layout_type, true)
    loop.await_fast_event()

    self.foldable_list_view:render()

    local list_item = self.foldable_list_view:get_current_list_item()

    self.query:set_id(list_item.id)

    self.code_view:render():navigate_to_mark(1)

    return self
  end),
  15
)

ProjectDiffScreen.stage_all = loop.debounce(
  loop.async(function(self)
    self.mutation:stage_all()

    self.foldable_list_view:evict_cache()

    loop.await_fast_event()
    self.query:fetch(self.layout_type)
    loop.await_fast_event()

    self.foldable_list_view:render()

    local list_item = self.foldable_list_view:get_current_list_item()

    self.query:set_id(list_item.id)

    self.code_view:render():navigate_to_mark(1)

    return self
  end),
  15
)

ProjectDiffScreen.unstage_all = loop.debounce(
  loop.async(function(self)
    self.mutation:unstage_all()

    self.foldable_list_view:evict_cache()

    loop.await_fast_event()
    self.query:fetch(self.layout_type)
    loop.await_fast_event()

    self.foldable_list_view:render()

    local list_item = self.foldable_list_view:get_current_list_item()

    self.query:set_id(list_item.id)

    self.code_view:render():navigate_to_mark(1)

    return self
  end),
  15
)

ProjectDiffScreen.reset_all = loop.debounce(
  loop.async(function(self)
    loop.await_fast_event()
    local decision = console.input(
      'Are you sure you want to discard all tracked changes? (y/N) '
    ):lower()

    if decision ~= 'yes' and decision ~= 'y' then
      return
    end

    loop.await_fast_event()
    self.mutation:reset_all()
    loop.await_fast_event()

    self.foldable_list_view:evict_cache()

    loop.await_fast_event()
    self.query:fetch(self.layout_type)
    loop.await_fast_event()

    self.foldable_list_view:render()

    local list_item = self.foldable_list_view:get_current_list_item()

    self.query:set_id(list_item.id)

    self.code_view:render():navigate_to_mark(1)

    return self
  end),
  15
)

ProjectDiffScreen.clean_all = loop.debounce(
  loop.async(function(self)
    loop.await_fast_event()
    local decision = console.input(
      'Are you sure you want to discard all untracked changes? (y/N) '
    ):lower()

    if decision ~= 'yes' and decision ~= 'y' then
      return
    end

    loop.await_fast_event()
    self.mutation:clean_all()
    loop.await_fast_event()

    self.foldable_list_view:evict_cache()

    loop.await_fast_event()
    self.query:fetch(self.layout_type)
    loop.await_fast_event()

    self.foldable_list_view:render()

    local list_item = self.foldable_list_view:get_current_list_item()

    self.query:set_id(list_item.id)

    self.code_view:render():navigate_to_mark(1)

    return self
  end),
  15
)

function ProjectDiffScreen:show()
  console.log('Processing project diff')

  local query = self.query
  local layout_type = self.layout_type

  loop.await_fast_event()
  local err = query:fetch(layout_type)

  if err then
    console.debug.error(err).error(err)
    return false
  end

  loop.await_fast_event()
  self.code_view:show(layout_type)
  self.foldable_list_view:show()

  self.code_view:set_keymap({
    {
      mode = 'n',
      key = '<C-j>',
      vgit_key = 'keys.Cj',
      handler = loop.async(function()
        self.code_view:next()
      end),
    },
    {
      mode = 'n',
      key = '<C-k>',
      vgit_key = 'keys.Ck',
      handler = loop.async(function()
        self.code_view:prev()
      end),
    },
    {
      mode = 'n',
      key = '<enter>',
      vgit_key = 'keys.enter',
      handler = loop.async(function()
        local mark = self.code_view:get_current_mark_under_cursor()

        if not mark then
          return
        end

        local _, filename = self.query:get_filename()

        if not filename then
          return
        end

        self:destroy()

        fs.open(filename)

        Window(0):set_lnum(mark.top_relative):call(function()
          vim.cmd('norm! zz')
        end)
      end),
    },
  })

  self.foldable_list_view:set_keymap({
    {
      mode = 'n',
      key = project_diff_preview_setting:get('keymaps').buffer_stage,
      vgit_key = string.format(
        'keys.%s',
        project_diff_preview_setting:get('keymaps').buffer_stage
      ),
      handler = loop.async(function()
        self:stage_file()
      end),
    },
    {
      mode = 'n',
      key = project_diff_preview_setting:get('keymaps').buffer_unstage,
      vgit_key = string.format(
        'keys.%s',
        project_diff_preview_setting:get('keymaps').buffer_unstage
      ),
      handler = loop.async(function()
        self:unstage_file()
      end),
    },
    {
      mode = 'n',
      key = project_diff_preview_setting:get('keymaps').stage_all,
      vgit_key = string.format(
        'keys.%s',
        project_diff_preview_setting:get('keymaps').stage_all
      ),
      handler = loop.async(function()
        self:stage_all()
      end),
    },
    {
      mode = 'n',
      key = project_diff_preview_setting:get('keymaps').unstage_all,
      vgit_key = string.format(
        'keys.%s',
        project_diff_preview_setting:get('keymaps').unstage_all
      ),
      handler = loop.async(function()
        self:unstage_all()
      end),
    },
    {
      mode = 'n',
      key = project_diff_preview_setting:get('keymaps').reset_all,
      vgit_key = string.format(
        'keys.%s',
        project_diff_preview_setting:get('keymaps').reset_all
      ),
      handler = loop.async(function()
        self:reset_all()
      end),
    },
    {
      mode = 'n',
      key = project_diff_preview_setting:get('keymaps').clean_all,
      vgit_key = string.format(
        'keys.%s',
        project_diff_preview_setting:get('keymaps').clean_all
      ),
      handler = loop.async(function()
        self:clean_all()
      end),
    },
    {
      mode = 'n',
      key = 'j',
      vgit_key = 'keys.j',
      handler = loop.async(function()
        local list_item = self.foldable_list_view:move('down')

        query:set_id(list_item.id)
        self.code_view:render_debounced(function()
          self.code_view:navigate_to_mark(1)
        end)
      end),
    },
    {
      mode = 'n',
      key = 'k',
      vgit_key = 'keys.k',
      handler = loop.async(function()
        local list_item = self.foldable_list_view:move('up')

        query:set_id(list_item.id)
        self.code_view:render_debounced(function()
          self.code_view:navigate_to_mark(1)
        end)
      end),
    },
    {
      mode = 'n',
      key = '<enter>',
      vgit_key = 'keys.enter',
      handler = loop.async(function()
        local _, filename = self.query:get_filename()

        if not filename then
          self.foldable_list_view:toggle_current_list_item():render()

          return self
        end

        self:destroy()

        fs.open(filename)
      end),
    },
    {
      mode = 'n',
      key = '<C-j>',
      vgit_key = 'keys.Cj',
      handler = loop.async(function()
        self.code_view:next()
      end),
    },
    {
      mode = 'n',
      key = '<C-k>',
      vgit_key = 'keys.Ck',
      handler = loop.async(function()
        self.code_view:prev()
      end),
    },
  })
  return true
end

function ProjectDiffScreen:destroy()
  self.scene:destroy()

  return self
end

return ProjectDiffScreen