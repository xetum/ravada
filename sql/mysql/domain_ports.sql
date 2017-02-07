CREATE TABLE `domain_ports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_domain` int(11),
  `public_port` int(11),
  `internal_port` int(11),
  `public_ip` varchar(255),
  `internal_ip` varchar(255),
  `name` varchar(32),
  `description` varchar(255)
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_domain` (`id_domain`),
);
