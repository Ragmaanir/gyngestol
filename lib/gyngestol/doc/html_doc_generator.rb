module Gyngestol
  module Doc
    class HTMLDocGenerator < DocGenerator
      def generate(cls)
        doc = ""

        doc << render_toc(cls.method_annotations)
        doc << render_actions(cls.method_annotations)

        doc
      end

    private

      def render_toc(actions)
        toc = "<ul>"
        actions.each do |method_name, annotations|
          toc << %{<li><a href="##{method_name}">#{method_name}</a></li>\n}
        end
        toc
      end

      def render_actions(actions)
        sections = ""

        actions.each do |method_name, annotations|
          sections << aligned_text(<<-HTML
            |<h2>
            |  Action:
            |  <span class="code">#{annotations[:action].first}</span>
            |  (<span class="code">#{method_name}</span>)
            |</h2>
            |<p>#{annotations[:documentation].first}</p>
          HTML
          )
        end

        sections
      end

      def aligned_text(text)
        text.gsub(/^\s*\|/, '')
      end

    end
  end#Doc
end
