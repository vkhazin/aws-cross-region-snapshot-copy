VOLUME_ID='vol-0629a13db343a19c0'
SOURCE_REGION='us-east-2'
TARGET_REGION='us-east-1'
./copy-snapshot.sh -v "$VOLUME_ID" -s "$SOURCE_REGION" -t "$TARGET_REGION"