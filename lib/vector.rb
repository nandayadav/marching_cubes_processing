class Vector < Struct.new(:point)
  attr_accessor :point
  def initialize(point = {:x => 0, :y => 0, :z => 0})
    self.point = point
  end
  
  def magnitude
    Math.sqrt(self.point.values.inject(0){|sum, val| sum + (val**2)})
  end
  
  def normalize
    magnitude = self.magnitude
    Vector.new({:x => self.point[:x] / magnitude, :y => self.point[:y] / magnitude, :z => self.point[:z] / magnitude})
  end
end