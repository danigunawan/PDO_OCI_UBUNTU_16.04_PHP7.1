#!/bin/bash

apt-get install php7.1-dev build-essential php-pear libaio1 -y

#Direktori instalasi Oracle Instan Client
install_dir="/opt/oracle"

#Capture Direktori Pengguna
user_dir="$(echo ~)" #standar, modifikasi sesuai kebutuhan Anda

#PATH do php.ini
php_ini="/etc/php/7.1/apache2/php.ini"
#php_ini="0"

mods_available="/etc/php/7.1/mods-available"
mods_enable="/etc/php/7.1/apache2/conf.d/"

#replace="apache2"
#path_php_ini="$(php --ini | grep Loaded | cut -d" " -f12)"


#echo php_ini=${path_php_ini/"cli"/$replace}

#limpar tela
clear

#Periksa prasyarat untuk instalasi

if [ $install_dir = "" ]; then
    echo "\033[01;31;47mÉ perlu menginformasikan PATH dari direktori instalasi ke Oracle Instant Client. (Ex: \"/opt/oracle\").\033[0m  - \033[01;32;31mERRO"
    exit
fi

if [ $user_dir = "0" ]; then
    echo "\033[01;31;47mÉ perlu menginformasikan PATH direktori pengguna. (Ex:"$(echo ~)").\033[0m  - \033[01;32;31mERRO"
    exit
fi

if [ $php_ini = "0" ]; then
    echo "\033[01;31;47mÉ perlu menginformasikan PATH file php.ini (EX: /etc/php/7.1/apache2/php.ini).\033[0m  - \033[01;32;31mERRO"
    exit
fi

#exit
if [ -e instantclient-basic-*.zip ]; then
        echo "\033[01;34;47mInstantclient-basic - \033[01;32;40mOK"
else
    echo "\033[01;31;47mÉ nbahwa installer instantclient-basic - *. zip ada di direktori yang sama dengan skrip ini.\033[0m  - \033[01;32;31mERRO"
    exit
fi

if [ -e instantclient-sdk-*.zip ]; then
        echo "\033[01;34;47mInstantclient-sdk - \033[01;32;40mOK"
else
    echo "\033[01;31;47mÉ nbahwa installer instantclient-sdk - *. zip ada di direktori yang sama dengan skrip ini.\033[0m - \033[01;32;31mERRO"
    exit
fi

tag=0

if [ -e php-7.*.tar.gz ]; then
    echo "\033[01;34;47mMenyiapkan penginstal PHP"
    tar -vzxf php-7.*.tar.gz
    tag=1
fi

if [ -e php-7.*.tar.bz2 ]; then
    echo "\033[01;34;47mMenyiapkan penginstal PHP"
    tar -vxf php-7.*.tar.bz2
    tag=1
fi

if [ -e php-7.*.tar.xz ]; then
    echo "\033[01;34;47mMenyiapkan penginstal PHP"
    tar -vxJf php-7.*.tar.xz -C
    tag=1
fi




if [ $tag = 0 ]; then
    echo "\033[01;31;47mÉ harus ada dalam paket PHP7. * di direktori yang sama dengan skrip ini..\033[0m  - \033[01;32;31mERRO"
    exit
else
    echo "\033[01;34;47mPemasang PHP7. * - \033[01;32;40mOK"
fi




#echo "PERHATIAN, PASTIKAN DIREKTORI \ "instantclient \" ada di direktori yang sama dengan Script ini."
echo "\033[01;34;47mMemeriksa paket pemasangan Oracle Instant Client.\033[0m"
versao="$(find . -name "*instantclient-*" | grep -Po "(\d+\.)+\d+" | cut -c 1-4)"
v1="$(echo $versao | cut -c 1-4)"
v2="$(echo $versao | cut -c 6-9)"

# Perbandingan Kesetaraan
if [ "$v1" = "$v2" ] && [ $v1 != "" ] && [ $v1 != " " ]; then
    echo "Installation melakukan Oracle Instant Client - \033[01;34;41mOK"
else
    echo "Installation melakukan Oracle Instant Client - \033[05;37;41mERROR"
    exit
fi
#

echo "\033[01;34;47mVersi Oracle Instant Client: \033[01;34;41m$(echo $versao | cut -c 1-4) \033[01;37m\033[01;37m"
echo "\033[0m"
echo ""


#Buka kemasan installer
sudo -S unzip "instantclient-*.zip" -d $install_dir
#
#Ganti nama Instantclient_X_X
cmd="$(sudo mv $install_dir/instantclient* $install_dir/instantclient)"
#
#menangkap versi lib, yang mungkin berbeda dari versi yang masuk dalam nama paket
versao_lib="$(find $install_dir/instantclient -name "*lib*" | grep -Po "(\d+\.)+\d+" | cut -c 1-4 | uniq)"
#
#Menghasilkan beberapa tautan simbolis
if [ $v1 = "12.1" ]; then
    cmd="$(sudo ln -s $install_dir/instantclient/libclntshcore.so.$versao_lib $install_dir/instantclient/libclntshcore.so)"
fi
#


cmd="$(sudo ln -s $install_dir/instantclient/libclntsh.so.$versao_lib $install_dir/instantclient/libclntsh.so)"
cmd="$(sudo ln -s $install_dir/instantclient/libocci.so.$versao_lib $install_dir/instantclient/libocci.so)"

#Gravar os PATH do Oracle Instant Client no arquivo de inicialização do perfil do Usuario
a="export LD_LIBRARY_PATH=$install_dir/instantclient:\$LD_LIBRARY_PATH"
b="export PATH=$install_dir/instantclient:\$PATH"
c="export ORACLE_HOME=$install_dir/instantclient"
d="export PATH=\$ORACLE_HOME:\$PATH"


echo $a >> $user_dir"/.bashrc"
echo $b >> $user_dir"/.bashrc"
echo $c >> $user_dir"/.bashrc"
echo $d >> $user_dir"/.bashrc"


echo "########################__MENGKOMPILE OCI8__############################"

cd php*/ext/oci8
#ls -lah
phpize
./configure --with-oci8=shared,instantclient,$install_dir/instantclient,$v1
make clean
make
#make test
cmd = $(sudo -S make install)
#echo "\033[01;34;41m$cmd\033[0m"

cd ../pdo_oci
echo "######################__CMENGKOMPILE__PDO_OCI__##########################"

phpize
./configure --with-pdo-oci=instantclient,$install_dir/instantclient,$v1
make clean
make
#make test
cmd = $(sudo -S make install)
#echo "\033[01;34;41m$cmd\033[0m"

#php --ini | grep Loaded | cut -d" " -f12

echo "Mengkonfigurasi Ekstensi PDO_OCI dan OCI8"
sudo echo "extension=pdo_oci.so" >> $php_ini
sudo echo "extension=oci8.so" >> $php_ini

sudo touch $mods_available"/pdo_oci.ini"
sudo touch $mods_available"/oci8.ini"

sudo echo "extension=pdo_oci.so" >> $mods_available"/pdo_oci.ini"
sudo echo "extension=oci8.so" >> $mods_available"/oci8.ini"

cd $mods_enable
sudo ln -s $mods_available/pdo_oci.ini 10-pdo_oci.ini
sudo ln -s $mods_available/oci8.ini 10-oci8.ini

ls -lah

echo "Restart Apache"
sudo service apache2 restart


echo "Periksa PHP Anda dengan perintah php -m atau php -m | grep oci dan periksa apakah modul telah diinstal dengan benar."

exit