/
├── 01_create_and_insert.sql
├── 02_selects.sql
├── 03_updates_deletes.sql
└── README.md
-- ============================
-- CRIAÇÃO DO BANCO
-- ============================
CREATE DATABASE suportenow;
\c suportenow;

-- ============================
-- TABELAS
-- ============================

CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cargo VARCHAR(100),
    setor VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    telefone VARCHAR(20)
);

CREATE TABLE filial (
    id_filial SERIAL PRIMARY KEY,
    nome_filial VARCHAR(150) NOT NULL,
    endereco VARCHAR(255),
    cidade VARCHAR(100),
    uf CHAR(2)
);

CREATE TABLE suporte (
    id_suporte SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cargo VARCHAR(100),
    setor VARCHAR(100),
    email VARCHAR(150),
    telefone VARCHAR(20)
);

CREATE TABLE chamado (
    id_chamado SERIAL PRIMARY KEY,
    categoria VARCHAR(20) NOT NULL CHECK (categoria IN ('Urgente','Pouco urgente')),
    descricao TEXT NOT NULL,
    tipo_problema VARCHAR(50),
    data_abertura TIMESTAMP NOT NULL DEFAULT NOW(),
    data_fechamento TIMESTAMP,
    status VARCHAR(30) NOT NULL,
    id_usuario INT NOT NULL REFERENCES usuario(id_usuario),
    id_filial INT REFERENCES filial(id_filial)
);

CREATE TABLE atendimento (
    id_atendimento SERIAL PRIMARY KEY,
    id_chamado INT NOT NULL REFERENCES chamado(id_chamado),
    id_suporte INT NOT NULL REFERENCES suporte(id_suporte),
    data_atendimento TIMESTAMP NOT NULL DEFAULT NOW(),
    tempo_resposta_min INT CHECK (tempo_resposta_min >= 0),
    tempo_solucao_min INT CHECK (tempo_solucao_min >= 0),
    observacoes TEXT
);

-- ============================
-- INSERTS — USUÁRIOS
-- ============================

INSERT INTO usuario (nome, cargo, setor, email, telefone) VALUES
('Ana Rodrigues', 'Analista', 'Financeiro', 'ana@empresa.com', '11988774466'),
('Carlos Silva', 'Assistente', 'RH', 'carlos@empresa.com', '11988771122'),
('Mariana Oliveira', 'Supervisor', 'TI', 'mariana@empresa.com', '11955667788');

-- ============================
-- INSERTS — FILIAIS
-- ============================

INSERT INTO filial (nome_filial, endereco, cidade, uf) VALUES
('Filial São Paulo', 'Av. Paulista, 1000', 'São Paulo', 'SP'),
('Filial Rio de Janeiro', 'Rua das Laranjeiras, 55', 'Rio de Janeiro', 'RJ');

-- ============================
-- INSERTS — SUPORTE
-- ============================

INSERT INTO suporte (nome, cargo, setor, email, telefone) VALUES
('João Santos', 'Técnico N1', 'Suporte', 'joao@empresa.com', '11999998877'),
('Beatriz Lima', 'Técnica N2', 'Suporte', 'bia@empresa.com', '21992223344');

-- ============================
-- INSERTS — CHAMADOS
-- ============================

INSERT INTO chamado (categoria, descricao, tipo_problema, status, id_usuario, id_filial)
VALUES
('Urgente', 'Computador não liga', 'hardware', 'Aberto', 1, 1),
('Pouco urgente', 'Erro no sistema de ponto', 'sistema', 'Em andamento', 2, 1),
('Urgente', 'Sistema travando constantemente', 'sistema', 'Aberto', 3, 2);

-- ============================
-- INSERTS — ATENDIMENTO
-- ============================

INSERT INTO atendimento (id_chamado, id_suporte, tempo_resposta_min, tempo_solucao_min, observacoes)
VALUES
(1, 1, 10, 45, 'Máquina reiniciada, trocado cabo de energia'),
(2, 2, 30, 0, 'Chamado em estudo'),
(3, 1, 5, 15, 'Limpeza do sistema e atualização realizada');
-- 1) Listar todos os chamados com nome do usuário e nome da filial
SELECT c.id_chamado, u.nome AS usuario, f.nome_filial, c.categoria, c.status
FROM chamado c
JOIN usuario u ON c.id_usuario = u.id_usuario
LEFT JOIN filial f ON c.id_filial = f.id_filial
ORDER BY c.id_chamado;

-- 2) Buscar chamados urgentes ainda abertos
SELECT id_chamado, descricao, status
FROM chamado
WHERE categoria = 'Urgente'
  AND status != 'Resolvido';

-- 3) Listar os 5 chamados mais recentes
SELECT id_chamado, descricao, data_abertura
FROM chamado
ORDER BY data_abertura DESC
LIMIT 5;

-- 4) Quantidade de chamados por categoria
SELECT categoria, COUNT(*) AS total
FROM chamado
GROUP BY categoria;

-- 5) Detalhar atendimentos com tempo de solução e técnico responsável
SELECT a.id_atendimento, s.nome AS tecnico, a.data_atendimento,
       a.tempo_resposta_min, a.tempo_solucao_min
FROM atendimento a
JOIN suporte s ON a.id_suporte = s.id_suporte
ORDER BY a.data_atendimento DESC;
-- ============================
-- UPDATES
-- ============================

-- 1) Atualizar status de um chamado após solução
UPDATE chamado
SET status = 'Resolvido', data_fechamento = NOW()
WHERE id_chamado = 1;

-- 2) Ajustar o setor de um usuário
UPDATE usuario
SET setor = 'Tecnologia'
WHERE nome = 'Ana Rodrigues';

-- 3) Atualizar tempo de solução de um atendimento
UPDATE atendimento
SET tempo_solucao_min = 60, observacoes = 'Ajuste após revisão'
WHERE id_atendimento = 2;

-- ============================
-- DELETES
-- ============================

-- 1) Apagar um atendimento antigo
DELETE FROM atendimento
WHERE id_atendimento = 3;

-- 2) Remover uma filial sem chamados associados
DELETE FROM filial
WHERE id_filial = 2
  AND id_filial NOT IN (SELECT id_filial FROM chamado);

-- 3) Excluir um suporte sem atendimentos vinculados
DELETE FROM suporte
WHERE id_suporte = 2
  AND id_suporte NOT IN (SELECT id_suporte FROM atendimento);
