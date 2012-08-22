require 'helper'

class TestAlgebra < Test::Unit::TestCase
  should "be able to solve for the square root of 5" do
    x=Algebra::Fixnum.new("x")
    minEq=(x**2-5)**2
    s=Solver::GradientDescent.new(minEq)
    v=s.solve()
    if (v[0] -(5 ** 0.5).abs) > 0.001
      flunk "Square root of 5 is not " + v[0].to_s
    end
  end
end