require 'helper'

class TestAlgebra < Test::Unit::TestCase
  should "be able to compute an equation" do
    Algebra::add_class(Fixnum)
    num1=Algebra::Fixnum.new("num1")
    num2=Algebra::Fixnum.new("num2")
    combo=num1 + num2
    s=combo.compute{|e|
      if e == "num1"
        3
      elsif e == "num2"
        5
      else
        flunk "Fixnum did not try to get a valid name"
      end
    }
    if s!=8
      flunk "Eval doesn't work: " + s.to_s  + "!=8"
    end
  end
  should "be able to add a num and a constant" do
    Algebra::add_class(Fixnum)
    num=Algebra::Fixnum.new("num")
    num + 3
  end
  should "be able to add complex things to fixed numbers" do
    Algebra::add_class(Fixnum)
    num1=Algebra::Fixnum.new("num1")
    num2=Algebra::Fixnum.new("num2")
    combo=num1 + num2
    combo + 3
    s=combo.compute {|e|
      if e == "num1"
        3
      elsif e == "num2"
        5
      else
        flunk "Fixnum did not try to get a valid name"
      end
    }
  end
  should "be able to take the derivative" do
    Algebra::add_class(Fixnum)
    x=Algebra::Fixnum.new("x")
    f=x*2
    d=f.partial_d("x")
    r=d.compute {|e|
      if e == "x"
        2
      else
        flunk "Bad variable showing up in function"
      end
    }
    if r!=2
      flunk "It calculates the derivative of 2*x as " + r.to_s
    end
  end
  should "take the derivative of (x**3)" do
    Algebra::add_class(Fixnum)
    x=Algebra::Fixnum.new("x")
    f=x**3
    d=f.partial_d("x")
    r=d.compute{|e|
      if e == "x"
        2
      else
        flunk "Bad variable showing up in function"
      end
    }
    if r!=12
      flunk "It calculates the derivative of x**3 at 3 as " + r.to_s
    end
  end
end
