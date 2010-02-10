require 'lib/vector'
require 'lib/data_point'
class Computation
  attr_accessor :iso_value, :weight
  def initialize(options = {})
    @iso_value = options[:iso_value]
    #3D data specific vars, will be filled in after reading data file
    @x_dimension = nil
    @y_dimension = nil
    @z_dimension = nil
    @weight = nil
    @size = nil
    @file = options[:file]
    @indices = [] #Used to store indices of 8 vertices
    @buffer = ''  #Store actual 3D raw data 
  end
  
  def main_loop
    interpolated_vector = Vector.new
    interpolated_normal = Vector.new
    normal_a = Vector.new
    normal_b = Vector.new
    #Loop through the @buffer
    for k in 0..@z_dimension-1
      for j in 0..@y_dimension-1
        for i in 0..@x_dimension-1
          find_offsets(i, j, k)
          mask = compute_mask(@buffer)
          table_index = to_decimal(mask)
          side_counter = 0
          data_point = DataPoint.new
          
        end
      end
    end
    
  end
  
  #Read the binary file data into array
  def read_file
    f = File.new(@file, "r")
    f.each_byte{|b| @buffer << b }
    f.close
    @x_dimension, @y_dimension, @z_dimension = @buffer.unpack('III') #THe first 3 int values are x, y, z dimensions
    @size = @x_dimension*@y_dimension*z_dimension
    @buffer = @buffer[0..@size-1] #Assuming unsigned char is 1 byte
  end
  
  def find_offsets(x, y, z)
    index = (x+ y*@x_dimension + z*@x_dimension*@y_dimension)
    @indices = []
    @indices[0] = index
  	@indices[1] = @indices[0] + 1
  	@indices[3] = @indices[0] + @x_dimension
  	@indices[2] = @indices[3] + 1
  	@indices[4] = @indices[0] + @x_dimension*@y_dimension
  	@indices[5] = @indices[4] + 1
  	@indices[7] = @indices[4] + @x_dimension
  	@indices[6] = @indices[7] + 1
  end
  
  #Compute mask(array of 0/1 based on iso_value and given lookup table)
  def compute_mask(temp_buffer)
    mask_bits = []
    (0..7).each{|i| mask_bits[i] = temp_buffer[@indices[i]] <= @iso_value ? 1 : 0 }
    mask_bits.reverse
  end
  
  #interpolate the scalar values and get the intersection point
  def interpolate_scalar(vector_a, vector_b, isovalue, first, second)
    point = {}
    @weight = (isovalue - first)/(second - first)
    vector_a.point.each{|key, val| point[key] = val + @weight*(vector_b.point[key]) - val }
    Vector.new(point)
  end
  
  #interpolate the normal vectors and get the normal vector at the intersected point
  def interpolate_normal(normal_a, normal_b, weight = @weight)
    point = {}
    magnitude = 0.0
    normal_a.point.each{|key, val| point[key] = val + weight*(normal_b.point[key] - val) }
    magnitude = Math.sqrt(point.values.inject(0){|sum, val| sum + (val**2)})
    point.each{|key, val| point[key] = val/magnitude }
    Vector.new(point)
  end
  
  #Given 8-bit mask, convert into a single 
  def to_decimal(bit_mask)
    value = 0.0
    bit_mask.each_with_index{|val, index| value += val*(2**index) }
    value.to_i
  end
  
  
end
