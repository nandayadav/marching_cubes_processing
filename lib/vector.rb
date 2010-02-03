class Vector < Struct.new(:point)
  def initialize(point = {:x => 0, :y => 0, :z => 0})
    self.point = point
  end
  
end