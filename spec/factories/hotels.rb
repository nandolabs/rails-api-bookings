FactoryBot.define do
  factory :hotel do
    name { Faker::Company.name + " Hotel" }
    location { "#{Faker::Address.city}, #{Faker::Address.state_abbr}" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price_per_night { Faker::Number.between(from: 50, to: 500) }
  end
end
