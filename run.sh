#!/bin/sh

set -e

if [ $# -ne 1 ]; then
  echo "Usage: run.sh /path/to/program.challenge"
  exit 1;
fi

make parser
./parser < $1 > $1.bonsai_starting_state
cp rules.bonsai $1.bonsai
prefix=`grep '^ *\$K$' rules.bonsai | sed 's/\$K$//'`
sed -i '' "s/^/$prefix/g" $1.bonsai_starting_state
sed -i '' -e "/^$prefix\$K$/ {" -e "r $1.bonsai_starting_state" -e 'd' -e '}' $1.bonsai
rm $1.bonsai_starting_state
ruby bonsai/implementations/ruby/run.rb $1.bonsai
