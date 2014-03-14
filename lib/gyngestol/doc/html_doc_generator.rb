module Gyngestol
  module Doc
    class HTMLDocGenerator < DocGenerator
      def generate(cls)
        doc = ""

        doc << render_toc(cls.method_annotations)
        doc << render_actions(cls.method_annotations)

        doc = document_wrapper("Api Documentation", doc)

        doc
      end

    private

      def document_wrapper(title, content)
        aligned_text <<-HTML
        |<html>
        |<head>
        |  <title>#{title}</title>
        |</head>
        |<body>
        |  <h1>#{title}</h1>
        |  #{content}
        |</body>
        |</html>
        HTML
      end

      def render_toc(actions)
        toc = "<ul>"
        actions.each do |method_name, annotations|
          toc << %{<li><a href="##{method_name}">#{method_name}</a></li>\n}
        end
        toc << '</ul>'
        toc
      end

      def render_actions(actions)
        sections = ""

        actions.each do |method_name, annotations|

          desc = annotations[:documentation].first
          verb, url = annotations[:action].first.shift

          sections << aligned_text(<<-HTML
            |<h2><a name="#{method_name}" />
            |  Action:
            |  <span class="code">#{verb.to_s.upcase} #{url}</span>
            |  (<span class="code">#{method_name}</span>)
            |</h2>
            |<p>#{desc}</p>
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
