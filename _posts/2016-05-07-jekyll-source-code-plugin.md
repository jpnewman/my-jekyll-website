---
layout: post
title: Jekyll Source Code Plugin
categories: Tech
tags:
- Jekyll
- Plugin
source_codes:
  - file: ../_plugins/source_code.rb
    language: ruby
    title: source_code.rb
  - file: ../_plugins/generate_source_code.rb
    language: ruby
    title: generate_source_code.rb
  - file: ../_plugins/redcarpet-custom.rb
    language: ruby
    title: redcarpet-custom.rb
---

I created the following Jekyll plugins to add support for code blocks with downloadable file link headers and custom titles.

## To Use

Place the file in a "_code" post relative folder and the following in the post Front Matter.

~~~
source_codes:
  - file: ../_code/source_code.rb
    language: ruby
    title: source_code.rb
  - file: ../_code/generate_source_code.rb
    language: ruby
    title: generate_source_code.rb
  - file: ../_code/redcarpet-custom.rb
    language: ruby
    title: redcarpet-custom.rb
~~~

{% source_code ../_plugins/source_code.rb %}

{% source_code ../_plugins/generate_source_code.rb %}

Based on plugin from <http://manidesto.github.io/better-code-blocks-in-jekyll> and modified to add code path and title.

{% source_code ../_plugins/redcarpet-custom.rb %}
