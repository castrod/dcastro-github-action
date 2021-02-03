FROM sonarsource/sonar-scanner-cli:4.5

LABEL version="0.0.1" \
      repository="https://github.com/sonarsource/sonarcloud-github-action" \
      homepage="https://github.com/sonarsource/sonarcloud-github-action" \
      maintainer="SonarSource" \
      com.github.actions.name="SonarCloud Scan" \
      com.github.actions.description="Scan your code with SonarCloud to detect bugs, vulnerabilities and code smells in more than 25 programming languages." \
      com.github.actions.icon="check" \
      com.github.actions.color="green"

ARG SONAR_SCANNER_HOME=/opt/sonar-scanner
ARG NODEJS_HOME=/opt/nodejs

ENV PATH=${PATH}:${SONAR_SCANNER_HOME}/bin:${NODEJS_HOME}/bin

WORKDIR /opt

# https://help.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#user
USER root

# Adding bugscout appliance cert to jvm
ARG HOST=sast.bugscout.io
ARG PORT=443
ARG KEYSTOREFILE=temporal_keystore
ARG KEYSTOREPASS=chageme

# a) get the SSL certificate
openssl s_client -connect ${HOST}:${PORT} </dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${HOST}.cert

# b) create a keystore and import certificate
keytool -import -noprompt -trustcacerts \
    -alias ${HOST} -file ${HOST}.cert \
    -keystore ${KEYSTOREFILE} -storepass ${KEYSTOREPASS}

# c) verify we've got it.
keytool -list -v -keystore ${KEYSTOREFILE} -storepass ${KEYSTOREPASS} -alias ${HOST}

# Prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
