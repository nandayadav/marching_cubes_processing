require 'lib/computation'
class IsoSurfaceViewer < Processing::App
  def setup
    size 800, 600
  end

  def draw
    triangle(1,400,56,47,69,7)
  end
  
end
IsoSurfaceViewer.new :title => "3D Visualization", :width => 800, :height => 600
