DROP DATABASE IF EXISTS BD_S4_B1_EX7;
CREATE DATABASE BD_S4_B1_EX7;
USE BD_S4_B1_EX7;

-- 1
CREATE TABLE animal (
    id INT NOT NULL,
    especie VARCHAR(100) NOT NULL,
    nivel_feroz INT NOT NULL,
    herbivoro_carnivoro VARCHAR(1) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE animal_feroz (
    id INT NOT NULL,
    especie VARCHAR(100) NOT NULL,
    herbivoro_carnivoro VARCHAR(1) NOT NULL,
    registros INT NOT NULL,
    PRIMARY KEY (id)
);

-- 2
DELIMITER $$
CREATE TRIGGER trg_animal_before_insert
BEFORE INSERT ON animal
FOR EACH ROW
BEGIN
    IF NEW.nivel_feroz < 1 OR NEW.nivel_feroz > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: nivel_feroz deve estar entre 1 e 5';
    END IF;
END$$
DELIMITER ;

-- 3
DELIMITER $$
CREATE TRIGGER trg_animal_after_insert
AFTER INSERT ON animal
FOR EACH ROW
BEGIN
    IF NEW.nivel_feroz IN (4, 5) THEN
        INSERT INTO animal_feroz (id, especie, herbivoro_carnivoro, registros)
        VALUES (NEW.id, NEW.especie, NEW.herbivoro_carnivoro, 1);
    END IF;
END$$
DELIMITER ;

-- 4
INSERT INTO animal (id, especie, nivel_feroz, herbivoro_carnivoro) VALUES (1, 'Leão', 5, 'C');
INSERT INTO animal (id, especie, nivel_feroz, herbivoro_carnivoro) VALUES (2, 'Tigre', 4, 'C');
INSERT INTO animal (id, especie, nivel_feroz, herbivoro_carnivoro) VALUES (3, 'Coelho', 1, 'H');
INSERT INTO animal (id, especie, nivel_feroz, herbivoro_carnivoro) VALUES (4, 'Zebra', 2, 'H');
INSERT INTO animal (id, especie, nivel_feroz, herbivoro_carnivoro) VALUES (5, 'Lobo', 4, 'C');
-- erro esperado (nivel_feroz inválido)
INSERT INTO animal (id, especie, nivel_feroz, herbivoro_carnivoro) VALUES (6, 'Urso', 9, 'C');

-- 5
DELIMITER $$
CREATE TRIGGER trg_animal_before_update
BEFORE UPDATE ON animal
FOR EACH ROW
BEGIN
    IF NEW.especie <> OLD.especie THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: não é permitido alterar a espécie do animal';
    END IF;
END$$
DELIMITER ;

-- 6
-- erro esperado (mudança de espécie)
UPDATE animal SET especie = 'espécie inválida' WHERE id = 3;

-- 7
DELIMITER $$
CREATE TRIGGER trg_animal_after_update
AFTER UPDATE ON animal
FOR EACH ROW
BEGIN
    UPDATE animal_feroz
    SET registros = registros + 1
    WHERE id = NEW.id;
END$$
DELIMITER ;

-- 8
UPDATE animal SET nivel_feroz = 5 WHERE id = 2;
UPDATE animal SET nivel_feroz = 3 WHERE id = 4;

-- 9
DELIMITER $$
CREATE TRIGGER trg_animal_before_delete
BEFORE DELETE ON animal
FOR EACH ROW
BEGIN
    IF OLD.herbivoro_carnivoro = 'H' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: não é permitido apagar um animal herbívoro';
    END IF;
END$$
DELIMITER ;

-- 10
-- erro esperado (animal herbívoro)
DELETE FROM animal WHERE id = 3;

-- 11
DELIMITER $$
CREATE TRIGGER trg_animal_after_delete
AFTER DELETE ON animal
FOR EACH ROW
BEGIN
    DELETE FROM animal_feroz WHERE id = OLD.id;
END$$
DELIMITER ;

-- 12
DELETE FROM animal WHERE id = 5;

-- 13
DELIMITER $$
CREATE FUNCTION fn_animal_feroz(p_especie VARCHAR(100))
RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
    IF EXISTS (SELECT 1 FROM animal_feroz WHERE especie = p_especie) THEN
        RETURN 'Animal feroz!';
    ELSE
        RETURN 'Animal não é muito feroz!';
    END IF;
END$$
DELIMITER ;

-- 14
SELECT a.*, fn_animal_feroz(a.especie) AS feroz
FROM animal a;

-- 15
DELIMITER $$
CREATE FUNCTION fn_herbivoro_carnivoro(p_letra VARCHAR(1))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF UPPER(p_letra) = 'H' THEN
        RETURN 'Herbívoro';
    ELSEIF UPPER(p_letra) = 'C' THEN
        RETURN 'Carnívoro';
    ELSE
        RETURN 'Letra inválida';
    END IF;
END$$
DELIMITER ;

-- 16
SELECT especie, fn_herbivoro_carnivoro(herbivoro_carnivoro) AS tipo
FROM animal;
