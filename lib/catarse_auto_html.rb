module CatarseAutoHtml
  AutoHtml.add_filter(:email_image).with(width: 200) do |text, options|
    text.gsub(/http(s)?:\/\/.+\.(jpg|jpeg|bmp|gif|png)(\?\S+)?/i) do |match|
      width = options[:width]
      %|<img src="#{match}" alt="" style="max-width:#{width}px" />|
    end
  end

  AutoHtml.add_filter(:line_space) do |text|
    text.gsub(/\r\n/) do |match|
      %|<br>|
    end
  end
  def catarse_auto_html_for options={}
    self.auto_html_for options[:field] do
      html_escape map: {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"' }
      image
      soundcloud target: :_blank
      youtube width: options[:video_width], height: options[:video_height], wmode: "opaque"
      vimeo width: options[:video_width], height: options[:video_height]
      #redcloth target: :_blank
      link target: :_blank
      line_space
    end
  end
end
