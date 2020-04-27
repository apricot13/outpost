module ApplicationHelper

    def map(lat, long)
        "<div class='map-holder' data-map='true' data-lat=#{lat} data-long=#{long}></div>".html_safe
    end

    def static_map(lat, long)
        image_tag "https://maps.googleapis.com/maps/api/staticmap?key=#{ENV['GOOGLE_CLIENT_KEY']}&size=550x350&markers=#{lat},#{long}", alt: ""
    end

    def short_url(url)
        url
          .delete_prefix("https://")
          .delete_prefix("http://")
          .delete_prefix("www.")
          .delete_suffix("/")
          .truncate(25)
    end

    def diff(one, two)
        Diffy::Diff.new(one, two).to_s(:html).html_safe
    end

    def pretty_event(event)
        case event
        when "create"
            "record created"
        when "update"
            "updated"
        when "destroy"
            "deleted"        
        when "restore"
            "restored from history"
        when "archive"
            "archived"
        when "unarchive"
            "removed from archive"
        when "import"
            "record imported"
        when "approve"
            "approved"
        end
    end

    def stepper_class(event)
        case event
        when "create"
            "stepper__step--solid"   
        when "archive"
            "stepper__step--cross"
        when "restore"
            "stepper__step--solid"
        when "import"
            "stepper__step--solid"
        when "approve"
            "stepper__step--tick"
        end
    end

    def last_seen_helper(value)
        if value    
            [time_ago_in_words(value).humanize, "ago"].join(" ")
        else
            "Never"
        end
    end

    def status_tag(status)
        if status === "pending"
            "<span class='tag tag--yellow'>Pending</span".html_safe
        elsif status === "archived"
            "<span class='tag tag--grey'>Archived</span".html_safe
        elsif status === "scheduled"
            "<span class='tag tag--grey'>Scheduled</span".html_safe
        elsif status === "hidden"
            "<span class='tag tag--grey'>Hidden</span".html_safe
        else
            "<span class='tag'>Active</span".html_safe
        end
    end

end
