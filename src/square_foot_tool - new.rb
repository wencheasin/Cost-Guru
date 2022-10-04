require 'sketchup.rb'

module Qisheng
#module CostInspector
module Controller

  def self.create_step(index, title, &block)
    cmd = UI::Command.new(title, &block)
    cmd.tooltip = title
    @ext = 'svg'
    # https://www.flaticon.com/free-icons/numbers_931
    icons = File.join(__dir__, 'images')
    Dir.chdir(icons)
    Dir.glob("#{index}.*"){|file|
      if file[/(?<=\.).+/].eql?('png')
        @ext = 'png'
      end
    }
    icon = File.join(__dir__, 'images', "#{index}.#{@ext}")
    cmd.small_icon = icon
    cmd.large_icon = icon
    cmd
  end

  unless file_loaded?(__FILE__)
    cmd = self.create_step(12, 'footage_estimate tool') {
      Qisheng.show_dialog
    }
    cmd2 = self.create_step(11, 'assembly_estimate tool') {
      Qisheng.show_dialog
    }
    terminal = self.create_step(13, 'sketcup terminal') {
      SKETCHUP_CONSOLE.show
    }

    toolbar = UI::Toolbar.new('Cost Guru')
    toolbar.add_item(cmd)
    toolbar.add_separator
    toolbar.add_item(cmd2)
    toolbar.add_separator
    toolbar.add_item(terminal)
    #toolbar.restore
    file_loaded(__FILE__)
  end

end # UI_Controller
#end # CostInspector
end # Qisheng