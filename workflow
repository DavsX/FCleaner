#we need a mech instance -> cookie_jar should be persistent
#we need to log in, get profile id and registration date
#we need to do the actual cleaning
#the same mech instance needs to be used by all HTTP request, so we stay logged in
#first maybe do everything inside FCleaner::Profile class, then refactor it later

class FacebookHttpConnection
    URLS
    @mech
end

class Profile
    @email, @pass
    @id
    @reg_date
end

my_profile.comments_at(Date).each do |comment|
    comment.delete
end

my_profile.likes_at(Date).each do |like|
    like.unlike
end

module FCleaner
    class UnlikeableEntry
        def unlike; end
    end

    class DeletableEntry
        def delete; end
    end

    class HideableEntry
        def hide; end
    end
end
