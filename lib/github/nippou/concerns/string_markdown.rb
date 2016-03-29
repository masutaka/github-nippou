module StringMarkdown
  refine String do
    def markdown_escape
      self.gsub(/([`<>])/, '\\\\\1')
    end

    def html_url_as_nippou
      self =~ /^\* \[.+\]\((.+)\)/
      $1
    end
  end
end
