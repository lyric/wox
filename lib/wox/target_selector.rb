module Wox
  class Selector
    def initialize(arg)
      @arg = arg
    end

    def to_s
      "#{prefix} '#{@arg}'"
    end
  end

  class TargetSelector < Selector
    def prefix
      "-target"
    end
  end

  class SchemeSelector < Selector
    def prefix
      "-scheme"
    end
  end

  class BuildTypeSelector < Selector
    def build_name
      File.basename(@arg, File.extname(@arg))
    end
  end

  class ProjectBuildSelector < BuildTypeSelector
    def prefix
      "-project"
    end
  end

  class WorkspaceBuildSelector < BuildTypeSelector
    def prefix
      "-workspace"
    end
  end
end
