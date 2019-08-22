DROP PROCEDURE `practice`.`SelectStudent`;

DELIMITER $$
CREATE
    /*[DEFINER = { user | CURRENT_USER }]*/
    PROCEDURE `practice`.`SelectStudent`(IN studentid INT)
    /*LANGUAGE SQL
    | [NOT] DETERMINISTIC
    | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
    | SQL SECURITY { DEFINER | INVOKER }
    | COMMENT 'string'*/
    BEGIN
    SELECT * FROM student WHERE sid<studentid;
    END$$
    
DELIMITER ;