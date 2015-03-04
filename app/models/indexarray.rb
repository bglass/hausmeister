class IndexArray
  include Enumerable

  def initialize(indices)
    @index = indices
  end

  # (block.class)
  def each(&block)
    @index.each do |index|
      block.call(Index.new(index))
    end
  end

  # (block.class)
  def map(&block)
    @index.map do |index|
      block.call(Index.new(index))
    end
  end

  # Index
  def first
    Index.new(@index.first)
  end

  # Index
  def [](k)
    if k < @index.length and k > -1
      Index.new(@index[k])
    else
      nil
    end
  end

  # Fixnum
  def length
    @index.length
  end

end
