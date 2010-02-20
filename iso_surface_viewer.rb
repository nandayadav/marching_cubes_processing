require 'lib/computation'
require 'lib/data_point'
require 'lib/vector'
class IsoSurfaceViewer < Processing::App
  load_library :opengl
  include_package 'processing.opengl'
  def setup
    size 800, 600, OPENGL
    @triangles = []
    (0..44).each do |i|
      scalar = Vector.new({:x => rand(i*100), :y => rand(i+15), :z => rand(i+54)})
      normal = Vector.new({:x => rand(i*20), :y => rand(i+135), :z => rand(i+52)})
      normal = normal.normalize
      @triangles << DataPoint.new(scalar, normal)
    end
  end

  def draw
    #normal(5, 6, 1.0) - equivalent to glNormal3f 
    # line(5,5,5,100,100,10) 
    begin_shape(TRIANGLES)
      @triangles.each do |triangle|
        vertex = triangle.vertex.point
        normal = triangle.normal.point
        normal(normal[:x], normal[:y], normal[:z])
        vertex(vertex[:x], vertex[:y], vertex[:z])
      end
    end_shape
  end
  
      
end
IsoSurfaceViewer.new :title => "3D Visualization", :width => 800, :height => 600
