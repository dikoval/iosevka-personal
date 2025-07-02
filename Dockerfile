# this Dockerfile ignores some best practices in favor of readability and simplicity of individual components update
FROM node:lts-slim

# required dependencies: git, make & ttfautohint
RUN <<EOF
  apt-get update
  apt-get install --no-install-recommends -y git make ttfautohint ca-certificates
  apt-get clean
EOF

# create workdir and make sure, that it is writable by all users (eg, host user)
RUN mkdir -p /iosevka-personal && chmod 777 /iosevka-personal
WORKDIR /iosevka-personal

# copy custom build plan to current directory
COPY Makefile private-build-plans.toml .

# build Iosevka distribution on run
ENTRYPOINT ["make"]
CMD ["--always-make", "build"]
