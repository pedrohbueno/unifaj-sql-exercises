DROP DATABASE IF EXISTS BD_S4_B1_EX4;
CREATE DATABASE BD_S4_B1_EX4;
USE BD_S4_B1_EX4;

-- 1
CREATE TABLE pai (
    id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE filho (
    id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    id_pai INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_pai) REFERENCES pai (id)
);

-- 2
INSERT INTO pai (id, nome) VALUES
    (1, 'João'),
    (2, 'Maria'),
    (3, 'Carlos'),
    (4, 'Ana'),
    (5, 'José');

INSERT INTO filho (id, nome, id_pai) VALUES
    (1, 'Pedro', 1),
    (2, 'Ana', 1),
    (3, 'Maria', 2),
    (4, 'Lucas', 3),
    (5, 'Pedro', 4),
    (6, 'Carlos', 1),
    (7, 'Julia', 5),
    (8, 'Lucas', 5);

-- 3
SELECT p.nome AS nome_pai, f.nome AS nome_filho
FROM pai p
INNER JOIN filho f ON f.id_pai = p.id;

-- 4
SELECT nome FROM pai
UNION ALL
SELECT nome FROM filho
ORDER BY nome ASC;

-- 5
SELECT nome FROM pai
UNION
SELECT nome FROM filho;

-- 6
SELECT DISTINCT p.nome
FROM pai p
INNER JOIN filho f ON f.nome = p.nome;

-- 7
SELECT DISTINCT p.nome
FROM pai p
WHERE NOT EXISTS (SELECT 1 FROM filho f WHERE f.nome = p.nome);

-- 8
SELECT DISTINCT p.nome
FROM pai p
WHERE NOT EXISTS (SELECT 1 FROM filho f WHERE f.nome = p.nome)
UNION
SELECT DISTINCT f.nome
FROM filho f
WHERE NOT EXISTS (SELECT 1 FROM pai p WHERE p.nome = f.nome);

-- 9
SELECT p.nome AS nome_pai, COUNT(f.id) AS qtd_filhos
FROM pai p
LEFT JOIN filho f ON f.id_pai = p.id
GROUP BY p.id, p.nome;

-- 10
SELECT nome, COUNT(*) AS qtd_pessoas
FROM (
    SELECT nome FROM pai
    UNION ALL
    SELECT nome FROM filho
) AS pessoas
GROUP BY nome
ORDER BY nome;

-- 11
SELECT p.nome
FROM pai p
INNER JOIN filho f ON f.id_pai = p.id
GROUP BY p.id, p.nome
HAVING COUNT(f.id) >= 2;

-- 12
WITH qtd_filhos_por_pai AS (
    SELECT id_pai, COUNT(*) AS qtd
    FROM filho
    GROUP BY id_pai
)
SELECT p.nome
FROM pai p
INNER JOIN qtd_filhos_por_pai q ON q.id_pai = p.id
WHERE q.qtd >= 2;

-- 13
CREATE TABLE pai_filho (
    nome_pai VARCHAR(100) NOT NULL,
    nome_filho VARCHAR(100) NOT NULL
);

-- 14
INSERT INTO pai_filho (nome_pai, nome_filho)
WITH relacao AS (
    SELECT p.nome AS nome_pai, f.nome AS nome_filho
    FROM pai p
    INNER JOIN filho f ON f.id_pai = p.id
)
SELECT nome_pai, nome_filho
FROM relacao;

SELECT * FROM pai_filho;