
xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title "#{@profile.f}'s Blog"
    xml.link SITE
    xml.description "#{@profile.f}'s Blog at #{SITE_NAME}"
    xml.language 'en-us'
    @videos.each do |video|
      xml.item do
        xml.title "Video"
        xml.description "<a href=\"#{profile_video_url(@profile, video)}\" title=\"#{video.caption}\" alt=\"#{video.caption}\" class=\"thickbox\" rel=\"user_gallery\">#{image video, :small}</a>" + video.caption
        xml.author "#{@profile.f}"
        xml.pubDate @profile.created_at
        xml.link profile_video_url(@profile, video)
        xml.guid profile_video_url(@profile, video)
      end
    end
  end
end
