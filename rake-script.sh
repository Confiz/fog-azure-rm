#!/bin/bash

if [ $TRAVIS_BRANCH == 'master' ]
then
  rake cc_coverage
  rake integration_tests
else
  rake cc_coverage
fi