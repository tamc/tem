require_relative 'model'

class Item
  def name
    self.class.to_s.downcase
  end
  alias :to_s :name
end

class Fuel < Item
  def setup(model)
    # Energy can be converted, but not created or destroyed
    model.constrain name, 0, 0
    # Energy can enter the system, up to the limit of availability
    model.variable name, 0, available
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

