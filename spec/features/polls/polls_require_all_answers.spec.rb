require 'rails_helper'

feature 'Polls' do

  context "Concerns" do
    it_behaves_like 'notifiable in-app', Poll
  end
  
  
  context 'Show without require all answers' do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }

    before do
      Setting['feature.poll.require_all_answers'] = false              
    end

    after do
      Setting['feature.poll.require_all_answers'] = true        
    end

    scenario 'Show answers with videos' do
      question = create(:poll_question, poll: poll)
      answer = create(:poll_question_answer, question: question, title: 'Chewbacca')
      video = create(:poll_answer_video, answer: answer, title: "Awesome project video", url: "https://www.youtube.com/watch?v=123")

      visit poll_path(poll)

      expect(page).to have_link("Awesome project video", href: "https://www.youtube.com/watch?v=123")
    end

    scenario 'Lists questions from proposals as well as regular ones' do
      normal_question = create(:poll_question, poll: poll)
      proposal_question = create(:poll_question, poll: poll, proposal: create(:proposal))

      visit poll_path(poll)
      expect(page).to have_content(poll.name)
      expect(page).to have_content(poll.summary)
      expect(page).to have_content(poll.description)

      expect(page).to have_content(normal_question.title)
      expect(page).to have_content(proposal_question.title)
    end

    scenario "Question answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: 'First', question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: 'Second', question: question, given_order: 1)

      visit poll_path(poll)

      within("div#poll_question_#{question.id}") do
        expect(page.body.index(answer1.title)).to be < page.body.index(answer2.title)
      end
    end

    scenario "More info answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: 'First', question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: 'Second', question: question, given_order: 1)

      visit poll_path(poll)

      within('div.poll-more-info-answers') do
        expect(page.body.index(answer1.title)).to be < page.body.index(answer2.title)
      end
    end

    scenario 'Non-logged in users' do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      visit poll_path(poll)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must Sign in or Sign up to participate')

      expect(page).not_to have_link('Han Solo')
      expect(page).not_to have_link('Chewbacca')
    end

    scenario 'Level 1 users' do
      visit polls_path
      expect(page).not_to have_selector('.already-answer')

      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      login_as(create(:user, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_content('You must verify your account in order to answer')

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')

      expect(page).not_to have_link('Han Solo')
      expect(page).not_to have_link('Chewbacca')
    end

    scenario 'Level 2 users in an incoming poll' do
      incoming_poll = create(:poll, :incoming, geozone_restricted: true)
      incoming_poll.geozones << geozone

      question = create(:poll_question, poll: incoming_poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Rey')
      answer2 = create(:poll_question_answer, question: question, title: 'Finn')

      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(incoming_poll)

      expect(page).to have_content('Rey')
      expect(page).to have_content('Finn')
      expect(page).not_to have_link('Rey')
      expect(page).not_to have_link('Finn')

      expect(page).to have_content('This poll has not yet started')
    end

    scenario 'Level 2 users in an expired poll' do
      expired_poll = create(:poll, :expired, geozone_restricted: true)
      expired_poll.geozones << geozone

      question = create(:poll_question, poll: expired_poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Luke')
      answer2 = create(:poll_question_answer, question: question, title: 'Leia')

      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(expired_poll)

      expect(page).to have_content('Luke')
      expect(page).to have_content('Leia')
      expect(page).not_to have_link('Luke')
      expect(page).not_to have_link('Leia')

      expect(page).to have_content('This poll has finished')
    end

    scenario 'Level 2 users in a poll with questions for a geozone which is not theirs' do
      poll.update(geozone_restricted: true)
      poll.geozones << create(:geozone)

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Vader')
      answer2 = create(:poll_question_answer, question: question, title: 'Palpatine')

      login_as(create(:user, :level_two))

      visit poll_path(poll)

      expect(page).to have_content('Vader')
      expect(page).to have_content('Palpatine')
      expect(page).not_to have_link('Vader')
      expect(page).not_to have_link('Palpatine')
    end

    scenario 'Level 2 users reading a same-geozone poll' do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      login_as(create(:user, :level_two, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users reading a all-geozones poll' do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      login_as(create(:user, :level_two))
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users who have already answered' do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')
      user = create(:user, :level_two)
      create(:poll_answer, question: question, author: user, answer: 'Chewbacca')

      login_as user
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users answering', :js do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)
      expect(page).to have_css("button", text: 'Send', count: 0)
      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users changing answer', :js do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)

      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')

      click_link 'Chewbacca'

      expect(page).not_to have_link('Chewbacca')
      expect(page).to have_link('Han Solo')
    end

    scenario 'Level 2 votes, signs out, signs in, votes again', :js do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)
      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')

      click_link "Sign out"
      login_as user
      visit poll_path(poll)
      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')

      click_link "Sign out"
      login_as user
      visit poll_path(poll)
      click_link 'Chewbacca'

      expect(page).not_to have_link('Chewbacca')
      expect(page).to have_link('Han Solo')
    end
  end


  context 'Booth & Website with require all answers set' do

    let(:poll) { create(:poll, summary: "Summary", description: "Description", starts_at: '2017-12-01', ends_at: '2018-02-01') }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }

    before do
      allow(Date).to receive(:current).and_return Date.new(2018,1,1)
      allow(Date).to receive(:today).and_return Date.new(2018,1,1)
      allow(Time).to receive(:current).and_return Time.zone.parse("2018-01-01 12:00:00")
      Setting['feature.poll.require_all_answers'] = true              
    end

    after do
      Setting['feature.poll.require_all_answers'] = false        
    end

    scenario 'Already voted on booth cannot vote on website', :js do

      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment, date: Date.current)
      question = create(:poll_question, poll: poll)
      create(:poll_question_answer, question: question, title: 'Han Solo')
      create(:poll_question_answer, question: question, title: 'Chewbacca')
      user = create(:user, :level_two, :in_census)

      login_as(officer.user)
      visit new_officing_residence_path
      officing_verify_residence
      click_button "Confirm vote"

      expect(page).to have_content "Vote introduced!"

      visit new_officing_residence_path
      click_link "Sign out"
      login_as user
      visit poll_path(poll)


      expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
      expect(page).to have_css("button", text: 'Send', count: 0)
      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_content('Han Solo')
        expect(page).to have_content('Chewbacca')

        expect(page).not_to have_link('Han Solo')
        expect(page).not_to have_link('Chewbacca')
      end
    end

  end

context 'Show with require all answers' do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }

    before do
      Setting['feature.poll.require_all_answers'] = true              
    end

    after do
      Setting['feature.poll.require_all_answers'] = false        
    end

    scenario 'Show answers with videos' do
      question = create(:poll_question, poll: poll)
      answer = create(:poll_question_answer, question: question, title: 'Chewbacca')
      video = create(:poll_answer_video, answer: answer, title: "Awesome project video", url: "https://www.youtube.com/watch?v=123")

      visit poll_path(poll)

      expect(page).to have_link("Awesome project video", href: "https://www.youtube.com/watch?v=123")
    end

    scenario 'Lists questions from proposals as well as regular ones' do
      normal_question = create(:poll_question, poll: poll)
      proposal_question = create(:poll_question, poll: poll, proposal: create(:proposal))

      visit poll_path(poll)
      expect(page).to have_content(poll.name)
      expect(page).to have_content(poll.summary)
      expect(page).to have_content(poll.description)

      expect(page).to have_content(normal_question.title)
      expect(page).to have_content(proposal_question.title)
    end

    scenario "Question answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: 'First', question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: 'Second', question: question, given_order: 1)

      visit poll_path(poll)

      within("div#poll_question_#{question.id}") do
        expect(page.body.index(answer1.title)).to be < page.body.index(answer2.title)
      end
    end

    scenario "More info answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: 'First', question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: 'Second', question: question, given_order: 1)

      visit poll_path(poll)

      within('div.poll-more-info-answers') do
        expect(page.body.index(answer1.title)).to be < page.body.index(answer2.title)
      end
    end

    scenario 'Non-logged in users' do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      visit poll_path(poll)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must Sign in or Sign up to participate')

      expect(page).not_to have_link('Han Solo')
      expect(page).not_to have_link('Chewbacca')
    end

    scenario 'Level 1 users' do
      visit polls_path
      expect(page).not_to have_selector('.already-answer')

      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      login_as(create(:user, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_content('You must verify your account in order to answer')

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')

      expect(page).not_to have_link('Han Solo')
      expect(page).not_to have_link('Chewbacca')
    end

    scenario 'Level 2 users in an incoming poll' do
      incoming_poll = create(:poll, :incoming, geozone_restricted: true)
      incoming_poll.geozones << geozone

      question = create(:poll_question, poll: incoming_poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Rey')
      answer2 = create(:poll_question_answer, question: question, title: 'Finn')

      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(incoming_poll)

      expect(page).to have_content('Rey')
      expect(page).to have_content('Finn')
      expect(page).not_to have_link('Rey')
      expect(page).not_to have_link('Finn')

      expect(page).to have_content('This poll has not yet started')
    end

    scenario 'Level 2 users in an expired poll' do
      expired_poll = create(:poll, :expired, geozone_restricted: true)
      expired_poll.geozones << geozone

      question = create(:poll_question, poll: expired_poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Luke')
      answer2 = create(:poll_question_answer, question: question, title: 'Leia')

      login_as(create(:user, :level_two, geozone: geozone))

      visit poll_path(expired_poll)

      expect(page).to have_content('Luke')
      expect(page).to have_content('Leia')
      expect(page).not_to have_link('Luke')
      expect(page).not_to have_link('Leia')

      expect(page).to have_content('This poll has finished')
    end

    scenario 'Level 2 users in a poll with questions for a geozone which is not theirs' do
      poll.update(geozone_restricted: true)
      poll.geozones << create(:geozone)

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Vader')
      answer2 = create(:poll_question_answer, question: question, title: 'Palpatine')

      login_as(create(:user, :level_two))

      visit poll_path(poll)

      expect(page).to have_content('Vader')
      expect(page).to have_content('Palpatine')
      expect(page).not_to have_link('Vader')
      expect(page).not_to have_link('Palpatine')
    end

    scenario 'Level 2 users reading a same-geozone poll' do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      login_as(create(:user, :level_two, geozone: geozone))
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users reading a all-geozones poll' do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      login_as(create(:user, :level_two))
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users who have already answered' do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')
      user = create(:user, :level_two)
      create(:poll_answer, question: question, author: user, answer: 'Chewbacca')

      login_as user
      visit poll_path(poll)

      expect(page).to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users answering', :js do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)
      expect(page).to have_css("button", text: 'Send', count: 0)
      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')
    end

    scenario 'Level 2 users changing answer', :js do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)

      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')

      click_link 'Chewbacca'

      expect(page).not_to have_link('Chewbacca')
      expect(page).to have_link('Han Solo')
    end

    scenario 'Level 2 votes, signs out, signs in, votes again', :js do
      poll.update(geozone_restricted: true)
      poll.geozones << geozone

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit poll_path(poll)
      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')

      click_link "Sign out"
      login_as user
      visit poll_path(poll)
      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')
      expect(page).to have_link('Chewbacca')

      click_link "Sign out"
      login_as user
      visit poll_path(poll)
      click_link 'Chewbacca'

      expect(page).not_to have_link('Chewbacca')
      expect(page).to have_link('Han Solo')
    end
  end


  context 'Booth & Website with require all answers set' do

    let(:poll) { create(:poll, summary: "Summary", description: "Description", starts_at: '2017-12-01', ends_at: '2018-02-01') }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }

    before do
      allow(Date).to receive(:current).and_return Date.new(2018,1,1)
      allow(Date).to receive(:today).and_return Date.new(2018,1,1)
      allow(Time).to receive(:current).and_return Time.zone.parse("2018-01-01 12:00:00")
      Setting['feature.poll.require_all_answers'] = true              
    end

    after do
      Setting['feature.poll.require_all_answers'] = false        
    end

    scenario 'Already voted on booth cannot vote on website', :js do

      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment, date: Date.current)
      question = create(:poll_question, poll: poll)
      create(:poll_question_answer, question: question, title: 'Han Solo')
      create(:poll_question_answer, question: question, title: 'Chewbacca')
      user = create(:user, :level_two, :in_census)

      login_as(officer.user)
      visit new_officing_residence_path
      officing_verify_residence
      click_button "Confirm vote"

      expect(page).to have_content "Vote introduced!"

      visit new_officing_residence_path
      click_link "Sign out"
      login_as user
      visit poll_path(poll)


      expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
      expect(page).to have_css("button", text: 'Send', count: 0)
      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_content('Han Solo')
        expect(page).to have_content('Chewbacca')

        expect(page).not_to have_link('Han Solo')
        expect(page).not_to have_link('Chewbacca')
      end
    end

  end

context 'Booth & Website with require all answers not set' do

    let(:poll) { create(:poll, summary: "Summary", description: "Description", starts_at: '2017-12-01', ends_at: '2018-02-01') }
    let(:booth) { create(:poll_booth) }
    let(:officer) { create(:poll_officer) }

    before do
      allow(Date).to receive(:current).and_return Date.new(2018,1,1)
      allow(Date).to receive(:today).and_return Date.new(2018,1,1)
      allow(Time).to receive(:current).and_return Time.zone.parse("2018-01-01 12:00:00")
      Setting['feature.poll.require_all_answers'] = false              
    end

    after do
      Setting['feature.poll.require_all_answers'] = true        
    end

    scenario 'Already voted on booth cannot vote on website', :js do

      create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment, date: Date.current)
      question = create(:poll_question, poll: poll)
      create(:poll_question_answer, question: question, title: 'Han Solo')
      create(:poll_question_answer, question: question, title: 'Chewbacca')
      user = create(:user, :level_two, :in_census)

      login_as(officer.user)
      visit new_officing_residence_path
      officing_verify_residence
      click_button "Confirm vote"

      expect(page).to have_content "Vote introduced!"

      visit new_officing_residence_path
      click_link "Sign out"
      login_as user
      visit poll_path(poll)

      #expect(page).to have_css("button", text: 'Send', count: 0)

      expect(page).to have_content "You have already participated in a physical booth. You can not participate again."
      expect(page).to have_css("button", text: 'Send', count: 0)
      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_content('Han Solo')
        expect(page).to have_content('Chewbacca')

        expect(page).not_to have_link('Han Solo')
        expect(page).not_to have_link('Chewbacca')
      end
    end

  end

end
