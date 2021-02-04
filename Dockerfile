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

# installing openssl
# install openssl
RUN apk add --update openssl && \
    rm -rf /var/cache/apk/*

# Adding bugscout appliance cert to jvm
ARG KEYSTOREFILE=temporal_keystore
ARG KEYSTOREPASS=changeme

# a) get the SSL certificate
RUN /usr/bin/openssl s_client -connect 35.199.111.237:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > temporal.cert

# b) create a keystore and import certificate
RUN /opt/java/openjdk/bin/keytool -import -noprompt -trustcacerts -alias 35.199.111.237 -file temporal.cert -keystore temporal_keystore -storepass changeme

# c) verify we've got it.
RUN /opt/java/openjdk/bin/keytool -list -v -keystore temporal_keystore -storepass changeme -alias 35.199.111.237

# Prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
