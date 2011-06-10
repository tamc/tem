require_relative '../lib/tem'

def check_lp(model,tag)
  actual = File.join(File.dirname(__FILE__),'actual-lp',"#{tag}-actual.lp")
  target = File.join(File.dirname(__FILE__),'target-lp',"#{tag}-target.lp")
  model.problem.write_lp(actual)
  lp = IO.readlines(actual).join("\n")
  desired_lp = IO.readlines(target).join("\n")
  lp.should == desired_lp
end