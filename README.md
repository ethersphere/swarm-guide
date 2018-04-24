# swarm-guide

swarm documentation in sphinx, hosted on read the docs: http://swarm-guide.readthedocs.io

## to set up the environment (mac)
```shell
brew install sphinx-doc
pip install sphinx_rtd_theme
cd swarm-guide
mkdir -p docs/_themes
ln -s /usr/local/lib/python2.7/site-packages/sphinx_rtd_theme sphinx_rtd_theme # don't push
sed -i -e 's/^#html_theme_path*/html_theme_path/g' contents/conf.py # don't push 
```

To compile the html,

```shell
cd swarm-guide
make html
```

