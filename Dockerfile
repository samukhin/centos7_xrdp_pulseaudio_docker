# CENTOS 7
FROM centos:7

# Update system, install init system and add repo
RUN yum -y update && yum -y install epel-release systemd && yum -y update

# Install the GNOME Desktop package group by using the below command
RUN yum groupinstall "GNOME DESKTOP" -y

#Install XRDP and start XRDP service
RUN yum install xrdp -y && systemctl enable xrdp && systemctl disable firewalld

#Install build tools and package development tools
RUN yum groupinstall "Development Tools" -y && \
yum install rpmdevtools yum-utils -y && \
rpmdev-setuptree

# Install pulseaudio and requisite packages to build pulseaudio
RUN yum install pulseaudio pulseaudio-libs pulseaudio-libs-devel -y && \
yum-builddep pulseaudio -y 

# Fetch the pulseaudio source and extract
RUN yumdownloader --source pulseaudio && \
useradd mockbuild && \
usermod -G mockbuild mockbuild && \
rpm --install pulseaudio*.src.rpm

# Build the pulseaudio source
RUN rpmbuild -bb --noclean ~/rpmbuild/SPECS/pulseaudio.spec

# You’ll have two so files module-xrdp-sink.so and module-xrdp-source.so.
RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && \
cd pulseaudio-module-xrdp && \
./bootstrap && ./configure PULSE_DIR=~/rpmbuild/BUILD/pulseaudio-10.0 && \
make && \
make install

#Prepare user
RUN passwd -d root && useradd -m user && passd -d user

# Init
CMD /sbin/init
