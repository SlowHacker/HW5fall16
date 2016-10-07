# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end

 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then /^(?:|I )should see "([^"]*)"$/ do |text|
    expect(page).to have_content(text)
 end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  movies_table.hashes.each do |movie|
    # Each returned movie will be a hash representing one row of the movies_table
    # The keys will be the table headers and the values will be the row contents.
    # Entries can be directly to the database with ActiveRecord methods
    # Add the necessary Active Record call(s) to populate the database.
    Movie.create(title: movie[:title], rating: movie[:rating], release_date: movie[:release_date])
  end
end

When /^I have opted to see movies rated: "(.*?)"$/ do |arg1|
  # HINT: use String#split to split up the rating_list, then
  # iterate over the ratings and check/uncheck the ratings
  # using the appropriate Capybara command(s)
  rating_list = arg1.split(",").map { |id| id = "ratings_" + id.strip }
  all('input[type=checkbox]').each do |ckb|
      if rating_list.include?(ckb[:id])
          check(ckb[:id])
      else
          uncheck(ckb[:id])
      end
  end
  
  click_button 'Refresh'
end

Then /^I should see only movies rated: "(.*?)"$/ do |arg1|
    result = true
    rating_list = arg1.split(",").collect(&:strip)
    find('tbody').all('tr').each do |row|
        if !rating_list.include?(row.all('td')[1].text)
            result = false
            break
        end
    end
    
    expect(result).to be_truthy 
end

Then /^I should see all of the movies$/ do
    expect(find('tbody').all('tr').size).to eq(Movie.count)
end

When /^I have sorted the movies alphabetically$/ do
    click_link 'Movie Title'
end

Then /^I should see "(.*?)" before "(.*?)"$/ do |movie_0, movie_1|
    expect(page.body).to match(/#{movie_0}.*#{movie_1}/m)
    #expect(page.body.index(movie_0) < page.body.index(movie_1)).to be_truthy
end

When /^I have sorted the movies by release date$/ do
    click_link 'Release Date'
end

Then /^I should see the oldest movie before the latest one$/ do
    tr_list = find('tbody').all('tr')
    expect(Date.parse(tr_list.first.all('td')[2].text) < Date.parse(tr_list.last.all('td')[2].text)).to be_truthy
end