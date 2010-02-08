require 'lib/vector'
require 'lib/data_point'
class Computation
  attr_accessor :iso_value, :weight
  def initialize(options = {})
    @iso_value = options[:iso_value]
    @x_dimension = nil
    @y_dimension = nil
    @z_dimension = nil
    @weight = nil
    @size = nil
    @file = options[:file]
    @buffer = nil
  end
  
  #Read the binary file data into array
  def read_file
    buffer = ""
    f = File.new(@file, "r")
    f.each_byte{|b| buffer << b }
    f.close
    @x_dimension, @y_dimension, @z_dimension = buffer.unpack('III') #THe first 3 int values are x, y, z dimensions
    @size = @x_dimension*@y_dimension*z_dimension
    @buffer = buffer[0..@size-1] #Assuming unsigned char is 1 byte
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
