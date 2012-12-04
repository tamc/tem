require_relative 'rglpk_wrapper'

class Model
  attr_accessor :items, :target, :problem, :columns, :rows, :coefficients
  
  def initialize(name = nil)
    @problem = Problem.new
    @problem.name = name if name
    @items = {}
    @columns = {}
    @rows = {}
    @coefficients = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = 0 } }
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
    matrix = Array.new
    number_of_columns = columns.size

    rows.each do |row_name, row|
      columns.each do |column_name, column|
        position_in_matrix = ((row.i-1) * number_of_columns) + column.j - 1
        matrix[position_in_matrix] = coefficients[row_name][column_name]
      end
    end

    problem.set_matrix(matrix)
  end
  
  def setup_objective_function
    return unless @target
    #p @items
    o = sorted_columns.map do |col|
      item = items[col.first] || col.first
      #p item
      item.respond_to?(@target) ? item.send(@target) : 0.0
    end
    # p o
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
