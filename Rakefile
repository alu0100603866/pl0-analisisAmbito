desc "Run server"
task :default => [:use_keys, :jison] do
  sh "rackup"
end

desc "Save config.yml out of the CVS"
task :keep_secrets do
  sh "cp config/config_template.yml config/config.yml "
end

desc "Use the filled client_secrets"
task :use_keys do
  sh "cp config/config_filled.yml config/config.yml"
end

desc "Go to console.developers.google"
task :link do
  sh "open https://console.developers.google.com/project/apps~sinatra-ruby-gplus/apiui/api"
end

desc "Commit changes"
task :ci, [ :message ] => :keep_secrets do |t, args|
  message = args[:message] || ''
  sh "git ci -am '#{message}'"
end

task :jison => %w{public/calculator.js} 

desc "Compile the grammar public/calculator.jison"
file "public/calculator.js" => %w{public/calculator.jison} do
  sh "jison public/calculator.jison public/calculator.l -o public/calculator.js"
end

task :jison => %w{public/pl0.js} 
desc "Compile the grammar public/pl0.jison"
file "public/pl0.js" => %w{public/pl0.jison} do
  sh "jison public/pl0.jison public/pl0.l -o public/pl0.js"
end

desc "Compile the sass public/styles.scss"
task :css do
  sh "sass public/styles.scss public/styles.css"
end

task :testf do
  sh " open -a firefox test/test.html"
end

task :tests do
  sh " open -a safari test/test.html"
end

desc "Remove calculator.js"
task :clean do
  sh "rm -f public/calculator.js"
  sh "rm -f calculator*.tab.jison"
  sh "rm -f calculator*.output"
  sh "rm -f calculator*.vcg"
  sh "rm -f calculator*.c"
end

desc "Open browser in GitHub repo"
task :github do
  sh "open https://github.com/crguezl/ull-etsii-grado-pl-jisoncalc"
end

desc "DFA table using bison -v"
task :table do
  sh "bison -v public/calculator.jison"
end
