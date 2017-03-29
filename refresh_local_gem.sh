#!/bin/bash

# This is a helper file, will be deleted later

rm etcdv3-0.0.*
gem uninstall etcdv3
gem build etcdv3.gemspec
gem install etcdv3
