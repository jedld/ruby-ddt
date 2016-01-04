module Pretentious
  # Generator for RSPEC
  class RspecGenerator < Pretentious::GeneratorBase
    def self.to_sym
      :spec
    end

    def begin_spec(test_class)
      buffer('# This file was automatically generated by the pretentious gem')
      buffer("require 'spec_helper'")
      whitespace
      buffer("RSpec.describe #{test_class.name} do")
    end

    def end_spec
      buffer('end')
    end

    def output
      @output_buffer
    end

    private

    def generate(test_instance, instance_count)
      output_buffer = ''
      if test_instance.is_a? Class
        context = Pretentious::Context.new(test_instance.let_variables)
        # class methods
        class_method_calls = test_instance.method_calls_by_method
        buffer_inline_to_string(output_buffer, generate_specs(0, context, "#{test_instance.test_class.name}::", test_instance.test_class.name,
                              class_method_calls))
      else
        buffer_to_string(output_buffer, "context 'Scenario #{instance_count}' do", 1)

        buffer_to_string(output_buffer, 'before do', 2)

        context, declarations = setup_fixture(test_instance)
        method_calls = test_instance.method_calls_by_method
        spec_context = context.subcontext(declarations[:declaration])
        specs_buffer = generate_specs(1, spec_context, "#{test_instance.test_class.name}#", "@fixture", method_calls)
        context.declared_names = {}
        deconstruct_output = @deconstructor.build_output(context, 3 * @_indentation.length, declarations)

        buffer_inline_to_string(output_buffer, deconstruct_output)
        buffer_to_string(output_buffer, 'end', 2)
        buffer_to_string(output_buffer, '')
        buffer_inline_to_string(output_buffer, specs_buffer)
        buffer_to_string(output_buffer, 'end', 1)
      end
      output_buffer
    end

    def proc_function_generator(block, method)
      "func_#{method}(#{Pretentious::Deconstructor.block_params_generator(block)})"
    end

    def get_block_source(context, block)
      " &#{context.pick_name(block.target_proc.object_id)}"
    end

    def generate_expectation(indentation_level, context, fixture, method, params, block, result)
      output = ''
      block_source = if !block.nil? && block.is_a?(Pretentious::RecordedProc)
                       get_block_source(context, block)
                     else
                       ''
                     end

      statement = if params.size > 0
                    "#{fixture}.#{prettify_method_name(method)}(#{params_generator(context, params)})#{block_source}"
                  else
                    stmt = []
                    stmt << "#{fixture}.#{method}"
                    stmt << "#{block_source}" unless block_source.empty?
                    stmt.join(' ')
                  end

      if result.is_a? Exception
        buffer_to_string(output, "expect { #{statement} }.to #{pick_matcher(context, result)}", indentation_level + 2)
      else
        buffer_to_string(output, "expect(#{statement}).to #{pick_matcher(context, result)}", indentation_level + 2)
      end
      output
    end

    def generate_specs(indentation_level, context, context_prefix, fixture, method_calls)
      output = ''
      buffer_to_string(output, "it 'should pass current expectations' do", indentation_level + 1)
      # collect all params
      params_collection = []
      mocks_collection = {}
      method_call_collection = []

      return if method_calls.nil?

      method_calls.each_key do |k|
        info_blocks_arr = method_calls[k]
        info_blocks_arr.each do |block|
          method_call_collection << block
          params_collection |= block[:params]
          if !Pretentious::Deconstructor.primitive?(block[:result]) && !block[:result].kind_of?(Exception)
            params_collection << block[:result]
          end

          params_collection << block[:block] unless block[:block].nil?

          next unless block[:context]
          block[:context][:calls].each do |mock_block|
            k = "#{mock_block[:class]}_#{mock_block[:method]}"

            mocks_collection[k] = [] if mocks_collection[k].nil?

            mocks_collection[k] << mock_block
            params_collection << mock_block[:result]
          end
        end
      end

      if params_collection.size > 0
        deps = declare_dependencies(context, params_collection, indentation_level + 2)
        buffer_inline_to_string(output, deps) if deps != ''
      end

      if mocks_collection.keys.size > 0
        buffer_to_string(output, generate_rspec_stub(context, mocks_collection,
                                                     (indentation_level + 2) * @_indentation.length))
      end

      expectations = []
      method_calls.each_key do |k|
        info_blocks_arr = method_calls[k]

        info_blocks_arr.each do |block|
          str = ''
          params_desc_str = if block[:params].size > 0
                              "when passed #{desc_params(block)}"
                            else
                              ''
                            end

          buffer_to_string(str, "# #{context_prefix}#{k} #{params_desc_str} should return #{context.value_of(block[:result])}", indentation_level + 2)
          buffer_inline_to_string(str, generate_expectation(indentation_level, context, fixture, k, block[:params], block[:block], block[:result]))
          expectations << str unless expectations.include? str
        end
      end
      buffer_inline_to_string(output, expectations.join("\n"))
      buffer_to_string(output, 'end', indentation_level + 1)
      output
    end

    def generate_rspec_stub(context, mocks_collection, indentation_level)
      indentation = ''

      indentation_level.times { indentation << ' ' }
      str = ''
      mocks_collection.each do |_k, values|
        vals = values.collect { |v| context.value_of(v[:result]) }

        # check if all vals are the same and just use one
        vals = [vals[0]] if vals.uniq.size == 1

        str << "#{indentation}allow_any_instance_of(#{values[0][:class]}).to receive(:#{values[0][:method]}).and_return(#{vals.join(', ')})\n"
      end
      str
    end

    def pick_matcher(context, result)
      if result.is_a? TrueClass
        'be true'
      elsif result.is_a? FalseClass
        'be false'
      elsif result.nil?
        'be_nil'
      elsif result.is_a? Exception
        'raise_error'
      elsif context.map_name result.object_id
        "eq(#{context.map_name(result.object_id)})"
      else
        "eq(#{Pretentious.value_ize(Pretentious::Context.new, result)})"
      end
    end

    def self.location(output_folder)
      output_folder.nil? ? 'spec' : File.join(output_folder, 'spec')
    end

    def self.naming(output_folder, klass)
      klass_name_parts = klass.name.split('::')
      last_part = klass_name_parts.pop
      File.join(output_folder, "#{Pretentious::DdtUtils.to_underscore(last_part)}_spec.rb")
    end

    def self.helper(output_folder)
      filename = File.join(output_folder, 'spec_helper.rb')
      unless File.exist?(filename)
        File.open(filename, 'w') { |f| f.write('# Place your requires here') }
        puts "#{filename}"
      end
    end
  end
end
