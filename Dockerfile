FROM ubuntu
MAINTAINER kensium
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y nginx vim net-tools && apt-get install -y mysql-server && service mysql start && mysql -uroot -proot -e "CREATE DATABASE magento; CREATE USER 'magento'@'localhost' IDENTIFIED BY 'magento'; GRANT ALL PRIVILEGES ON *.* TO 'magento'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" && apt-get update && apt-get -y install software-properties-common && add-apt-repository ppa:ondrej/php && apt-get update && apt-get install -y php7.4 && apt-get install -y php7.4-fpm php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath php7.4-intl php7.4-soap && apt-get update && apt-get install -y curl sudo && curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg &&apt-get update && echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list && apt-get update && apt-get install -y elasticsearch && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && php composer-setup.php && mv composer.phar /usr/local/bin/composer


RUN service php7.4-fpm start

COPY php /etc/php/7.4/cli/php.ini
COPY default1 /etc/nginx/sites-available/default
COPY elasticsearch /etc/elasticsearch/elasticsearch.yml
COPY jvm.options /etc/elasticsearch/jvm.options
COPY env.php /var/www/html/
