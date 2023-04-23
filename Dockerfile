# This Dockerfile ignores some best practices in favor of readability and simplicity of individual components update
FROM dasbaumwolltier/archlinux-yay

# base image is switching to YAY user as last command

# Required dependencies: nodejs & ttfautohint
# ttfautohint has missing GPG key, so skipping verification for it
RUN sudo pacman -Suy --noconfirm curl nodejs-lts-hydrogen npm                                        \
 && yay -S --noconfirm --nopgpfetch --mflags "--skippgpcheck" --cleanafter --removemake ttfautohint  \
 && sudo pacman -S --clean --clean

# create build directory
# set 777 to build directory to allow "others" (eg, users from host system) full access to it
RUN mkdir -p /home/yay/Iosevka/dist/
WORKDIR /home/yay/Iosevka/
VOLUME /home/yay/Iosevka/dist/

# prepare Iosevka development setup
ARG IOSEVKA_VERSION=v22.1.0
RUN curl --location https://github.com/be5invis/Iosevka/archive/${IOSEVKA_VERSION}.tar.gz --output /tmp/iosevka.tar.gz   \
 && tar --extract --file /tmp/iosevka.tar.gz --strip-components 1                                                        \
 && rm -rf /tmp/iosevka.tar.gz                                                                                           \
 && npm install --no-audit

# copy custom build plan to current directory
# grant full access to Iosevka dir to be able to build font by any user
COPY --chown=yay:users private-build-plans.toml .
RUN sudo chmod --recursive 777 /home/yay/Iosevka

# build Iosevka distribution on run
ENTRYPOINT ["npm", "run", "build"]
CMD ["ttf::iosevka-personal"]
