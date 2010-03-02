require 'lib/computation'
require 'lib/data_point'
require 'lib/vector'
class IsoSurfaceViewer < Processing::App
  load_library :opengl
  include_package 'processing.opengl'
  def setup
    size 800, 600, OPENGL
    #@triangles = Computation.test
    @triangles = YAML::load(File.open(File.dirname(__FILE__) + '/test.yml'))
    #puts @triangles.size
    # @triangles = []
    #     (0..44).each do |i|
    #       scalar = Vector.new({:x => rand(i*100), :y => rand(i+15), :z => rand(i+54)})
    #       normal = Vector.new({:x => rand(i*20), :y => rand(i+135), :z => rand(i+52)})
    #       normal = normal.normalize
    #       @triangles << DataPoint.new(scalar, normal)
    #     end
  end

  def draw
    #normal(5, 6, 1.0) - equivalent to glNormal3f 
    # line(5,5,5,100,100,10) 
    ambient_light(102,102,102)
    fov = PI/3.0
    height = 1000.0
    width = 1000.0
    cameraZ = (height/2.0) / tan(fov/2.0)
    perspective(fov, (width)/(height), cameraZ/10.0, cameraZ*10.0)
    push_matrix
    scale(0.05,0.05,0.05)
    begin_shape(TRIANGLES)
      @triangles.each_value do |triangle|
        vertex = triangle["vertex"]
        normal = triangle["normal"]
        normal(normal[:x], normal[:y], normal[:z])
        vertex(vertex[:x], vertex[:y], vertex[:z])
      end
    end_shape
    pop_matrix
  end
  
      
end
IsoSurfaceViewer.new :title => "3D Visualization", :width => 1000, :height => 1000
