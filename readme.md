## DoubleDoc 2.0

[![CI Status](https://github.com/zendesk/double_doc/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/zendesk/double_doc/actions/workflows/ci.yml)

<!-- only modify doc/readme.md and not Readme.md -->

Write documentation with your code, to keep them in sync, ideal for public API docs.

This document was generated using DoubleDoc from [doc/readme.md](doc/readme.md), and the source of this project is a great source for how to use DoubleDoc.

### Documentation Format
Write documentation in markdown right in source code files by double commenting it:
```ruby
class User < ActiveRecord::Base
  ## ```js
  ## {
  ##   "id":   1,
  ##   "name": "Mick Staugaard"
  ## }
  ## ```
  def as_json
    # this comment will not be included in the documentation
    # as it only has a single # character
    super(only: [:id, :name])
  end
end

class UsersController < ApplicationController
  ## ### Getting a User
  ## `GET /users/{id}.json`
  ##
  ## #### Format
  ## @import app/models/user.rb
  def show
    render json: User.find(params[:id])
  end
end
```

Then write a markdown document about User API:

    ## Users
    Access users by using our REST API, blah blah blah...

    @import app/controllers/users_controller.rb

And DoubleDoc will generate this markdown document:

    ## Users
    Access users in by using our REST API, blah blah blah...

    ### Getting a User
    `GET /users/{id}.json`

    #### Format
    ```js
    {
      "id":   1,
      "name": "Mick Staugaard"
    }
    ```

### Rake Task
Generate documentation by telling DoubleDoc what the input files are, and where the output should go.
In the example, `double_doc` is picked to avoid conflicts with the `doc` rake task in rails.

```ruby
require 'double_doc'

DoubleDoc::Task.new(
  :double_doc,
  sources:          'doc/source/*.md',
  md_destination:   'doc/generated',
  html_destination: 'site'
)
```

The available options are:

| name                 | Description
| -------------------- | -----------
| __sources__          | __Required__. Documentation source directory (string or array of strings).
| __md_destination__   | __Required__. Directory where the generated markdown files should go.
| __html_destination__ | Where a pretty HTML version of the documentation should go.
| __html_template__    | Custom ERB template for HTML rendering, see default template for inspiration (templates/default.html.erb).
| __html_renderer__    | Custom html rendered, defaults to `DoubleDoc::HtmlRenderer`.
| __html_css__         | Custom CSS document path.
| __title__            | Title for generated HTML, defaults to "Documentation".
To generate a README.md for github, write documentation in doc/README.md and put this in the Rakefile:

```ruby
require 'double_doc'

DoubleDoc::Task.new(:double_doc, sources: 'doc/README.md', md_destination: '.')
```

Then run `rake double_doc`, which will generate a `readme.md` in the root of the project.

If a gh-pages branch exists, run `rake doc:publish` to generate html documentation and push it to your github pages.

### Notes
 - Tested on ruby 3.0+
 - Does not work on jruby because of its dependency on redcarpet.

### Release

After merging your changes:
1. Create a PR with a version bump and updated changelog.
2. After that PR gets merged, create a new tag (by running `gem_push=no rake release` or via Github releases).
3. This will trigger the publishing workflow—[approve it in Github Actions](https://github.com/zendesk/double_doc/actions/workflows/publish.yml)).

### TODO
* Support for directory structures
* Documentation for the Guard
* Add support for extracting documentation from JavaScript files

### License
#### The MIT License

Copyright © 2012 [Mick Staugaard](mailto:mick@staugaard.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
