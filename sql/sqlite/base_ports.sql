CREATE TABLE `base_ports` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `id_domain` integer
,  `port` integer
,  `name` varchar(32)
,  `description` varchar(255)
,  UNIQUE (`id_domain`,`port`)
,  UNIQUE (`id_domain`,`name`)
);
