@import lib/double_doc/version.rb

[![Build Status](https://travis-ci.org/zendesk/double_doc.svg?branch=master)](https://travis-ci.org/zendesk/double_doc)

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
  ## @@import app/models/user.rb
  def show
    render json: User.find(params[:id])
  end
end
```

Then write a markdown document about User API:

    ## Users
    Access users by using our REST API, blah blah blah...

    @@import app/controllers/users_controller.rb

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

@import lib/double_doc/task.rb

### Notes
 - Tested on ruby 2.0+
 - Does not work on jruby because of its dependency on redcarpet.

### TODO
@import doc/todo.md

### License
@import doc/license.md
