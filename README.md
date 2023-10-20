
![logo](https://raw.githubusercontent.com/solo10010/trash/main/static/image/reconwtf1.png "reconWTF Logo")

# RESUME

**ReconWTF** это инструмент, предназначенный для охотников за вознаграждениями (bounty hunters). Скрипт устанавливает и запускает лучший набор инструментов для расширения атакующей поверхности для веб-сайтов, порталов и организаций.

**Благодарности six2dez за сценарии и идеи для этого инструмента, хотя reconftw и reconWTF похожи, мой работает хуже XD. По крайней мере, не для меня.** 

# Установка

```bash
git clone https://github.com/solo10010/reconWTF
cd reconWTF
chmod +x *.sh
sh reconWTF --install
```

# Файл конфигурации

    * through the configuration file, you can fine-tune the entire scanning process
    * configure timeout, threads, API token, scanning tools, ports, number of threads, and much more.

# ИСПОЛЬЗОВАНИЕ:

    !Настройте файл конфигурации (config.conf) и укажите в нем API-ключи.

    ./reconwtf.sh -h

    Usage: ./reconwtf.sh [options...] -d <domain> -m <companu tld>-l <list.txt> -x <scope.txt> -c <cookie> -cidr <cidr>
                -r -s -p -a -o -v -h

# ОПЦИИ

| Флаг | Описание |
|------|-------------|
| -d, --domain | целевой домен 'example.com' |
| -m, --company | имя компании 'Tesla inc' см. https://www.whoxy.com/tesla.com |
| -cidr, --cidr | диапазон IP-адресов цели '192.49,128.0/16' |
| -x, --scope | формат диапазона (out of scope), например, 'egrep .vk.com' - удалить все поддомены vk.com; 'clear vk subdomain \vk.com' - очистить все vk.com |
| -c, --cookie | cookie -c 'PHPSESSIONID=qweqweqwe' |

**SCANNING METHODS**

| Флаг | Описание |
|------|-------------|
| -r, --recon-full | полное исследование цели (с использованием атак) |
| -s, --subdomain-search | только поиск поддоменов, разрешение и захват поддоменов |
| -p, --passive | только пассивные методы, не влияющие на цель |
| -a, --active | полный анализ с использованием атак |
| -o, --osint | минимальное исследование с использованием OSINT |


**GENERAL OPTIONS**

| Флаг | Описание |
|------|-------------|
| -in, --install | Установить все инструменты |
| -ct, --check-tools | Проверить, правильно ли установлены инструменты |
| -g, --config | файл конфигурации '-g dir/config2.conf' |
|-v, --version | версия reconWTF |
| -h, --help | справка |


# ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ:

**Провести полное разведывание цели**

```bash
./reconwtf.sh -d "target.com" -a
```
 
**Провести полное разведывание цели, используя файл scope**
 
```bash
cat scope_domain.txt
    
    example.com
    *.api.example.com
    dev.example.com

./reconwtf.sh -d "target.com" --scope /scope_domain.txt -a 
```
 
**Провести только исследование OSINT**
 
```bash
./reconwtf.sh -d "target.com" -o
```
**Провести полное разведывание цели, используя куки**
 
```bash
./reconwtf.sh -d "target.com" -m "Target INC" -cidr "192.168.0.1/16" -c "PHPSESSIONID=XXXXXXXXX"
```

**Запустить пример с указанием всех важных настроек**

```bash
./reconwtf.sh -d "target.com" -m "Target INC" -cidr "192.168.0.1/16" -c "PHPSESSIONID=XXXXXXXXX" -x /home/OutOfScope.txt --config config/config.conf --recon-full
```

**Показать справочную секцию**
 
```bash
./reconwtf.sh -h
```
**Загрузить собранную информацию на GitHub**

* Создайте репозиторий с названием "recon".
* Получите токен GitHub. внесите на Github ваши публичный ключ, в систему сохраните приватный где работает инсрумент
* Заполните файл config.conf этой информацией.
* сколнируйте ваш приватный репозиторий recon


# ИСПОЛЬЗУЕМЫЕ УТИЛИТЫ И МЕТОДЫ РАЗВЕДКИ

## СБОР ИНФОРМАЦИИ

* Получение IP-адресов поддоменов (dig).
* Определение облачного провайдера по IP-адресу (ip2provider).
* Информация о домене (DHVAdmin).
* Проверка WAF (wafw00f).
* Поиск слабых звеньев в конечных точках (gf template).

## ПЕРЕЧИСЛЕНИЕ ПОДДОМЕНОВ

* Пассивное перечисление поддоменов (amass, ctfr.py, sonarbyte).
* Активное перечисление поддоменов (amass, subfinder, sonarbyte).
* Брутфорс поддоменов (puredns).
* Пермутационное перечисление DNS (DNScewl, puredns).

## ПЕРЕЧИСЛЕНИЕ КОНЕЧНЫХ ТОЧЕК

* Пассивное перечисление конечных точек (sigurlfind3r, gauplus, github-endpoints).
* EАктивное перечисление конечных точек (gospider).

## ВЕБ-ПРОБИНГ

* Визуальное определение (webscreenshot.py).
* Пробивка WEB (httprobe, httpx).

## РАЗВЕДКА JAVASCRIPT

* Поиск ссылок JavaScript (linkfinder.py).
* Поиск секретов в JavaScript (SecretFinder.py).
* Скачивание JavaScript (DownloadJS.py).
* Извлечение переменных JavaScript (jsvar.sh).

## СКАНИРОВАНИЕ

* Проверка безопасности заголовков (h2t.py).
* Сканирование IP: портов (nmap, naabu).
* Идентификация используемых технологий (шаблоны nuclei, webanalyze).

## ПОИСК УЯЗВИМОСТЕЙ

* Сканирование на уязвимости (шаблоны nuclei, сценарии nmap nse, searchsploit).
* Фаззинг (ffuf).
* Проверка CORS (corsy.py).
* Поиск открытого перенаправления (openredirex.py).
* Пробивка 4xx (dirdar).

## OSINT

* Сбор электронных адресов и проверка утечек паролей (emailfinder, theHarvester.py).
* Поиск информации в репозиториях GitHub и поисковике Google, метаданных (dorks), сканирование S3 (s3scanner).

# ПРИМЕРЫ КАК СОЗДАТЬ ФАЙЛЫ

1. Out of scope

```bash
cat scope.txt

\.tesla.com # все поддомены tesla.com будут исключены из зоны видимости
\example.com # вся информация о домене example.com будет исключена из зоны видимости, включая поддомены
```

# РЕШЕНИЕ ВОЗМОЖНЫХ ПРОБЛЕМ

* required program not found or installed -> 
**Не найдена или не установлена необходимая программа -> попробуйте установить программу вручную, скрипт устанавливает все необходимые программы в $HOME/Tools/.**
**Попробуйте установить зависимости вручную: pip3 install -r requirements.txt.**


# ReconWTF БЫЛ ПРОТЕСТИРОВАН НА СЛЕДУЮЩИХ ОПЕРАЦИОННЫХ СИСТЕМАХ (install.sh и reconwtf.sh)

1. Arch linux
2. Ubuntu 22.04

# ДАЛЕЕ ПЛАНИРУЕТСЯ

- [ ] Исследование покупок компании.
- [ ] Поддержка BBRF.
- [ ] Добавить поддержку прокси-сервера Burp.
- [ ] Добавить возможность сканировать репозитории GitHub.
- [ ] Добавить функцию сканирования списка IP-адресов и диапазонов.
- [ ] Создать красивое завершение.
