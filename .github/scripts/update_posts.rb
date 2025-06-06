require 'httparty'
require 'nokogiri'
require 'octokit'
require "logger"
require 'base64'

logger = Logger.new(STDOUT)

# Scrape blog posts from the website
url = "https://www.bingfeng.tech/"
response = HTTParty.get(url)
parsed_page = Nokogiri::HTML(response.body)
posts = parsed_page.css('.post-card')

# Generate the updated blog posts list (top 5)
posts_list = ["### Recent Blog Posts\n"]
posts.first(5).each do |post|
  title = post.css("h2").text.strip
  link = "#{post.at_css('a')[:href]}"
  posts_list << "* [#{title}](#{url}#{link})"
end

logger.debug(posts_list)

# Update the README.md file
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
repo = ENV['GITHUB_REPOSITORY']
readme = client.readme(repo)
readme_content = Base64.decode64(readme[:content]).force_encoding('UTF-8')

# Replace the existing blog posts section
posts_regex = /### Recent Blog Posts[\s\S]*?(?=### Pinned Repos)/m
updated_content = readme_content.sub(posts_regex, "#{posts_list.join("\n")}\n")

client.update_contents(repo, 'README.md', 'Update recent blog posts', readme[:sha], updated_content)
