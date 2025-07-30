# frozen_string_literal: true

class SimpleInlineTextAnnotation
  class EntityTypeCollection
    def initialize(source)
      @source = source
    end

    # get returns the entity type id for a given label.
    # Example:
    #   get("Person") => "https://example.com/Person"
    #
    # If the label is not found, it returns nil.
    # Example:
    #   get("NonExistentLabel") => nil
    def get(label)
      entity_types[label]
    end

    # to_config returns a Array of hashes of each entity type.
    # Example:
    #   [
    #     {"id" => "https://example.com/Person", "label" => "Person"},
    #     {"id" => "https://example.com/Organization", "label" => "Organization"}
    #   ]
    def to_config
      entity_types.map do |label, id|
        { "id" => id, "label" => label }
      end
    end

    def any?
      entity_types.any?
    end

    private

    # entity_types returns a Hash structured with label as key and id as value.
    # Example:
    #   {
    #     "Person": "https://example.com/Person",
    #     "Organization": "https://example.com/Organization"
    #   }
    def entity_types
      @entity_types ||= read_entities_from_source
    end

    def read_entities_from_source
      entity_types = {}

      @source.scan(ENTITY_TYPE_BLOCK_PATTERN).each do |entity_block|
        process_entity_block(entity_block, entity_types)
      end

      entity_types
    end

    def process_entity_block(entity_block, entity_types)
      entity_block[0].each_line do |line|
        process_entity_line(line, entity_types)
      end
    end

    def process_entity_line(line, entity_types)
      match = line.strip.match(ENTITY_TYPE_PATTERN)
      return unless match

      label = match[1]
      id = match[2]
      return if label == id # Do not create entity_type if label and id is same.

      entity_types[label] ||= id
    end
  end
end
