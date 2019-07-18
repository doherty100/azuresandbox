#!/bin/bash

# Downloads jp release and moves it to bin directory

wget https://github.com/jmespath/jp/releases/download/0.1.3/jp-linux-amd64
chmod 755 jp-linux-amd64 
sudo mv jp-linux-amd64 /usr/local/bin/jp
jp --version
