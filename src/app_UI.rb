require 'sketchup.rb'
require 'json'

module Qisheng
#module CostInspector
#module Step10
PLUGIN_ROOT = "D:/UW CM/CM 700/Sketchup/Git/QW/Cost-Guru/src"


  def self.create_dialog(num)
    name = "step" + num.to_s + ".html"
    html_file = File.join(__dir__, 'html', name)
    options = {
      :dialog_title => "Assembly Cost Estimate",
      :preferences_key => "Qisheng.htmldialog.cost_inspector",
      :style => UI::HtmlDialog::STYLE_DIALOG
    }
    dialog = UI::HtmlDialog.new(options)
    dialog.set_file(html_file)
    dialog.center
    dialog
  end

  def self.show_dialog(num)
    @dialog = self.create_dialog(num)
    @dialog.add_action_callback("ready") { |action_context|
      self.update_dialog
    }

    @dialog.add_action_callback("cancel") { |action_context|
      @dialog.close
      nil
    }

    @dialog.add_action_callback("apply") { |action_context|
      #self.update_material(value, value2)
      self.update_dialog
    }

    @dialog.add_action_callback("apply_asb") { |action_context|
      #self.update_material(value, value2)
      self.update_dialog_assembly
    }

    @dialog.add_action_callback("log") { |action_context, data|
      #self.update_material(value, value2)
      puts data
    }

    @dialog.show
  end

  # Update dialog with square-foot data.
  def self.update_dialog
    #return if @dialog.nil?
    self.scan
    @dialog.execute_script("set_base_size(#{@areas})")
  end

  def self.update_dialog_assembly
    #return if @dialog.nil?
    self.scan
    @dialog.execute_script("setBaseSize(#{@areas})")
    @dialog.execute_script("setPerimeter(#{@perimeter_total})")
    puts "result sent"
  end

  file_loaded(__FILE__)

  def self.reload(clear_console = true, undo = false)
    # Hide warnings for already defined constants.
    verbose = $VERBOSE
    $VERBOSE = nil
    Dir.glob(File.join(PLUGIN_ROOT, "*.{rb,rbe}")).each { |f| load(f) }
    $VERBOSE = verbose
    # Use a timer to make call to method itself register to console.
    # Otherwise the user cannot use up arrow to repeat command.
    UI.start_timer(0) { SKETCHUP_CONSOLE.clear } if clear_console
    Sketchup.undo if undo
    nil
  end

#end # Step10
#end # CostInspector
end # Qisheng