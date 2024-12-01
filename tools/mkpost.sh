#!/bin/sh

# MIT License
# 
# Copyright (c) 2024 Hunter G. Reynolds
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if [ $# != "1" ]; then
    echo "Just the title of the post please"
    exit 1
fi

today=$(date "+%Y-%m-%d")
now=$(date "+%H:%M:%S %z")
post_title=$1
post_file="_posts/${today}-${post_title}.md"

if [ -d "_posts" ]; then
    #echo "---\ntitle:\ndate: ${today} ${now}\nmedia_subpath: /assets/images/${today}-${post_title}.d\ntags:\ncategories:\n---\n" >> "${post_file}"
    printf -- "---\ntitle:\ndate: %s %s\nmedia_subpath: /assets/images/%s-%s.d\ntags:\ncategories:\n---\n" "$today" "$now" "$today" "$post_title" >> "$post_file"

    mkdir -p "assets/images/${today}-${post_title}.d"
fi

