module RakeBuilder
  module UnitTests
  
    def TestPred(v1, v2, message)
      succ = yield v1, v2
      result = succ ? "success" : "failed"
      puts "Testing...\n" + message + "\n:" + result
      puts
      if(!succ)
        fail "Test failed!\n"
      end
    end
    
    def TestEqual(actual, exptected)
      TestPred(actual, exptected, "#{actual.to_s} == #{exptected.to_s}") do |v1, v2|
        v1 == v2
      end
    end
    
    def TestNotEqual(actual, exptected)
      TestPred(actual, exptected, "#{actual.to_s} 1= #{exptected.to_s}") do |v1, v2|
        v1 != v2
      end
    end
    
    def TestTrue(actual)
      TestEqual(actual, true)
    end
    
    def TestFalse(actual)
      TestEqual(actual, false)
    end
  
  end
end

