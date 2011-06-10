require_relative 'rglpk_wrapper'

class Model
  attr_accessor :items, :target, :problem, :columns, :rows, :coefficients
  
  def initialize(name = nil)
    @problem = Problem.new
    @problem.name = name if name
    @items = {}
    @columns = {}
    @rows = {}
    @coefficients = {}
  end
  
  def add(*new_items)
    new_items.each do |new_item|
      i = new_item.new
      items[i.to_s] = i
    end
  end
  
  def minimise(target)
    @target = target
    problem.obj.dir = Rglpk::GLP_MIN
  end

  def maximise(target)
    @target = target
    problem.obj.dir = Rglpk::GLP_MAX
  end
  
  def setup_problem
    setup_items
    setup_coefficients
    setup_objective_function
  end
  
  def setup_items
    items.each do |id,item|
      item.setup(self) if item.respond_to?(:setup)
    end
  end
  
  def sorted_columns
    @columns.sort_by { |k,v| v.j }
  end
  
  def sorted_rows
    @rows.sort_by { |k,v| v.i }
  end
  
  def setup_coefficients 
    c = sorted_rows.map do |row|
      puts "Can't find constraint #{row.first} in #{coefficients.keys.inspect}" unless coefficients.has_key?(row.first)
      r = coefficients[row.first] || {}
      sorted_columns.map do |col|
        #puts "Can't find variable #{col.first} in #{r.keys.inspect}" unless r.has_key?(col.first)
        r[col.first] || 0.0
      end
    end
    problem.set_matrix(c.flatten)
  end
  
  def setup_objective_function
    return unless @target
    #p @items
    o = sorted_columns.map do |col|
      item = items[col.first] || col.first
      #p item
      item.respond_to?(@target) ? item.send(@target) : 0.0
    end
    p o
    problem.obj.coefs = o
  end
  
  def variable(id,low = nil,high = nil)
    columns[id] = problem.add_col
    columns[id].name = id
    columns[id].set_bounds *bound(low, high)
  end
  
  def constrain(id,low = nil,high = nil)
    rows[id] = problem.add_row
    rows[id].name = id
    rows[id].set_bounds *bound(low,high)
  end
  
  def coefficient(column_id, row_id, value)
    @coefficients[row_id] ||= {}
    @coefficients[row_id][column_id] = value
  end
    
  def bound(low,high)
    constraint = 
    if low && high && (low == high)
      Rglpk::GLP_FX
    elsif low && high
      Rglpk::GLP_DB
    elsif low
      Rglpk::GLP_LO
    elsif high
      Rglpk::GLP_UP
    else
      Rglpk::GLP_FR
    end
    [constraint,low,high]
  end
    
  def solve_problem
    @problem.simplex
  end
  
  def result
    @problem.obj.get
  end
  
  def status
    @problem.status
  end
  
end

class Item
  def name
    self.class.to_s.downcase
  end
  alias :to_s :name
end

class Fuel < Item
  def setup(model)
    model.variable name, 0, available
    model.constrain name, 0, 0
    model.coefficient name, name, 1.0
  end
end

class Electricity < Fuel
  def available
    100
  end
  
  def cost
    10
  end
end

class Gas < Fuel
  def available
    10000
  end
  
  def cost
    10
  end
end

class Demand < Item
  def setup(model)
   (self.methods - Demand.new.methods).each do |method|
     fixed_value = self.send(method)
     model.constrain method.to_s, fixed_value, fixed_value
    end
  end
end

class Person < Demand
  def heat
    300
  end
end

class Technology < Item
  def setup(model)
    model.variable name, 0
    model.coefficient name, from, -1.0
    model.coefficient name, to, efficiency
  end
end

class Heater < Technology
  def to
    "heat"
  end
end

class GasBoiler < Heater
  def from
    "gas"
  end
    
  def efficiency
    0.9
  end
  
  def cost
    5
  end
end

class ResistiveHeater < Heater
  def from
    "electricity"
  end
  
  def efficiency
    1.0
  end
  
  def cost
    1
  end
end

