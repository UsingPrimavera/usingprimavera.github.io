source "https://rubygems.org"

ruby "3.3.4"

gem "jekyll", "~> 4.4.1"
gem "just-the-docs", "0.10.1"   # pinned — do not upgrade without testing

# removes unambiguous specs during Fem::Specification.reset warning
gem "psych", "~> 5.3.1"
gem "erb", "~> 6.0.4"

group :jekyll_plugins do
  gem "jekyll-compose"          # draft/post/publish CLI commands
  gem "jekyll-feed"             # RSS feed at /feed.xml
  gem "jekyll-seo-tag"          # <meta> SEO tags, Open Graph, Twitter Card
  gem "jekyll-sitemap"          # sitemap.xml for search engines
  gem "jekyll-paginate-v2"      # blog pagination
end

# Development only
group :development do
  gem "html-proofer"            # link and HTML validity checking
end
