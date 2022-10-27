module Qisheng
    model = Sketchup.active_model
    @layer_temp = model.active_layer
    @status = true

    def self.toggle_layers
        if @status == true
            self.iso
        else
            self.return_layers
        end
    end

    def self.iso
        model = Sketchup.active_model
        layers = model.layers
        model.active_layer = layers["building base"]
        layers.each {|layer|
          if layer != layers["building base"]
            layer.visible = false
          end
        }
        @status = false
    end

    def self.return_layers
        model = Sketchup.active_model
        layers = model.layers
        layers.each {|layer|
          layer.visible = true
        }
        model.active_layer = @layer_temp
        @status = true
    end
end