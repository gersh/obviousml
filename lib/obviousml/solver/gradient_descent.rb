module Solver
  # Apply good old naive gradient descent
	class GradientDescent
    
    # Start a new gradient descent solver to minimize something
    # @param equation The equation we are minimizing 
    # @param initial A hash of initial values for the variables. If this isn't specified we will set all the values initially to 0
	  def initialize(equation, initial=nil)
      @equation=equation
      @variables=equation.variables()
      @ds=[]
      n=0
      @variable_position={}
      @variables.each{|v|
        @ds[n]=@equation.partial_d(v)
        @variable_position[@variables[n]]=n
        puts "Variable " + @variables[n] + " is in position " + n.to_s
        
        n+=1
      }
      if initial==nil
        @vars=[]
        (0..(@variables.length-1)).each{|n|
          @vars.push(0)
        }
      else
        @vars=initial
      end
    end
    def solve(learning_rate=0.5)
      compute_gradients()
      
      begin
        iterate(learning_rate)
        compute_gradients()
        n=gradient_norm()
        val=@equation.compute{|name|
          @vars[@variable_position[name]]
        }
      end  while(n.abs > 1e-10)
      @vars
    end
    private
    def gradient_norm()
      n=@gradients.map{|g| g*g}.inject(0){|sum,x|sum+x}
      n*n
    end
    def compute_gradients()
      @gradients=@ds.map{|d|
        d.compute {|name|
          
          @vars[@variable_position[name]]
        }
      }
    end
    def iterate(learning_rate)
      n=0
      @variables.each{|v|
        @vars[n] -= learning_rate*@gradients[n]
        n=n+1
      }
      
    end
	end
end