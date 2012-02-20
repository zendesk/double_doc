## DoubleDoc 1.0

One of the challenges you face when writing public documention for code or APIs, is that you have to remember to update the documentation
when ever you change the API. The main reason why this is a problem is that very often the documentation lives very for from your code.

This is the problem DoubleDoc tries to solve.

DoubleDoc allows you to write the documentation right where your code is, and you can combine it all into a well structured document.

This document was generated using DoubleDoc, and the source of this project is a great source for inspiration for how to use DoubleDoc.

### Documentation Format
You write your documentation in markdown right in your source code files by double commenting it:

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
    super(:only => [:id, :name])
  end

end

class UsersController < ApplicationController
  ## ### Getting a User
  ## `GET /users/{id}.json`
  ##
  ## #### Format
  ## @import app/models/user.rb
  def show
    render :json => User.find(params[:id])
  end
end
```

You would then write a markdown document about your User API:

    ## Users
    You can acces users in our system by using our REST API, blah blah blah...

    @import app/controllers/users_controller.rb

And DoubleDoc will generate this markdown document for you:

    ## Users
    You can acces users in our system by using our REST API, blah blah blah...

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
It is very easy to set up a rake task for generating your documentation. All you have to do is
tell DoubleDoc what the input files are, and where you want the output to go.

```ruby
require 'double_doc'

DoubleDoc::Task.new(:doc,
  :sources          => 'doc/source/*.md',
  :md_destination   => 'doc/generated',
  :html_destination => 'site'
)
```

The available options are:

| name                 | Description
| -------------------- | -----------
| __sources__          | __Required__. This tells Double doc where to look for the source of the documentation. Can be either a string or an array of strings.
| __md_destination__   | __Required__. This is the directory where you want the generated markdown files to go.
| __html_destination__ | If you want a pretty HTML version of your documentation, all you have to do is to say where you want it.
| __html_template__    | You can use your own custom ERB template for HTML rendering. Have a look in the one we ship with DoubleDoc for inspiration (templates/default.html.erb).
| __html_renderer__    | If you want full control of the HTML rendering you can use your own implementation. Defaults to `DoubleDoc::HtmlRenderer`.
| __html_css__         | You can use your own custom CSS document by specifying it's path here.
| __title__            | The title you want in the generated HTML. Defaults to "Documentation".

If you just want to use double doc to generate your README.md for github, you should write your documentation in doc/README.md and put his in your Rakefile:

```ruby
require 'double_doc'

DoubleDoc::Task.new(:doc, :sources => 'doc/README.md', :md_destination => '.')
```
Then all you have to do is to run `rake doc`, and you will have a `readme.md` in the root of your project.

You can even run `rake doc:publish` to generate html documentation and push it to your Github Pages.

### Notes
DoubleDoc is tested as working on both ruby 1.8.7 and 1.9.3, but does not work on jruby because if it's dependency on redcarpet.

[![Build Status](https://secure.travis-ci.org/staugaard/double_doc.png?branch=master)](http://travis-ci.org/staugaard/double_doc)

### TODO
* Tests
* Support for directory structures
* Documentation for the Rake task
* Documentation for the Guard
* Add support for extracting documentation from JavaScript files

### License
#### The MIT License

Copyright © 2012 [Mick Staugaard](mailto:mick@staugaard.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.