desc "Deploy to slicehost"
task :deploy do
  sh "rsync -rtz --delete . deploy@snappyco.de:/var/www/snappyco.de/"
  sh "ssh deploy@snappyco.de touch /var/www/snappyco.de/tmp/restart.txt"
end
