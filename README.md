# CPro #

**cpro** - ruby-обертка для КриптоПро. 

Возможности:

* хэширование строки по алгоритмам: ГОСТ Р 34.11-94, ГОСТ Р 34.11-2012 256bit, ГОСТ Р 34.11-2012 512bit
* *подпись строки по алгоритмам ... (todo)*

```ruby
# Произвести хэширование строки
# --- по алгоритму ГОСТ Р 34.11-2012 256bit
CPro::Cryptcp.dn {CN: 'Иван Иванов'}		# параметры поиска сертификата в локальном хранилище
CPro::Cryptcp.hash_alg :gost3411_2012_256	# алгоритм хэширования
CPro::Cryptcp.hash('Hello world')
#=> "ABCDE..."
```



## Перед началом работы

Для работы библиотеки потребуется:

1) установить КриптоПро (протестировано на версии 5)

2) установить драйверы для носителя (напр. Рутокен 2.0)

3) установить сертификат в локальное хранилище



### Установить КриптоПро

[Скачиваем](https://www.cryptopro.ru/products/csp/downloads) архив с deb-пакетами x64 с оф. сайта, распаковываем, переходим в директорию со сценариями.

```bash
# --- запускаем установщик
sudo ./install_gui.sh
# Выбираем Next
# Отмечаем все пакеты, Next
# Install
# Ok
# Вводим линзионный ключ или пропускаем
# Exit
```



### Установить драйверы для носителя

```bash
# --- Устанавливаем драйвера РУТОКЕН
sudo apt-get install libccid pcscd libpcsclite1 pcsc-tools opensc

# --- Перезапускаем службу pcscd
sudo service pcscd restart

# --- Запускаем pcsc_scan (из состава драйверов РУТОКЕН) и можно вставить РУТОКЕН,
#     должна отобразиться информация об устройстве
pcsc_scan
# Using reader plug'n play mechanism
# Scanning present readers...
# ...
^C

# --- получаем модель подключенного токена
/opt/cprocsp/bin/amd64/csptest -card -enum -v -v
```



### Установить сертификат в локальное хранилище

#### Локальное хранилище

Локальное хранилище - это специальный раздел на ПК, в котором безопасно хранятся личные сертификаты.

Сертификаты с носителя могут быть "установлены" в хранилище. 

Для использования сертификата при хэшировании и подписи данных, он должен быть установлен в локальное хранилище. 

После установки сертификата с носителя в хранилище потребность в наличии установленного носителя в ПК сохраняется.

> Носитель должен быть вставлен в компьютер

```bash
# получить список сертификатов на носителе
/opt/cprocsp/bin/amd64/csptest -keyset -enum_cont -fqcn -verifyc | iconv -f cp1251
# CSP (Type:80) v5.0.10003 KC2 Release Ver:5.0.11455 OS:Linux CPU:AMD64
# AcquireContext: OK. HCRYPTPROV: 31340675
# \\.\Aktiv Rutoken lite 00 00\23bcbffe5-92e7-01bb-450b-9774105bf2c <------ сертификат

# Установка сертификата в локальное хранилище
/opt/cprocsp/bin/amd64/certmgr -inst -cont '\\.\Aktiv Rutoken lite 00 00\23bcbffe5-92e7-01bb-450b-9774105bf2c'

# просмотр сертификатов в локальном хранилище
/opt/cprocsp/bin/amd64/certmgr -list
```

#### Тестовый сертификат

Для отладки хэширования и подписи можно использовать тестовый сертификат, выданный тестовым удостоверяющим центром.

Для получения тестового сертификата необходимо:

1) установить в систему корневой сертификат тестового удостоверяющего центра

2) установить плагины КриптоПро для бразуера

3) установить тестовый личный сертификат на носитель



Для установки корневого сертификата тестового УЦ переход на [страницу](https://www.cryptopro.ru/certsrv/certcarc.asp) загрузки, выбираем опцию "Base 64" и нажимаем ссылку "Загрузка сертификата ЦС". 

Выполняем установку:

```bash
/opt/cprocsp/bin/amd64/certmgr -inst -store uRoot -cert -file /path/to/downloaded/certnew.cer
```

Проверяем наличие сертификата

```bash
 /opt/cprocsp/bin/amd64/certmgr -list -store uRoot
# 1-------
# Issuer              : E=support@cryptopro.ru, C=RU, L=Moscow, O=CRYPTO-PRO LLC, CN=CRYPTO-PRO Test Center 2
# Subject             : E=support@cryptopro.ru, C=RU, L=Moscow, O=CRYPTO-PRO LLC, CN=CRYPTO-PRO Test Center 2
# Serial              : 0x37418882F539A5924AD44E3DE002EA3C
# SHA1 Hash           : cd321b87fdabb503829f88db68d893b59a7c5dd3
# SubjKeyID           : 4e833e1469efec5d7a952b5f11fe37321649552b
# Signature Algorithm : ГОСТ Р 34.11/34.10-2001
# PublicKey Algorithm : ГОСТ Р 34.10-2001 (512 bits)
# Not valid before    : 27/05/2019  07:24:26 UTC
# Not valid after     : 26/05/2024  07:34:05 UTC
# PrivateKey Link     : No
# 2--------
# ...
```



Для установки плагинов открываем страницу [КриптоПро ЭЦП Browser plug-in](https://www.cryptopro.ru/products/cades/plugin) и выполняем инструкцию по установке.



Для установки тестового сертификата на носитель открываем [страницу "Тестовый УЦ"](https://www.cryptopro.ru/certsrv/) , нажимаем на ссылку "Сформировать ключи и отправить запрос на сертификат". На следующей странице отобразится диалоговое окно "КриптоПро CSP" с подтверждением действия (если диалогового окна нет, значит плагин для браузера установлен некорректно).

Далее вносим произвольные данные в разделе "Идентифицирующие сведения". В разделе "Параметры ключа" выбираем "Crypto-Pro GOST R 34.10-2012 KC2 CSP". Остальные параметры можно оставить без изменения. Нажимаем кнопку "Выдать" . Далее выполняем действия по генерации случайной последовательности и, при необходимости, задаем пароль. В итоге будет выполнен переход на страницу "Сертификат выдан" со ссылкой "Установить этот сертификат", при нажатии на которой и подтверждении действия получаем сообщение "Новый сертификат успешно установлен".

Сертификат установлен в локальном хранилище и должен отобразиться в выводе команды:

```bash
/opt/cprocsp/bin/amd64/certmgr -list
```

Проверку тестового сертификата можно выполнить на [странице](https://www.cryptopro.ru/sites/default/files/products/cades/demopage/simple.html) "Провека работы КриптоПро ЭЦП"



## Установка библиотеки

```bash
git submodule add REPO_URL PATH
```

