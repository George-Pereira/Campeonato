CREATE DATABASE championship
GO
USE championship
CREATE TABLE times
(
codigo		INT IDENTITY,
times		VARCHAR(150),
sigla		CHAR(3),
PRIMARY KEY (codigo)
)
CREATE TABLE confronto
(
timeA		INT,
timeB		INT,
golsA		INT,
golsB		INT,
horaJogo	datetime,
FOREIGN KEY (timeA) REFERENCES times(codigo),
FOREIGN KEY (timeB) REFERENCES times(codigo),
CONSTRAINT pk_confronto primary key(timeA, timeB, horaJogo)
)
CREATE TABLE campeonato
(
cod_time		INT,
jogos			INT,
vitorias		INT,
empates			INT,
derrotas		INT,
golsPro			INT,
golsContra		INT,
PRIMARY KEY (cod_time),
FOREIGN KEY (cod_time) REFERENCES times(codigo)
)

CREATE TRIGGER tr_atualizaTabelaCamp ON times
FOR INSERT
AS
BEGIN
	DECLARE @cod_tim	INT,
			@status		INT
	SELECT @cod_tim = codigo FROM inserted
	INSERT INTO campeonato VALUES(@cod_tim, 0, 0, 0, 0, 0, 0)
END

CREATE TRIGGER tr_atualizaConfrontos ON confronto
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @cod_timeA	INT,
			@cod_timeB  INT,
			@golsA		INT,
			@golsB		INT
	SELECT @cod_timeA = timeA, @cod_timeB = timeB, @golsA = golsA, @golsB = golsB FROM inserted
	UPDATE campeonato SET golsContra = (golsContra + @golsB), golsPro = (golsPro + @golsA), jogos = (jogos + 1) WHERE cod_time = @cod_timeA 
	UPDATE campeonato SET golsContra = (golsContra + @golsA), golsPro = (golsPro + @golsB), jogos = (jogos + 1) WHERE cod_time = @cod_timeB
	IF(@golsA > @golsB)
	BEGIN
		UPDATE campeonato SET vitorias = (vitorias + 1) WHERE cod_time = @cod_timeA
		UPDATE campeonato SET derrotas = (derrotas + 1) WHERE cod_time = @cod_timeB
	END
	ELSE
	BEGIN
		IF(@golsA = @golsB)
		BEGIN
			UPDATE campeonato SET empates = (empates + 1) WHERE cod_time = @cod_timeA
			UPDATE campeonato SET empates = (empates + 1) WHERE cod_time = @cod_timeB
		END
		ELSE
		BEGIN
			UPDATE campeonato SET vitorias = (vitorias + 1) WHERE cod_time = @cod_timeB
			UPDATE campeonato SET derrotas = (derrotas + 1) WHERE cod_time = @cod_timeA
		END
	END
END

DROP TABLE times
DROP TABLE campeonato
DROP TABLE confronto

INSERT INTO times VALUES
('Barcelona', 'BAR')
('Celta de Vigo', 'CEL')
('Málaga', 'MAL')
('Real Madrid', 'RMA')
SELECT * FROM times
SELECT * FROM confronto
SELECT * FROM campeonato

insert into confronto values(1,2,2,3,'04/22/2013 15:00')
insert into confronto values(1,3,4,3,'04/29/2013 15:00')
insert into confronto values(1,4,5,3,'05/06/2013 15:00')
insert into confronto values(2,1,0,3,'04/25/2013 15:00')
insert into confronto values(2,3,2,0,'04/02/2013 15:00')
insert into confronto values(2,4,3,3,'05/09/2013 15:00')
insert into confronto values(3,1,2,3,'05/12/2013 15:00')
insert into confronto values(3,2,3,1,'05/15/2013 15:00')
insert into confronto values(3,4,0,1,'05/18/2013 15:00')
insert into confronto values(4,1,0,3,'05/23/2013 15:00')
insert into confronto values(4,2,4,0,'05/27/2013 15:00')
insert into confronto values(4,3,2,0,'05/31/2013 15:00')

CREATE FUNCTION fn_campeonato()
RETURNS @tabela TABLE
(
sigla		CHAR(3),
jogos		INT,
vitorias	INT,
empates		INT,
derrotas	INT,
gols_pro	INT,
gols_contra INT,
pontos		INT
)
AS
BEGIN
	INSERT INTO @tabela
		SELECT sigla = tm.sigla, jogos = camp.jogos, vitorias = camp.vitorias, empates = camp.empates, 
		derrotas = camp.derrotas, gols_pro = camp.golspro, gols_contra = camp.golsContra, pontos = 0 FROM times tm 
		INNER JOIN campeonato camp ON tm.codigo = camp.cod_time
	UPDATE @tabela SET pontos = empates + (vitorias * 3) 
	RETURN
END
DROP FUNCTION fn_campeonato
SELECT * FROM fn_campeonato()