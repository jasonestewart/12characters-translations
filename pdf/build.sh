#!/bin/bash
#
# Run this to build the project.
#

set -e

cd "`dirname \"$0\"`"

rm -r build

for lang in "../play"/*; do
  if ! [ -d "$lang" ]; then
    echo "Skip $lang as it is not a language."
    continue
  fi
  echo "Prepare language $lang for the book."
  for file in "$lang"/*; do
    # Replace the latex specific characters.
    # see https://tex.stackexchange.com/a/34586/125049
    #  &  %  $  #  _  {  }  ~               ^                \
    # \& \% \$ \# \_ \{ \} \textasciitilde \textasciicircum \textbackslash
    base="./build/`basename \"$lang\"`/"
    play_dir="$base/play"
    mkdir -p "$play_dir"
    output="$play_dir/`basename \"$file\"`"
    echo "    Saving `basename \"$file\"`"
    cp "$file" "$output"
    for substitution in '\\/\\textbackslash' '&/\\&' '%/\\%' '\$/\\$' '#/\\#' '_/\\_' '{/\\{' '}/\\}' '~/$\\textasciitilde$' '\^/$\\textasciicircum$' '\[/\\[' '\]/\\]'
    do
      sed -i "s/$substitution/g" "$output"
    done 
  done
done

for lang in "build"/*; do
  cp -r ../latex/* "$lang"/
  docker run --rm -v "`pwd`/$lang":/latex niccokunzmann/ci-latex "/latex/build.sh"
done
