#represents a single 3d point with scalar and direction(normal)
class DataPoint < Struct.new(:vertex, :normal)
  
  def initialize(vertex, normal)
    self.vertex = vertex
    self.normal = normal
  end
  
end