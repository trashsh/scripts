-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Хост: localhost:3306
-- Время создания: Фев 27 2019 г., 09:33
-- Версия сервера: 5.7.25-0ubuntu0.18.04.2
-- Версия PHP: 7.2.14-1+ubuntu18.04.1+deb.sury.org+1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `lamer_webserver2`
--

-- --------------------------------------------------------

--
-- Структура таблицы `db`
--

CREATE TABLE `db` (
  `id_database` int(11) NOT NULL COMMENT 'Индекс',
  `name_db` text NOT NULL COMMENT 'Имя базы данных',
  `site_id` int(11) DEFAULT NULL COMMENT 'База данных относится к указанному сайту',
  `characterSetId_db` text NOT NULL COMMENT 'Character Set',
  `collateId_db` text NOT NULL COMMENT 'Collate',
  `id_created_db` int(11) NOT NULL COMMENT 'Кем создана база',
  `created_db` datetime NOT NULL COMMENT 'Дата и время создания базы данных',
  `last_backup_db` datetime NOT NULL COMMENT 'Дата и время последнего бэкапа'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `sites`
--

CREATE TABLE `sites` (
  `id_site` int(11) NOT NULL,
  `name_site` text NOT NULL COMMENT 'имя сайта',
  `type_site` int(11) NOT NULL COMMENT 'тип сайта',
  `owner_site` int(11) NOT NULL COMMENT 'владелец сайта',
  `created_site` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'дата и время создания сайта'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `site_type`
--

CREATE TABLE `site_type` (
  `id_site_type` int(11) NOT NULL COMMENT 'id типа сайта',
  `name_site_type` text NOT NULL COMMENT 'название типа сайта',
  `comment` text NOT NULL COMMENT 'комментарий'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `sshkeys`
--

CREATE TABLE `sshkeys` (
  `id_sshkey` int(11) NOT NULL COMMENT 'индекс',
  `id_user` int(11) NOT NULL COMMENT 'индекс пользователя',
  `openkey` text NOT NULL COMMENT 'Открытый ключ',
  `comment` text NOT NULL COMMENT 'комментарий'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL COMMENT 'индекс пользователя',
  `username` text NOT NULL COMMENT 'имя пользователя',
  `homedir` text COMMENT 'домашний каталог пользователя',
  `isAdminAccess` tinyint(4) DEFAULT NULL COMMENT 'Админ сервера?',
  `isSudo` tinyint(4) DEFAULT NULL COMMENT 'Sudo?',
  `isSshAccess` tinyint(4) DEFAULT NULL COMMENT 'доступ ssh',
  `isFtpAccess` tinyint(4) DEFAULT NULL COMMENT 'ftp-доступ',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'дата и время создания пользователя',
  `created_by` text COMMENT 'Пользователь создан следующим пользователем',
  `comment` text COMMENT 'комментарий',
  `last_change` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Дата/время последнего изменения'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `db`
--
ALTER TABLE `db`
  ADD KEY `id_database` (`id_database`),
  ADD KEY `id_created_db` (`id_created_db`);

--
-- Индексы таблицы `sites`
--
ALTER TABLE `sites`
  ADD KEY `type_site` (`type_site`),
  ADD KEY `owner_site` (`owner_site`);

--
-- Индексы таблицы `site_type`
--
ALTER TABLE `site_type`
  ADD KEY `id_site_type` (`id_site_type`);

--
-- Индексы таблицы `sshkeys`
--
ALTER TABLE `sshkeys`
  ADD PRIMARY KEY (`id_sshkey`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `db`
--
ALTER TABLE `db`
  MODIFY `id_database` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Индекс';
--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT COMMENT 'индекс пользователя', AUTO_INCREMENT=32;
--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `sites`
--
ALTER TABLE `sites`
  ADD CONSTRAINT `sites_ibfk_1` FOREIGN KEY (`type_site`) REFERENCES `site_type` (`id_site_type`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
