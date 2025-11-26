FactoryBot.define do
  factory :booking do
    association :user
    association :hotel
    check_in { Date.today + 7.days }
    check_out { Date.today + 10.days }
    guests { Faker::Number.between(from: 1, to: 4) }
    status { 'pending' }
  end
end
