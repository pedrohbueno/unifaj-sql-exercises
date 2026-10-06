DROP DATABASE IF EXISTS BD_S4_B1_EX8;
CREATE DATABASE BD_S4_B1_EX8;
USE BD_S4_B1_EX8;

-- 1
CREATE TABLE tabuada (
    id INT NOT NULL AUTO_INCREMENT,
    n1 INT NOT NULL,
    n2 INT NOT NULL,
    resultado INT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE automovel (
    id INT NOT NULL AUTO_INCREMENT,
    carro_moto VARCHAR(1) NOT NULL,
    placa VARCHAR(7) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    proprietario VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);

-- 2
DELIMITER $$
CREATE PROCEDURE sp_preencher_tabuada()
BEGIN
    DECLARE v_n1 INT DEFAULT 1;
    DECLARE v_n2 INT;

    WHILE v_n1 <= 10 DO
        SET v_n2 = 1;
        WHILE v_n2 <= 10 DO
            INSERT INTO tabuada (n1, n2, resultado)
            VALUES (v_n1, v_n2, v_n1 * v_n2);
            SET v_n2 = v_n2 + 1;
        END WHILE;
        SET v_n1 = v_n1 + 1;
    END WHILE;
END$$
DELIMITER ;

-- 3
CALL sp_preencher_tabuada();
SELECT * FROM tabuada;

-- 4
DELIMITER $$
CREATE PROCEDURE sp_buscar_tabuada(
    IN p_n1 INT,
    IN p_n2 INT,
    OUT p_id INT
)
BEGIN
    SET p_id = NULL;
    SELECT id INTO p_id
    FROM tabuada
    WHERE n1 = p_n1 AND n2 = p_n2
    LIMIT 1;
END$$
DELIMITER ;

-- 5
CALL sp_buscar_tabuada(3, 4, @id_tabuada);
SELECT @id_tabuada AS id_tabuada;

-- 6
DELIMITER $$
CREATE PROCEDURE sp_numero(INOUT p_numero INT)
BEGIN
    DECLARE v_i INT DEFAULT 2;
    DECLARE v_primo BOOLEAN;
    DECLARE v_qtd INT;

    SET v_primo = (p_numero >= 2);

    WHILE v_primo AND v_i * v_i <= p_numero DO
        IF p_numero % v_i = 0 THEN
            SET v_primo = FALSE;
        END IF;
        SET v_i = v_i + 1;
    END WHILE;

    IF NOT v_primo THEN
        SELECT COUNT(*) INTO v_qtd
        FROM tabuada
        WHERE resultado = p_numero;

        SET p_numero = p_numero * v_qtd;
    END IF;
END$$
DELIMITER ;

-- 7
SET @primo = 7;
CALL sp_numero(@primo);
SELECT @primo AS resultado_numero_primo;

SET @na_tabuada = 12;
CALL sp_numero(@na_tabuada);
SELECT @na_tabuada AS resultado_numero_na_tabuada;

SET @fora_tabuada = 22;
CALL sp_numero(@fora_tabuada);
SELECT @fora_tabuada AS resultado_numero_fora_da_tabuada;

-- 8
DELIMITER $$
CREATE PROCEDURE sp_automovel(
    IN p_acao VARCHAR(10),
    IN p_id INT,
    IN p_carro_moto VARCHAR(1),
    IN p_placa VARCHAR(7),
    IN p_marca VARCHAR(50),
    IN p_modelo VARCHAR(50),
    IN p_proprietario VARCHAR(100)
)
BEGIN
    IF p_acao = 'INSERIR' THEN
        IF EXISTS (SELECT 1 FROM automovel WHERE placa = p_placa) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro - Placa já cadastrada';
        END IF;

        INSERT INTO automovel (carro_moto, placa, marca, modelo, proprietario)
        VALUES (p_carro_moto, p_placa, p_marca, p_modelo, p_proprietario);

    ELSEIF p_acao = 'ATUALIZAR' THEN
        IF NOT EXISTS (SELECT 1 FROM automovel WHERE id = p_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro - Id não existe';
        END IF;

        UPDATE automovel
        SET carro_moto = p_carro_moto,
            placa = p_placa,
            marca = p_marca,
            modelo = p_modelo,
            proprietario = p_proprietario
        WHERE id = p_id;

    ELSEIF p_acao = 'EXCLUIR' THEN
        IF NOT EXISTS (SELECT 1 FROM automovel WHERE id = p_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro - Id não existe';
        END IF;

        DELETE FROM automovel WHERE id = p_id;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro - Ação desconhecida';
    END IF;
END$$
DELIMITER ;

-- 9
CALL sp_automovel('INSERIR', NULL, 'C', 'ABC1234', 'Fiat', 'Uno', 'João Silva');
SELECT * FROM automovel;

-- erro esperado (placa já cadastrada)
CALL sp_automovel('INSERIR', NULL, 'C', 'ABC1234', 'Fiat', 'Palio', 'Maria Souza');

CALL sp_automovel('ATUALIZAR', 1, 'C', 'ABC1234', 'Fiat', 'Palio', 'João Silva');
SELECT * FROM automovel;

-- erro esperado (id não existe)
CALL sp_automovel('ATUALIZAR', 99, 'C', 'XYZ9876', 'Fiat', 'Uno', 'João Silva');

CALL sp_automovel('EXCLUIR', 1, NULL, NULL, NULL, NULL, NULL);
SELECT * FROM automovel;

-- erro esperado (id não existe)
CALL sp_automovel('EXCLUIR', 99, NULL, NULL, NULL, NULL, NULL);

-- erro esperado (ação desconhecida)
CALL sp_automovel('CONSULTAR', 1, NULL, NULL, NULL, NULL, NULL);
