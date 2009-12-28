desc "Deploy to slicehost"
task :deploy do
  sh "rsync -rtz --delete . deploy@snappyco.de:/var/www/snappyco.de/"
end
