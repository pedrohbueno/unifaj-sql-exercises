DROP DATABASE IF EXISTS BD_S4_B1_EX5;
CREATE DATABASE BD_S4_B1_EX5;
USE BD_S4_B1_EX5;

-- 1
CREATE TABLE pessoa (
    id INT NOT NULL,
    nome VARCHAR(45) NOT NULL,
    profissao VARCHAR(45) NOT NULL,
    cnh VARCHAR(1) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE automovel (
    id INT NOT NULL,
    carro_moto VARCHAR(1) NOT NULL,
    modelo VARCHAR(45) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    id_pessoa INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_pessoa) REFERENCES pessoa (id)
);

-- 2
INSERT INTO pessoa (id, nome, profissao, cnh) VALUES
    (1, 'Ana', 'Desenvolvedor', 'S'),
    (2, 'Bruno', 'Médico', 'S'),
    (3, 'Carla', 'Professor', 'N'),
    (4, 'Diego', 'Advogado', 'S'),
    (5, 'Elisa', 'Engenheiro', 'N'),
    (6, 'Fábio', 'Médico', 'S');

INSERT INTO automovel (id, carro_moto, modelo, preco, id_pessoa) VALUES
    (1, 'C', 'Civic', 95000.00, 1),
    (2, 'M', 'CG 160', 14000.00, 1),
    (3, 'C', 'Onix', 70000.00, 2),
    (4, 'C', 'Corolla', 120000.00, 4),
    (5, 'M', 'Biz', 12000.00, 4),
    (6, 'C', 'Gol', 30000.00, 6);

-- 3
SELECT id, nome, profissao,
       CASE WHEN cnh = 'S' THEN 'Sim' ELSE 'Não' END AS cnh
FROM pessoa;

-- 4
SELECT p.nome, COUNT(a.id) AS qtd_automoveis
FROM pessoa p
LEFT JOIN automovel a ON a.id_pessoa = p.id
GROUP BY p.id, p.nome;

-- 5
SELECT p.nome,
       CASE a.carro_moto
            WHEN 'C' THEN 'Carro'
            WHEN 'M' THEN 'Moto'
       END AS tipo,
       a.modelo
FROM pessoa p
LEFT JOIN automovel a ON a.id_pessoa = p.id;

-- 6
CREATE TABLE pessoa_automovel (
    nome VARCHAR(45) NOT NULL,
    modelo VARCHAR(45) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

-- 7
INSERT INTO pessoa_automovel (nome, modelo, preco)
SELECT p.nome, a.modelo, a.preco
FROM pessoa p
INNER JOIN automovel a ON a.id_pessoa = p.id
WHERE p.id IN (SELECT id_pessoa FROM automovel);

-- 8
SELECT p.nome, SUM(a.preco) AS preco_total
FROM pessoa p
INNER JOIN automovel a ON a.id_pessoa = p.id
GROUP BY p.id, p.nome
ORDER BY preco_total DESC;

-- 9
UPDATE automovel
SET preco = 98000.00
WHERE id = 1;

-- 10
SET SQL_SAFE_UPDATES = 0;

UPDATE pessoa_automovel
SET preco = (SELECT a.preco FROM automovel a WHERE a.id = 1)
WHERE modelo = (SELECT a.modelo FROM automovel a WHERE a.id = 1);

-- 11
SELECT nome, modelo, preco
FROM pessoa_automovel
WHERE nome IN (
    SELECT nome FROM pessoa
    WHERE profissao IN ('Desenvolvedor', 'Médico')
);

-- 12
CREATE INDEX idx_pessoa_automovel_modelo ON pessoa_automovel (modelo);

-- 13
SELECT p.nome, p.profissao
FROM pessoa p
WHERE p.nome NOT IN (SELECT nome FROM pessoa_automovel);
