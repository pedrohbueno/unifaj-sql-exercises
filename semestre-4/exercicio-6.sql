DROP DATABASE IF EXISTS BD_S4_B1_EX6;
CREATE DATABASE BD_S4_B1_EX6;
USE BD_S4_B1_EX6;

-- 1
CREATE TABLE filme (
    id INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    diretor VARCHAR(100) NOT NULL,
    ano_lancamento INT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE personagem (
    id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    especie VARCHAR(100) NOT NULL,
    nivel_importancia INT NOT NULL,
    id_filme INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_filme) REFERENCES filme (id)
);

-- 2
INSERT INTO filme (id, titulo, tipo, diretor, ano_lancamento) VALUES
    (1, 'Fúria no Deserto', 'Ação', 'Carlos Mendes', 2018),
    (2, 'Lágrimas de Verão', 'Drama', 'Marta Souza', 2021),
    (3, 'Aventura Selvagem', 'Ação', 'Carlos Mendes', 2020),
    (4, 'O Último Reino', 'Fantasia', 'Paulo Lima', 2016);

INSERT INTO personagem (id, nome, especie, nivel_importancia, id_filme) VALUES
    (1, 'Rex', 'Humano', 10, 1),
    (2, 'Lia', 'Humano', 8, 1),
    (3, 'Bolt', 'Cachorro', 5, 1),
    (4, 'Helena', 'Humano', 10, 2),
    (5, 'Tiago', 'Humano', 7, 2),
    (6, 'Nina', 'Gata', 4, 2),
    (7, 'Zara', 'Humano', 9, 3),
    (8, 'Kong', 'Gorila', 10, 3),
    (9, 'Aldo', 'Elfo', 10, 4),
    (10, 'Mira', 'Fada', 6, 4);

-- 3
SELECT f.titulo, COUNT(p.id) AS qtd_personagens
FROM filme f
LEFT JOIN personagem p ON p.id_filme = f.id
GROUP BY f.id, f.titulo;

-- 4
SELECT diretor, COUNT(*) AS qtd_filmes
FROM filme
GROUP BY diretor;

-- 5
SELECT p.nome, p.especie, p.nivel_importancia
FROM personagem p
INNER JOIN filme f ON f.id = p.id_filme
ORDER BY f.ano_lancamento ASC, p.nivel_importancia DESC;

-- 6
SELECT f.titulo, p.nome
FROM filme f
INNER JOIN personagem p ON p.id_filme = f.id
WHERE f.tipo IN ('Ação', 'Drama');

-- 7
SELECT diretor AS nome FROM filme
UNION
SELECT nome FROM personagem
ORDER BY nome ASC;

-- 8
CREATE VIEW view_filme AS
SELECT titulo, tipo
FROM filme;

-- 9
SELECT * FROM view_filme
ORDER BY titulo;

-- 10
CREATE VIEW view_personagem AS
SELECT nome, especie, id_filme
FROM personagem;

-- 11
SELECT vp.nome, f.titulo
FROM view_personagem vp
INNER JOIN filme f ON f.id = vp.id_filme;

-- 12
CREATE VIEW view_filme_personagem AS
SELECT f.titulo, f.tipo, f.diretor, f.ano_lancamento, p.nome AS nome_personagem
FROM filme f
INNER JOIN personagem p ON p.id_filme = f.id
WHERE f.ano_lancamento % 2 = 0;

-- 13
SELECT titulo
FROM filme
WHERE titulo NOT IN (SELECT titulo FROM view_filme_personagem);

-- 14
SELECT f.titulo, f.tipo, f.diretor, f.ano_lancamento, p.nome AS nome_personagem
FROM filme f
INNER JOIN personagem p ON p.id_filme = f.id
WHERE NOT EXISTS (
    SELECT 1
    FROM view_filme_personagem v
    WHERE v.titulo = f.titulo
      AND v.nome_personagem = p.nome
);
