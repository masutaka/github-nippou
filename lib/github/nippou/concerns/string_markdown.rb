# frozen_string_literal: true

module StringMarkdown
  refine String do
    def markdown_escape
      self.gsub(/([`<>])/, '\\\\\1')
    end
  end
end
