RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
clear
ls

printf "1) Laravel root folder not public_html \n"
read -p "Laravel root folder: " laravelFolder

cp $laravelFolder/.env.example $laravelFolder/.env

clear

printf " Indique el usuario para acceder a mysql \n"
read -p "mysql user : " mysqlRootUser

printf "1) Indique la clave para acceder a mysql \n"
read -p "mysql password : " mysqlRootPassword


clear

until mysql -u $mysqlRootUser -p$mysqlRootPassword  -e ";" ; do
        printf "${RED}Can't connect, please retry:${NC} \n"
        read -p "mysql passwor : "  mysqlRootPassword
        clear
done

clear
printf "$GREEN Connection success $NC \n"
printf "$GREEN Creating database $NC \n"
read -p "Database name: " database

until mysql -u $mysqlRootUser -p$mysqlRootPassword -e "create database $database" ; do
        printf "${RED}Database exist ${NC} \n"
        read -p "Database name: " database
done

printf "$GREEN Creating .env file configuration $NC \n"


# Linux support
sed -i "s/DB_DATABASE=homestead/DB_DATABASE=$database/gi" $laravelFolder/.env
sed -i "s/DB_USERNAME=homestead/DB_USERNAME=$mysqlRootUser/gi" $laravelFolder/.env
sed -i '' -e "s/DB_PASSWORD=secret/DB_PASSWORD=$mysqlRootPassword/g" $laravelFolder/.env


# Mac support
sed -i '' -e "s/DB_DATABASE=homestead/DB_DATABASE=$database/g" $laravelFolder/.env
sed -i '' -e "s/DB_USERNAME=homestead/DB_USERNAME=$mysqlRootUser/g" $laravelFolder/.env
sed -i "s/DB_PASSWORD=secret/DB_PASSWORD=$mysqlRootPassword/gi" $laravelFolder/.env



apt-get install php-memcached

cd $laravelFolder
composer install
php artisan key:generate
echo "holaaa"

v="$(cat <<-EOF
<?php

function quickRandom( \$length = 16)
{
    \$pool = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    return substr(str_shuffle(str_repeat(\$pool, 5)), 0, \$length);
}

  echo quickRandom(32);
?>
EOF
)"

echo $v > phpkey-generate.php
sudo chmod 777 phpkey-generate.php
newKey=$(php -f phpkey-generate.php)

echo $newKey;

# Linux support
sed -i "s/APP_KEY=/APP_KEY=$newKey/gi" $laravelFolder/.env

# Mac support
sed -i '' -e "s/APP_KEY=/APP_KEY=$newKey/g" $laravelFolder/.env




rm phpkey-generate.php


php artisan migrate
php artisan migrate:refresh --seed

printf "$GREEN Importing database sql file $NC \n"
mysql -u root -p$mysqlRootPassword $database < database.sql
printf "$GREEN SQL file imported successfuly $NC \n"

printf "$GREEN Setting chmod in required folders $NC \n"
sudo chmod 777 ./storage -R
sudo chmod 777 ./public -R

