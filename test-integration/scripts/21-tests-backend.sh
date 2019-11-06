#!/bin/bash

set -e
source $(dirname $0)/00-init-env.sh

#-------------------------------------------------------------------------------
# Display environment information like JDK version
#-------------------------------------------------------------------------------
cd "$JHI_FOLDER_APP"
if [ -f "mvnw" ]; then
    ./mvnw -ntp enforcer:display-info
elif [ -f "gradlew" ]; then
    ./gradlew -v
fi

#-------------------------------------------------------------------------------
# Exclude webpack task from Gradle if not skipping client
#-------------------------------------------------------------------------------
JHI_GRADLE_EXCLUDE_WEBPACK="-x webpack"
if [[ $(grep "\"skipClient\": true" .yo-rc.json) != "" ]]; then
    JHI_GRADLE_EXCLUDE_WEBPACK=""
fi

#-------------------------------------------------------------------------------
# Check Javadoc generation
#-------------------------------------------------------------------------------
if [ -f "mvnw" ]; then
    ./mvnw -ntp javadoc:javadoc
elif [ -f "gradlew" ]; then
    ./gradlew javadoc $JHI_GRADLE_EXCLUDE_WEBPACK
fi

#-------------------------------------------------------------------------------
# Check no-http
#-------------------------------------------------------------------------------
if [ -f "mvnw" ]; then
    ./mvnw -ntp checkstyle:check
elif [ -f "gradlew" ]; then
    ./gradlew checkstyleNohttp -x webpack
fi

#-------------------------------------------------------------------------------
# Launch UAA tests
#-------------------------------------------------------------------------------
if [[ "$JHI_APP" == *"uaa"* ]]; then
    cd "$JHI_FOLDER_UAA"
    ./mvnw -ntp verify
fi

#-------------------------------------------------------------------------------
# Launch tests
#-------------------------------------------------------------------------------
cd "$JHI_FOLDER_APP"
if [ -f "mvnw" ]; then
    ./mvnw -ntp -P-webpack verify \
        -Dlogging.level.ROOT=OFF \
        -Dlogging.level.org.zalando=OFF \
        -Dlogging.level.io.github.jhipster=OFF \
        -Dlogging.level.io.github.jhipster.sample=OFF \
        -Dlogging.level.io.github.jhipster.travis=OFF \
        -Dlogging.level.org.springframework=OFF \
        -Dlogging.level.org.springframework.web=OFF \
        -Dlogging.level.org.springframework.security=OFF

elif [ -f "gradlew" ]; then
    ./gradlew test integrationTest $JHI_GRADLE_EXCLUDE_WEBPACK \
        -Dlogging.level.ROOT=OFF \
        -Dlogging.level.org.zalando=OFF \
        -Dlogging.level.io.github.jhipster=OFF \
        -Dlogging.level.io.github.jhipster.sample=OFF \
        -Dlogging.level.io.github.jhipster.travis=OFF \
        -Dlogging.level.org.springframework=OFF \
        -Dlogging.level.org.springframework.web=OFF \
        -Dlogging.level.org.springframework.security=OFF
fi
