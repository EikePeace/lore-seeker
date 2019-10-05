class ExhSorter
  def initialize(ech)
    @ech = ech
  end

  def sort(results)
    results.sort_by do |c|
      [
        -c.num_exh_votes,
        @ech.legality(c).start_with?("banned"),
        @ech.legality(c).start_with?("restricted"),
        !c.commander?,
        c.release_date_i,
        .color_identity.size,
        c.default_sort_index
      ]
    end
  end

  def sort_order
    ["exh"]
  end

  def warnings
    []
  end

  def ==(other)
    other.is_a?(ExhSorter)
  end
end
