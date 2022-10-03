#require 'sketchup.rb'

class Face_scope
    attr_reader :x_scope, :y_scope, :face
    def initialize entity
        @face = entity
        @x_scope = get_scope[0]
        @y_scope = get_scope[1]
    end

    def get_scope
        edges = @face.edges
        pts = []
        x_values = []
        y_values = []
        scope = []
        edges.each {|edge|
            pt_end = edge.end.position
            pts << pt_end
            x_values << pt_end.x
            y_values << pt_end.y
        }
        scope[0] = [x_values.min,x_values.max]
        scope[1] = [y_values.min,y_values.max]
        scope
    end

    def overlaping? (other)
        (@x_scope[0] <= other.x_scope[0] &&
         @x_scope[1] >= other.x_scope[1] &&
         @y_scope[0] <= other.y_scope[0] &&
         @y_scope[1] >= other.y_scope[1]) ||
        (@x_scope[0] > other.x_scope[0] &&
         @x_scope[1] < other.x_scope[1] &&
         @y_scope[0] > other.y_scope[0] &&
         @y_scope[1] < other.y_scope[1])
    end
end

# depth = 4
# width = 3
# model = Sketchup.active_model
# entities = model.active_entities
# pts = []
# pts[0] = [0, 0, 0]
# pts[1] = [width, 0, 0]
# pts[2] = [width, depth, 0]
# pts[3] = [0, depth, 0]
# depth = 4
# width = 3
# model = Sketchup.active_model
# entities = model.active_entities
# pts2 = []
# pts2[0] = [0, 0, 3]
# pts2[1] = [width, 0, 3]
# pts2[2] = [width, depth/2, 3]
# pts2[3] = [0, depth/2, 3]

# # Add the face to the entities in the model
# face = entities.add_face(pts)
# face_scope = Face_scope.new(face)
# face2 = entities.add_face(pts2)
# face_scope2 = Face_scope.new(face2)
# puts face_scope.overlaping?(face_scope2)
# puts "look"