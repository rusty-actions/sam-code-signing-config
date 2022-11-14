#!/bin/sh -l

# Always mask the profile
echo "::add-mask::$2"

cd $GITHUB_WORKSPACE

echo "::debug ::Set the template"
TEMPLATE="${1:-./template.yaml}"
if [[ ! -f $TEMPLATE ]]; then
	echo $TEMPLATE not found. Exiting.
	exit 1
fi

echo "::debug ::Set the profile"
PROFILE="${2}"
if [ "${PROFILE}x" = "x" ]; then
  echo "Profile must be provided"
  exit 2
fi

SIGNER="${3}"
if [ "${SIGNER}x" != "x" ]; then
  echo "::add-mask::$3"
  echo "::debug ::Updating template with signing profile"
  mv $TEMPLATE $TEMPLATE.orig
  sed -e "s~\([[:space:]]*\)SigningProfileVersionArns:.*~\1SigningProfileVersionArns:\n\1 - $SIGNER~" $TEMPLATE.orig > $TEMPLATE

  echo "::group::template output"
  echo "$(cat $TEMPLATE)"
  echo "::endgroup"
fi

SIGNING_CONFIG=$(fgrep -B1 "Type: AWS::Serverless::Function" $TEMPLATE | grep -e ':$' | sed "s/^ *\(.*\):/\1=$PROFILE /" | grep -ve '^#' | tr -d '\n' | xargs)
SUCCESS=$?

OUTPUT="--signing-profiles $SIGNING_CONFIG"

echo "::group::signing output"
echo "SIGNING_CONFIG: $OUTPUT"
echo "::endgroup"

echo "signing_config<<EOF" >> $GITHUB_OUTPUT
echo "${OUTPUT}" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT

exit $SUCCESS
