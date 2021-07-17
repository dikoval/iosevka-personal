# This Dockerfile ignores some best practices in favor of readability and simplicity of individual components update
FROM oblique/archlinux-yay

# Required dependencies: nodejs & ttfautohint & otfcc
# ttfautohint has missing GPG key, so skipping verification for it
RUN pacman -Suy --noconfirm curl nodejs-lts-erbium npm                           \
 && sudo --user aur -- yay -S --noconfirm --nopgpfetch --mflags "--skippgpcheck" \
                              --cleanafter --removemake ttfautohint otfcc        \
 && pacman -S --clean --clean                                                    \
 && rm -rf /home/aur/.cache

# create build directory
# set 777 to build directory to allow "others" (eg, users from host system) full access to it
RUN mkdir -p /Iosevka/dist/                 \
 && chown --recursive aur:users /Iosevka/
WORKDIR /Iosevka/
VOLUME /Iosevka/dist/

# drop root privileges
USER aur

# prepare Iosevka development setup
ARG IOSEVKA_VERSION=v7.3.0
RUN curl --location https://github.com/be5invis/Iosevka/archive/${IOSEVKA_VERSION}.tar.gz --output /tmp/iosevka.tar.gz   \
 && tar --extract --file /tmp/iosevka.tar.gz --strip-components 1                                                        \
 && rm -rf /tmp/iosevka.tar.gz                                                                                           \
 && npm install --no-optional --no-audit

# copy custom build plan to current directory
# grant full access to Iosevka dir to be able to build font by any user
COPY --chown=aur:users private-build-plans.toml .
RUN chmod --recursive 777 /Iosevka

# build Iosevka distribution on run
ENTRYPOINT ["npm", "run", "build"]
CMD ["contents::iosevka"]
