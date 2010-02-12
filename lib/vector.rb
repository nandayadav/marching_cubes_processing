class Vector < Struct.new(:point)
  attr_accessor :point
  def initialize(point = {:x => 0, :y => 0, :z => 0})
    self.point = point
  end
  
  def magnitude
    squared = 0
    self.point.each_val{|v| squared += (val*val)}
    Math::sqrt(squared)
  end
  
  def normalize
    Vector.new({:x => self.point[:x] / self.magnitude, :y => self.point.y / self.magnitude, :z => self.point.z / self.magnitude})
  end
end