require 'rglpk'

class Problem < Rglpk::Problem
  PROBLEM_STATUS = {
    Rglpk::GLP_OPT => "solution is optimal", 
    Rglpk::GLP_FEAS => "solution is feasible", 
    Rglpk::GLP_INFEAS => "solution is infeasible", 
    Rglpk::GLP_NOFEAS => "problem has no feasible solution",
    Rglpk::GLP_UNBND => "problem has unbounded solution",
    Rglpk::GLP_UNDEF => "solution is undefined"
  }
  
  def status
    PROBLEM_STATUS[super]
  end
  
end