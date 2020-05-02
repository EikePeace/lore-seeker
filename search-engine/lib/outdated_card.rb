class OutdatedCard < UnknownCard
  attr_reader :set, :set_version

  def initialize(name, set, set_version)
    super(name)
    @set = set
    @set_version = set_version
  end

  def ==(other)
    other.is_a?(OutdatedCard) and name == other.name and set == other.set and set_version == other.set_version
  end

  def hash
    name.hash
  end

  def eql?(other)
    self == other
  end

  def inspect
    "OutdatedCard[#{@name}, #{@set.code}, #{@set_version}]"
  end
end
