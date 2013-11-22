require 'json'
require 'math'

IMPORTANCE = [0, 1, 10, 50, 250]

# returns profile_a satisfaction with profile_b
def satisfaction (profile_a, profile_b)
  earned_points = 0
  possible_points = 0

  profile_a_answers = answer_dictionary(profile_a)
  profile_b_answers = answer_dictionary(profile_b)

  profile_a_answers.each do |question|
    # if profile_b answered the question
    if profile_b_answers[question]
      # calculate importance of question
      importance = IMPORTANCE[question['importance']]

      # increase possible points by the importance
      possible_points += importance

      # if profile_b's answered one of the acceptable answers
      if question['acceptableAnswers'].include? profile_b_answers[question].answer
        earned_points += importance
      end
    end
  end

  # return the float divison
  satisfaction = earned_points.fdiv(possible_points)
end

# creates a dictionary of answers with questionId as key
def answer_dictionary (profile)
  answers = {}
  profile['answers'].each do |answer|
    answers << {
      answer['questionId'] => answer
    }
  end
  answers
end

# returns top 10 matches by score
def top_10 (matches)
  matches.sort_by! { |match| match['score'] }.reverse[:10]
end

# returns all the profiles and their top 10 matches
def rank_matches (profiles)
  output = { results: [] }

  profiles.each do |profile|
    profile_result = {
      profileId: profile['id'],
      matches: []
    }

    matches = []

    profiles.each do |other_profile|
      # avoid evaluating profile against itself
      next if other_profile == profile

      # match percentage with OKCupid's formula
      match_score = Math.sqrt(
        satisfaction(profile, other_profile) *
        satisfaction(other_profile, profile)
      )

      # add the match to possible matches
      matches << {
        profileId: other_profile['id'],
        score: match_score
      }

      # add the top 10 matches to the profile
      profile_result['matches'] = top_10(matches)

      # add the results for the profile to the outp
      output['results'] << profile_result
    end
  end

  # return the output
  output
end

# read input json
profiles = JSON.parse(STDIN.read)

# rank the matches
matches = rank_matches(profiles)

# write output json
STDOUT.write matches
