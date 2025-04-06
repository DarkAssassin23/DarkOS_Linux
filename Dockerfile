FROM debian:latest 
WORKDIR /server  
COPY . ./tmp
RUN apt update && apt install build-essential libncurses-dev libssl-dev \
    bc flex bison libelf-dev python3 grub2 git gawk rsync xorriso \
    genisoimage pigz texinfo gettext autoconf libtool cpio wget -y \
    && cd tmp && ./buildISO.sh
