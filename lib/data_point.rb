#represents a single 3d point with scalar and direction(normal)
class DataPoint 
  attr_accessor :vertex, :normal
  def initialize(vertex, normal)
    self.vertex = vertex
    self.normal = normal
  end
  
end