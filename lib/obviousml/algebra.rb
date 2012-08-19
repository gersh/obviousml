module Algebra
  @standard_operators = [:+,:-,:*,:/]
  @operator_derivative={}
  def self.standard_operators()
    @standard_operators
  end
  def self.operator_derivative()
    @operator_derivative
  end
  def self.add_operator_derivative(operator,&block)
    @operator_derivative[[operator,block.arity-2]]=block
  end
  
  # The base class of our objects composed from a GenericObject
  class Object < Object
   def compute
    throw "Cannot compute basic object type"
   end
   def partial_d(wrt)
   end
   def variables()
   end
  end
  # Unbound variable
  class GenericObject < Object
    def initialize(name)
      @name=name
    end
    def compute
      yield @name
    end
    def partial_d(wrt)
      puts "Partial d" + wrt + "\n"
      if @name==wrt
        1
      else
        0
      end
    end
    def variables()
      [@name]
    end
    def to_s()
      @name.to_s
    end
  end
  # Some sort of composition with an unbound variable
  class FunctionalObject < Object
     def initialize(klass, meth,args,block)
        @klass=klass
        @meth=meth
        @args=args
        @block=block
      end
      def compute(&block)
        args=@args.map{|a|
          if a!=nil && a.is_a?(Algebra::Object)
            a.compute(&block)
          else
            a
          end
        }
        @klass.compute(&block).send(@meth, *args,&block)
      end
      def partial_d(wrt)
        if Algebra.operator_derivative.member?([@meth,@args.length])
          operator=Algebra.operator_derivative[[@meth,@args.length]]
          operator.call(wrt,@klass,@args[0])
        else
          throw "We do not know how to take the derivative with method " + @meth.to_s + " of length " + @args.length.to_s
        end
        
      end
      def variables()
        vs=@args.map{|a|a.variables}
        if @klass!=nil && @klass.is_a?(Algebra::Object)
          vs.inject(@klass.variables(),:+)
        else
          vs.inject([],:+)
        end
      end
      def to_s()
        "(#{@meth.to_s} " + @args.join(" ") + ")"
      end
      def method_missing(meth, *args, &block)
        Algebra::FunctionalObject.new(self,meth,args,block)
      end
  end
  # Allows using any type of class as a generic object, which can be manipulated algebraicly
  def self.add_class(klass)
    # We don't re-define this mutliple times
    if self.constants.include?(klass.name.to_sym)
      return
    end
    # Alter standard operators of the class so we it will correctly compute the operator with us
    # We will assume the operators commutative
    klass.class_eval do
      Algebra.standard_operators.each{|o|
        m=instance_method(o)
        define_method(o) do |*args,&block|
          if args.length == 1 && args[0].is_a?(Algebra::Object)
            Algebra::FunctionalObject.new(args[0],o,[self],block)
          else
            m.bind(self).(*args,&block)
          end
        end
      }
      define_method(:partial_d) do |wrt|
        0
      end
    end
    # Add the generic version of the class to our namespace so we can create a generic version of the object type
    our_klass=Class.new(GenericObject)
    our_klass.class_eval do
      klass.instance_methods.each{|m|
        if !Object.instance_methods.include?(m)
          define_method(m) do |*args, &block|
            Algebra::FunctionalObject.new(self,m,args,block)
          end
        end
       
      }
      define_method(:initialize) do |name|
        super(name)
        self
      end   
       
    end
    const_set(klass.name,our_klass)
  end
  add_operator_derivative(:+)  {|wrt,a,b|
    a.partial_d(wrt) + b.partial_d(wrt)
  }
  add_operator_derivative(:*)  {|wrt,a,b|
    a.partial_d(wrt) * b + a * b.partial_d(wrt)
  }
  add_operator_derivative(:**) {|wrt,a,b|
    b * (a.partial_d(wrt) ** (b-1))
  }
    
  
end

