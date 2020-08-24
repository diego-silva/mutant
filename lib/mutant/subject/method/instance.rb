# frozen_string_literal: true

module Mutant
  class Subject
    class Method
      # Instance method subjects
      class Instance < self

        NAME_INDEX = 0
        SYMBOL     = '#'

        # Prepare subject for mutation insertion
        #
        # @return [self]
        def prepare
          warnings.call do
            scope.public_send(:undef_method, name)
          end
          self
        end

        # Mutator for memoizable memoized instance methods
        class Memoized < self
          include AST::Sexp

          # Prepare subject for mutation insertion
          #
          # @return [self]
          def prepare
            scope.__send__(:memoized_methods).instance_variable_get(:@memory).delete(name)
            super()
          end

        private

          def wrap_node(mutant)
            s(:begin, mutant, s(:send, nil, :memoize, s(:args, s(:sym, name))))
          end

        end # Memoized
      end # Instance
    end # Method
  end # Subject
end # Mutant
