# this Dockerfile ignores some best practices in favor of readability and simplicity of individual components update
FROM node:lts-slim

# required dependencies: git & ttfautohint
RUN <<EOF
  apt-get update
  apt-get install --no-install-recommends -y git ttfautohint ca-certificates
  apt-get clean
EOF

# download Iosevka src code and setup work env
ARG IOSEVKA_VERSION=main
RUN <<EOF
  git clone --depth=1 --branch ${IOSEVKA_VERSION} https://github.com/be5invis/Iosevka.git

  # install build dependencies
  cd Iosevka && npm install --no-audit

  # grant full access to Iosevka dir to be able to build font by any user
  chmod --recursive 777 /Iosevka
EOF

# setup work and result directories
WORKDIR /Iosevka
VOLUME  /Iosevka/dist/

# copy custom build plan to current directory
COPY private-build-plans.toml .

# build Iosevka distribution on run
ENTRYPOINT ["npm", "run", "build", "--"]
CMD ["ttf::iosevka-personal"]
