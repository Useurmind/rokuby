#class SuperProxy
#  def initialize(obj)
#    @obj = obj
#  end
#
#  def method_missing(meth, *args, &blk)
#    @obj.class.superclass.instance_method(meth).bind(@obj).call(*args, &blk)
#  end
#end
#
#class Object
#  private  
#  def sup
#    puts "Creating superproxy"
#    SuperProxy.new(self)
#  end
#end