require 'sketchup.rb'
require "extensions.rb"
#require 'point3d_qw.rb'
#require 'face_scope.rb'

module Qisheng
  #module CostInspector
  #module Step10
  
  PLUGIN_ROOT = "D:/UW CM/CM 700/Sketchup/Git/htmldialog-examples-main/src"
  PLUGIN_ID = File.basename(__FILE__, ".rb")
  PLUGIN_DIR = File.dirname(__FILE__)
  EXTENSION = SketchupExtension.new(
    "Test",
    File.join(PLUGIN_DIR, PLUGIN_ID)
  )
  Sketchup.register_extension(EXTENSION, true)
  menu = UI.menu("Plugins")
  menu.add_item(EXTENSION.name) {method_test}

  @areas = 0
  @count = 0
  def self.method_test
    scan
    puts @areas
    puts @count
  end

  def self.perimeter(face)
    total = 0
    edges = face.edges
    edges.each {|edge|
      total += edge.length
    }
    total
  end

  def self.scan
    @areas = 0
    cd_faces = Set[];
    mark_pts = [];
    model = Sketchup.active_model
    entities = model.entities
    entities.each {|entity|
      case entity
      when Sketchup::Face
        normal = plane_normal(entity.plane)
        p_length = perimeter(entity)
        if normal.parallel?(Z_AXIS) && p_length>40*12
          cd_faces.add(entity)
        end
        if wall?(entity)
          edges = entity.edges
          edges.each {|edge|
            pt = edge.end.position
            mark_pts << pt
          }
        end
      end
    }
    mark_pts = mark_pts.uniq(&:to_a)
    plots = distill(cd_faces,mark_pts)
    plots = reduce_dup(plots)
    plots.each{|plot| register(plot)}
  end

  def self.reduce_dup (faces)
    sel_faces = []
    faces.each {|entity|
       if sel_faces.empty?
        sel_faces << entity
      else
        sel_faces.each { |face|
          face_scope1 = Face_scope.new(face)
          face_scope2 = Face_scope.new(entity)
          if !face_scope1.overlaping? (face_scope2)
            sel_faces << entity
          end
        }
      end
    }
    sel_faces
  end

  def self.wall? face
    normal = plane_normal(face.plane)
    if normal[2] == 0
      max_height = height(face.edges)
      if max_height > 60 && max_height < 40*12
        return true
      end
    end
    return false
  end

  def self.distill (entities,pts)
    plots = Set[]
    entities.each {|entity|
      edges = entity.edges
      edges.each {|edge|
        sample = edge.end.position
        if pts.include?(sample)
          plots.add(entity)
          break
        end
      }
    }
    plots
  end

  def self.register (entity)
    area = entity.area/144
    @areas += area
    @count += 1

    model = Sketchup.active_model
    materials = model.materials
    matl = materials.add('red')
    matl.color= "Red"
    entity.material = matl
    entity.back_material = matl
  end

  def self.plane_normal(plane)
    return plane[1].normalize if plane.size == 2
    a, b, c, _ = plane
    Geom::Vector3d.new(a, b, c).normalize
  end

  def self.height(edges)
    num_max = 0
    num_min = 10000000
    edges.each {|edge|
      pt = edge.end.position
      num = pt[2]
      if num_max < num
        num_max = num
      end
      if num_min > num
        num_min = num
      end
    }
    num_max-num_min
  end
#end # Step10
#end # CostInspector
end # Qisheng