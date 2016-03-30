module StringMarkdown
  refine String do
    def markdown_escape
      self.gsub(/([`<>])/, '\\\\\1')
    end

    def markdown_html_url
      self =~ /^\* \[.+\]\((.+)\)/
      $1
    end
  end
end
