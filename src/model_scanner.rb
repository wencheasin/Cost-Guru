require 'sketchup.rb'
require "extensions.rb"
#require 'point3d_qw.rb'
#require 'face_scope.rb'

module Qisheng
  #module CostInspector
  #module Step10

  @areas = 0
  @area_collection = []
  @count = 0

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
    @area_collection.clear()
    cd_faces = Set[];
    mark_pts = [];
    model = Sketchup.active_model
    entities = model.entities
    entities.each {|entity|
      case entity
      when Sketchup::Face
        normal = plane_normal(entity.plane)
        p_length = perimeter(entity)
        area = entity.area
        if normal.parallel?(Z_AXIS) && p_length>40*12 &&
          area > 50*12*12
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
    plots = sel_base(plots)
    plots.each{|plot| register(plot)}
    puts @area_collection
    puts
  end

  def self.sel_base (faces)
    sel_scopes = {}
    sel_faces = []
    faces.each {|entity|
      face_scope_cnd = Face_scope.new(entity)
      sel_scopes[face_scope_cnd] = entity
    }
    scopes = sel_scopes.keys
    if scopes.length >= 2
      while scopes.length >= 2
        scope1 = scopes[0]
        overlaped = false
        overlap_cnd = []
        overlap_cnd << scope1
        scopes.delete(scope1)
        scopes_itt = Array.new(scopes)
        scopes_itt.each{|scope|
          if !(scope.non_overlaping?(scope1))
            overlaped = true
            overlap_cnd << scope
            scopes.delete(scope)
          end
        }
        if !overlaped
          sel_faces << sel_scopes[scope1]
        else
          sel_faces << biggest(overlap_cnd,sel_scopes)
        end
      end
    else
      sel_faces << faces[0]
    end
    sel_faces
  end

  def self.biggest (scope_ary,scope_face_h)
    scope_ary.sort! {|a,b|
      scope_face_h[a].area - scope_face_h[b].area}
    scope_face_h[scope_ary[-1]]
  end

  def self.wall? face
    normal = plane_normal(face.plane)
    if normal[2] == 0
      max_height = height(face.edges)
      if max_height > 30 && max_height < 40*12
        return true
      end
    end
    return false
  end

  def self.distill (entities,pts)
    plots = []
    entities.each {|entity|
      edges = entity.edges
      edges.each {|edge|
        sample = edge.end.position
        if pts.include?(sample)
          plots << entity
          break
        end
      }
    }
    plots
  end

  def self.register (entity)
    area = entity.area/144
    @areas += area
    @area_collection << area
    @count += 1

    model = Sketchup.active_model
    materials = model.materials
    matl = materials.add('red')
    matl.color= "Red"
    entity.material = matl
    entity.back_material = matl
    tag(entity)
  end

  def self.tag (face)
    model = Sketchup.active_model
    layers = model.layers
    layer = layers.add("building base")
    face.layer = layer
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