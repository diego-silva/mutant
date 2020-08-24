# frozen_string_literal: true

module Mutant
  module AST
    # Given an AST, finds the sclass that directly(-ish) contains the provided
    # node.
    # This won't match arbitrarily complex structures - it only searches the
    # first level deep (no begins-in-begins, for example). This is in
    # keeping with mutant generally not supporting 'weird' syntax.
    # Descending into 'begin' nodes is supported because these are generated for
    # the one-line syntax class << self; def foo; end
    class FindMetaclassContaining
      include NodePredicates, Concord.new(:root, :target), Procto.call

      # index of sclass's body
      SCLASS_BODY_INDEX = 1

      # the list of node types whose children will be checked
      TRANSPARENT_NODE_TYPES = %i[begin].freeze

      private_constant(*constants(false))

      def call
        AST.find_last_path(root) do |cur_node|
          next unless n_sclass?(cur_node)

          metaclass_of?(cur_node)
        end.last
      end

    private

      def metaclass_of?(sclass)
        body = sclass.children.fetch(SCLASS_BODY_INDEX)
        body.equal?(target) || transparently_contains?(body)
      end

      def transparently_contains?(body)
        TRANSPARENT_NODE_TYPES.include?(body.type) &&
          include_exact?(body.children, target)
      end

      def include_exact?(haystack, needle)
        !haystack.index { |elem| elem.equal?(needle) }.nil?
      end
    end
  end
end
