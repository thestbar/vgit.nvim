local utils = require('vgit.core.utils')
local Window = require('vgit.core.Window')
local Buffer = require('vgit.core.Buffer')
local Component = require('vgit.ui.Component')
local HeaderTitle = require('vgit.ui.decorations.HeaderTitle')
local HeaderElement = require('vgit.ui.elements.HeaderElement')
local FooterElement = require('vgit.ui.elements.FooterElement')
local Notification = require('vgit.ui.decorations.Notification')
local LineNumberElement = require('vgit.ui.elements.LineNumberElement')

local DiffComponent = Component:extend()

function DiffComponent:constructor(props)
  props = utils.object.assign({
    config = {
      elements = {
        header = true,
        line_number = true,
        footer = true,
      },
    },
  }, props)
  return Component.constructor(self, props)
end

function DiffComponent:set_cursor(cursor)
  self.window:set_cursor(cursor)

  return self
end

function DiffComponent:set_lnum(lnum)
  self.window:set_lnum(lnum)

  return self
end

function DiffComponent:call(callback)
  self.elements.line_number:call(callback)
  self.window:call(callback)

  return self
end

function DiffComponent:reset_cursor()
  self.elements.line_number:reset_cursor()
  Component.reset_cursor(self)

  return self
end

function DiffComponent:clear_lines()
  self.elements.line_number:clear_lines()
  Component.clear_lines(self)

  return self
end

function DiffComponent:sign_unplace()
  self.elements.line_number:sign_unplace()
  self.buffer:sign_unplace()

  return self
end

function DiffComponent:sign_place_line_number(lnum, sign_name)
  self.elements.line_number:sign_place(lnum, sign_name)

  return self
end

function DiffComponent:transpose_virtual_line_number(text, hl, row)
  self.elements.line_number:transpose_virtual_line({ { text, hl } }, row, 'right_align')

  return self
end

function DiffComponent:position_cursor(placement)
  Component.position_cursor(self, placement)
  self.elements.line_number:position_cursor(placement)

  return self
end

function DiffComponent:mount(opts)
  if self.mounted then
    return self
  end

  local config = self.config
  opts = opts or {}

  self.notification = Notification()
  self.header_title = HeaderTitle()
  self.buffer = Buffer():create():assign_options(config.buf_options)

  local buffer = self.buffer
  local plot = self.plot

  self.elements.line_number = LineNumberElement():mount(plot.line_number_win_plot)

  if config.elements.header then
    self.elements.header = HeaderElement():mount(plot.header_win_plot)
  end

  if config.elements.footer then
    self.elements.footer = FooterElement():mount(plot.footer_win_plot)
  end

  self.window = Window:open(buffer, plot.win_plot):assign_options(config.win_options)

  self.mounted = true

  return self
end

function DiffComponent:unmount()
  if not self.mounted then
    return self
  end

  local header = self.elements.header
  local line_number = self.elements.line_number
  local footer = self.elements.footer

  self.window:close()
  if header then
    header:unmount()
  end

  if line_number then
    line_number:unmount()
  end

  if footer then
    footer:unmount()
  end

  return self
end

function DiffComponent:set_title(title, opts)
  local header = self.elements.header

  if not header then
    return self
  end

  self.header_title:set(header, title, opts)

  return self
end

function DiffComponent:clear_title()
  local header = self.elements.header

  if not header then
    return self
  end

  self.header_title:clear(header)

  return self
end

function DiffComponent:make_line_numbers(lines)
  self.elements.line_number:make_lines(lines)

  return self
end

function DiffComponent:clear_namespace()
  self.elements.line_number:clear_namespace()
  Component.clear_namespace(self)

  local header = self.elements.header

  if header then
    header:clear_namespace()
  end

  return self
end

function DiffComponent:clear_notification()
  local header = self.elements.header

  if not header then
    return self
  end

  self.notification:clear_notification(header)

  return self
end

function DiffComponent:notify(text)
  local header = self.elements.header

  if not header then
    return self
  end

  self.notification:notify(header, text)

  return self
end

return DiffComponent
