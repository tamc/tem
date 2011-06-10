require_relative 'spec_helper'

describe Model do
  
  it "should work in a very simple case" do
    model = Model.new "Cars and spaces"
    model.variable "cars", 0
    model.constrain "spaces", nil, 100
    model.coefficient "cars", "spaces", 1
    model.maximise "length"
    model.setup_problem
    check_lp model, 'simple'
    model.solve_problem
    model.status.should == "solution is optimal"
    model.result.should == 400
  end
  
  it "should work in a slightly more complex case" do
    model = Model.new "Cars, buses and spaces"
    model.variable "cars", 0
    model.variable "buses", 0
    model.constrain "spaces", nil, 100
    model.coefficient "cars", "spaces", 1
    model.coefficient "buses", "spaces", 2    
    model.maximise "length"
    model.setup_problem
    check_lp model, 'slightly more complex'
    model.solve_problem
    model.status.should == "solution is optimal"
    model.result.should == 400
  end
  
  it "should allow a variety of bounds to be added" do
    model = Model.new
    model.variable "Variable 1"
    model.variable "Variable 2", 0
    model.variable "Variable 3", nil, 100
    model.variable "Variable 4", 0, 100
    model.constrain "Constraint 1"
    model.constrain "Constraint 2", 0
    model.constrain "Constraint 3", nil, 100
    model.constrain "Constraint 4", 0, 100
    model.coefficient "Variable 1", "Constraint 1", 10
    model.coefficient "Variable 1", "Constraint 2", 10
    model.coefficient "Variable 2", "Constraint 3", 10
    model.maximise "length"
    model.setup_problem
    check_lp model, 'variables1'
    model.solve_problem
    model.status.should == "problem has unbounded solution"
  end
end