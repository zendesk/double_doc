$LOAD_PATH.unshift 'lib'
require 'double_doc'

guard :double_doc, :rake_task => 'doc' do
  watch(/^(doc|lib|templates)\//)
end
