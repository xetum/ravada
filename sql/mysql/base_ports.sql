CREATE TABLE `base_ports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_domain` int(11),
  `port` int(11),
  `name` varchar(32),
  `description` varchar(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_domain_port` (`id_domain`,`port`),
  UNIQUE KEY `id_domain_name` (`id_domain`,`name`)
);
