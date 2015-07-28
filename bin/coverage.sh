#!/bin/bash

if [[ $1 == -i ]] ; then
  integration='-tags integration'
fi

failure=0
echo "mode: set" > .acc.out
for Dir in . $(find ./* -maxdepth 10 -type d -prune -o -path 'Godeps/*' );
do
        if ls $Dir/*.go &> /dev/null;
        then
            godep go test -coverprofile=.profile.out $integration $Dir || failure=1
            if [ -f .profile.out ]
            then
                cat .profile.out | grep -v "mode: set" >> .acc.out
            fi
fi
done

if [[ -z $2 ]] ; then
  gocov convert .acc.out | gocov-html > coverage.html
else
  goveralls -coverprofile=.acc.out -repotoken=$2 -service=circleci
fi

rm .profile.out .acc.out

exit $failure
