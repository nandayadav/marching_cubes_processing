require 'lib/vector'
require 'lib/data_point'
require 'lib/table_data'
require 'yaml'

class Computation
  attr_accessor :iso_value, :weight, :triangle_list
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
    @buffer = []  #Store actual 3D raw data 
    @vertex_a = Vector.new
    @vertex_b = Vector.new
    @triangle_list = [] #Array that stores DataPoint objects, each one representing triangles to be rendered
  end
  
  def self.test
    c = new({:iso_value => 30, :file => '/../data/brain.bin'})
    c.read_file
    c.main_loop
    c.triangle_list
    File.open('test.yml', 'w') do |f|  
      c.triangle_list.each_with_index do |t, i|
        hash_block = {}
        hash_block['normal'] = t.normal.point
        hash_block['vertex'] = t.vertex.point
        h = {"#{i}" => hash_block}
        f.puts h.to_yaml
      end
    end
  end
  
  def main_loop
    interpolated_vector = Vector.new
    interpolated_normal = Vector.new
    normal_a = Vector.new
    normal_b = Vector.new
    #Loop through the @buffer
    for k in 0..1#@z_dimension-1
      for j in 0..@y_dimension-1
        for i in 0..@x_dimension-1
          find_offsets(i, j, k)
          #puts "(#{i},#{j},#{k})"
          mask = compute_mask(@buffer)
          #puts "Mask: #{mask}"
          table_index = to_decimal(mask)
          #puts "table index: #{table_index}"
          side_counter = 0
          data_point = DataPoint.new(Vector.new, Vector.new)
          while(TableData::TRI_TABLE[table_index][side_counter] != -1)
  	        first, second = find_vertices(TableData::TRI_TABLE[table_index][side_counter], i, j, k)
  	        side_counter += 1 
  	        next if @buffer[first] == 0 && @buffer[second] == 0 || (@buffer[first] == @buffer[second])
      	    interpolated, weight = interpolate_scalar(@buffer[first], @buffer[second])
      	    #Set interpolated vector
      	    data_point.vertex = interpolated
      	    normal_a = compute_normal(first)
      	    normal_b = compute_normal(second)
      	    interpolated_normal = interpolate_normal(normal_a, normal_b, weight)
      	    data_point.normal = interpolated_normal
            #Add the triangle in the array
            puts "Adding triangle: "
            puts data_point.normal.inspect
            puts data_point.vertex.inspect
      	    @triangle_list << data_point
      	  end
        end
      end
    end
    
  end
  
  #Read the binary file data into array
  def read_file
    f = File.new(File.dirname(__FILE__) + @file, "r")
    temp_buffer = ''
    f.each{|b| temp_buffer << b}
    f.close
    @x_dimension, @y_dimension, @z_dimension = temp_buffer.unpack('III') #THe first 3 int values are x, y, z dimensions
    @size = @x_dimension*@y_dimension*@z_dimension
    temp_buffer.each_byte{|b| @buffer << b}
    @buffer = @buffer[12..@buffer.size-1]
    false
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
  def interpolate_scalar(first, second)
    point = {}
    weight = (@iso_value - first)/(second - first)
    @vertex_a.point.each{|key, val| point[key] = val + weight*(@vertex_b.point[key]) - val }
    return Vector.new(point), weight
  end
  
  #interpolate the normal vectors and get the normal vector at the intersected point
  def interpolate_normal(normal_a, normal_b, weight)
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
  
  def compute_normal(i)
  	temp_normal = {}
  	xy = @x_dimension*@y_dimension
  	if i % @x_dimension == 0									          #the left-most
  		temp_normal[:x] = @buffer[i + 1] - @buffer[i] 
  	elsif (i % @x_dimension) == (@x_dimension - 1)			#the right-most 
  		temp_normal[:x] = @buffer[i] - @buffer[i - 1] 
  	else													                      #in the midle
  		temp_normal[:x] = (@buffer[i + 1] - @buffer[i - 1]) / 2 
    end

  	if i % xy < @x_dimension							              #the inner-most
  		temp_normal[:y] = @buffer[i + @x_dimension] - @buffer[i]
  	elsif ((i + @x_dimension) % xy) < @x_dimension			#the outer-most
  		temp_normal[:y] = @buffer[i] - @buffer[i - @x_dimension]
  	else													                      #in the midle
  		temp_normal[:y] = (@buffer[i + @x_dimension] - @buffer[i - @x_dimension]) / 2
    end


  	if i < xy							                              #the bottom layer
  		temp_normal[:z] = @buffer[i + xy] - @buffer[i]
  	elsif i >= xy * (@z_dimension - 1)			            #the top layer
  		temp_normal[:z] = @buffer[i] - @buffer[i - xy]
  	else													                      #in the midle
  		temp_normal[:z] = (@buffer[i + xy] - @buffer[i - xy] ) / 2
    end
    temp_normal = Vector.new(temp_normal)
  	temp_normal.normalize
  end
  
  def find_vertices(lookup_val, x, y, z)
    puts "Lookup val: #{lookup_val}"
    puts "For POint: #{x}, #{y}, #{z}"
    mapping = TableData::MAPPINGS[lookup_val]
    vertices = {:x => x, :y => y, :z => z}
    vertices.each do |key, val|
      @vertex_a.point[key] = val + (mapping[0][key] || 0)
      @vertex_b.point[key] = val + (mapping[1][key] || 0)
    end
    mapping[2]
  end
  
  
  
end
