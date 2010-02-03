require 'vector'
require 'data_point'
class Computation
  attr_accessor :iso_value, :weight
  def initialize(options = {})
    @iso_value = options[:iso_value]
    @x_dimension = options[:x_dimension]
    @y_dimension = options[:y_dimension]
    @z_dimension = options[:z_dimension]
    @weight = options[:weight]
  end
  
  def find_offsets(x, y, z)
  	index = (x+ y*@x_dimension + z*@x_dimenstion*@y_dimension)
  end
  
  #interpolate the scalar values and get the intersection point
  def interpolate_scalar(vector_a, vector_b, isovalue, first, second)
  	point = {}
  	@weight = (isovalue - first)/(second - first)
  	vector_a.point.each{|key, val|
  	  point[key] = val + @weight*(vector_b.point[key]) - val 
  	}
  	Vector.new(point)
  end
  
  #interpolate the normal vectors and get the normal vector at the intersected point
  def interpolate_normal(normal_a, normal_b, weight = @weight)
  	point = {}
  	magnitude = 0.0
    normal_a.point.each{|key, val|
      point[key] = val + weight*(normal_b.point[key] - val)
    }
    magnitude = Math.sqrt(point.values.inject(0){|sum, val| sum + (val**2)})
    point.each{|key, val|
      point[key] = val/magnitude   
    }
  	Vector.new(point)
  end
  
  #Given 8-bit mask, convert into a single 
  def to_decimal(bit_mask)
  	value = 0.0
  	bit_mask.each_with_index{|val, index| value += val*(2**index) }
    value.to_i
  end
  
  
end