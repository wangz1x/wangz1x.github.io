# used to publish new blog

# push to hexo branch which used to save source blog
git add .
git commit -m "add new blog"
git push


# update blog to master branch which used to show blogs
hexo clean
hexo g -d

#hexo d -g
