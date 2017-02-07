CREATE TABLE `domain_ports` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT
,  `id_domain` integer
,  `public_port` integer
,  `internal_port` integer
,  `public_ip` varchar(255)
,  `internal_ip` varchar(255)
,  `name` varchar(32)
,  `description` varchar(255)
,  UNIQUE (`id_domain`)
);
