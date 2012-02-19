## DoubleDoc 1.0

One of the challenges you face when writing public documention for code or APIs, is that you have to remember to update the documentation
when ever you change the API. The main reason why this is a problem is that very often the documentation lives very for from your code.

This is the problem DoubleDoc tries to solve.

DoubleDoc allows you to write the documentation right where your code is, and you can combine it all into a well structured document.

### Format
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
You can easly use DoubleDoc from Rake, and soon I'll tell you how...

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