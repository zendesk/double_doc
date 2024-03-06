@import lib/double_doc/version.rb

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
 - Tested on ruby 3.0+
 - Does not work on jruby because of its dependency on redcarpet.

### Release

After merging your changes:
1. Create a PR with a version bump and updated changelog.
2. After that PR gets merged, create a new tag (by running `gem_push=no rake release` or via Github releases).
3. This will trigger the publishing workflow—[approve it in Github Actions](https://github.com/zendesk/double_doc/actions/workflows/publish.yml)).

### TODO
@import doc/todo.md

### License
@import doc/license.md
