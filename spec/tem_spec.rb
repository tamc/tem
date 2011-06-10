require_relative 'spec_helper'
  
describe "A basic scenario" do
  it "should produce a sensible result" do
    model = Model.new "Home heating"
    model.add Person,ResistiveHeater,GasBoiler,Gas,Electricity
    model.minimise :cost
    model.setup_problem
    check_lp model, 'basic'
    model.solve_problem
    model.status.should == "solution is optimal"
    model.result.should == 4433.333333333333
  end
end