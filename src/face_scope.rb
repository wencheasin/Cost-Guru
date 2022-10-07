#require 'sketchup.rb'

class Face_scope
    attr_reader :x_scope, :y_scope, :z_scope, :face
    def initialize entity
        @face = entity
        @x_scope = get_scope[0]
        @y_scope = get_scope[1]
        @z_scope = get_scope[2]
    end

    def get_scope
        edges = @face.edges
        pts = []
        x_values = []
        y_values = []
        z_values = []
        scope = []
        edges.each {|edge|
            pt_end = edge.end.position
            pts << pt_end
            x_values << pt_end.x
            y_values << pt_end.y
            z_values << pt_end.z
        }
        scope[0] = [x_values.min,x_values.max]
        scope[1] = [y_values.min,y_values.max]
        scope[2] = [z_values.min,z_values.max]
        scope
    end

    # def non_overlaping? (other)
    #     (@x_scope[0] <= other.x_scope[0] &&
    #      @x_scope[1] >= other.x_scope[1] &&
    #      @y_scope[0] <= other.y_scope[0] &&
    #      @y_scope[1] >= other.y_scope[1]) ||
    #     (@x_scope[0] > other.x_scope[0] &&
    #      @x_scope[1] < other.x_scope[1] &&
    #      @y_scope[0] > other.y_scope[0] &&
    #      @y_scope[1] < other.y_scope[1])
    # end
    def non_overlaping? (other)
        (self.x_scope[0] >= other.x_scope[1] ||
         self.x_scope[1] <= other.x_scope[0] ||
         self.y_scope[0] >= other.y_scope[1] ||
         self.y_scope[1] <= other.y_scope[0])
    end

    def eql? (other)
        this.x_scope == other.x_scope &&
        this.y_scope == other.y_scope &&
        this.z_scope == other.z_scope
    end

    def hash
        ary = [@x_scope,@y_scope,@z_scope]
        ary.hash
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
# puts face_scope.non_overlaping?(face_scope2)
# puts "look"