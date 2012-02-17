## DoubleDoc
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