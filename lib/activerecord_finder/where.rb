module ActiveRecordFinder
  module Where
    def restrict(finder = nil, &block)
      raise ArgumentError, 'wrong number of arguments (0 for 1)' if block.nil? && finder.nil?
      if block
        where(create_finder(&block).arel)
      else
        where(finder.arel)
      end
    end
    alias :condition :restrict

    def new_finder(&block)
      finder = create_finder(&block)
      scoped_where = scoped.arel.where_clauses.map { |w| Arel.sql(w) }
      arel = Arel::Nodes::And.new([*scoped_where, finder.arel])
      ActiveRecordFinder::Finder.new(arel_table, arel)
    end

    def create_finder(&block)
      activerecord_finder = ActiveRecordFinder::Finder.new(arel_table)
      if block.arity == 1
        block.call(activerecord_finder)
      else
        activerecord_finder.instance_eval(&block)
      end
    end
    private :create_finder
  end
end
