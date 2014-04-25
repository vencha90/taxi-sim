require 'plexus'

module TaxiLearner
  class Graph
    attr_reader :graph, :known_paths

    def initialize(matrix)
      @known_paths = {}
      initialize_graph(matrix)
    end

    def find_vertex_by_label(label)
      @graph.vertices.each do |vertex|
        return vertex if vertex.label.to_s == label.to_s
      end
      nil
    end

    def path_weight(start_label, finish_label)
      val = @known_paths[[start_label, finish_label]]
      return val unless val.nil?
      proc = Proc.new { |vertex| 0 }
      start_vertex = find_vertex_by_label(start_label)
      finish_vertex = find_vertex_by_label(finish_label)
      path = @graph.astar(start_vertex, finish_vertex, proc, {})
      weight = 0
      path.each.with_index do |vertex, index|
        break if index == path.length - 1
        next_vertex = path[index + 1]
        weight += @graph.edge_label(vertex, next_vertex)
      end
      @known_paths[[start_label, finish_label]] = weight
      weight
    end

    alias :distance :path_weight

    def random_vertex
      @graph.vertices.sample
    end

    def vertices
      @graph.vertices
    end

  private 
    def initialize_graph(matrix)
      matrix_length = matrix.length
      e = -> { raise ArgumentError, "bad matrix dimensions: #{matrix.to_s}" }
      e.call if matrix_length < 1
      @graph = Plexus::UndirectedGraph.new
      matrix.each.with_index do |row, row_index|
        e.call unless row.length == matrix_length
        row.each.with_index do |column, column_index|
          next if column == 0
          next if row_index == column_index #ignore self-loop
          start_vertex = find_or_create_vertex_by_label(row_index + 1)
          finish_vertex = find_or_create_vertex_by_label(column_index + 1)
          @graph.add_edge!(start_vertex, finish_vertex, column)
        end
      end
      raise ArgumentError, 'input matrix graph is not connected' unless graph.connected?
      @graph
    end

    def find_or_create_vertex_by_label(label)
      vertex = find_vertex_by_label(label.to_s)
      vertex ||= TaxiLearner::Graph::Vertex.new(label.to_s)
      vertex
    end
  end
end
