json.extract! profile, :id, :lastNameKana, :firstNameKana, :birthDay, :bloodType, :sex, :created_at, :updated_at
json.url profile_url(profile, format: :json)
