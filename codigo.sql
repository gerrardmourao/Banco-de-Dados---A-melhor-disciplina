-- EX 1:

DELIMITER //

CREATE PROCEDURE sp_ListarAutores()
BEGIN
    SELECT Nome, Sobrenome
    FROM Autor;
END;
//

DELIMITER ;
CALL sp_ListarAutores();

-- Eu tive que fazer uma gambiarra com o git, aí ele criou o readMe por causa disso, e também criou o primeiro commit sozinho

-- EX 2:
DELIMITER //
CREATE PROCEDURE sp_LivrosPorCategoria(IN categoria_nome VARCHAR(200))
BEGIN
    SELECT Livro.Titulo
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID WHERE Categoria.Nome = categoria_nome
END;
//

DELIMITER ;


CALL sp_LivrosPorCategoria('Romance');
CALL sp_LivrosPorCategoria('Ciência');
CALL sp_LivrosPorCategoria('Ficção Científica');
CALL sp_LivrosPorCategoria('História');
CALL sp_LivrosPorCategoria('Autoajuda');


-- EX 3:

DELIMITER //

CREATE PROCEDURE sp_ContarLivrosPorCategoria(IN categoria_nome VARCHAR(200), OUT total_livros INT)
BEGIN
    SELECT COUNT(*) INTO total_livros
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoria_nome;
END;
//

DELIMITER ;

CALL sp_ContarLivrosPorCategoria('Romance', @total_livros);
CALL sp_ContarLivrosPorCategoria('Ciência', @total_livros);
CALL sp_ContarLivrosPorCategoria('Ficção Científica', @total_livros);
CALL sp_ContarLivrosPorCategoria('História', @total_livros);
CALL sp_ContarLivrosPorCategoria('Autoajuda', @total_livros);



-- Assim como no ex2, eu fiz com todas as categorias
SELECT @total_livros;



-- EX 4:

DELIMITER //

CREATE PROCEDURE sp_VerificarLivrosCategoria(IN categoria_nome VARCHAR(200), OUT possui_livros VARCHAR(3))
BEGIN
 
    DECLARE contador INT;
    SET contador = 0;

    SELECT COUNT(*) INTO contador
    FROM Livro
    INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
    WHERE Categoria.Nome = categoria_nome;

    IF contador > 0 THEN
        SET possui_livros = 'Sim';
    ELSE
        SET possui_livros = 'Não';
    END IF;
END;
//

DELIMITER ;

CALL sp_VerificarLivrosCategoria('Romance', @possui_livros);
CALL sp_VerificarLivrosCategoria('Ciência', @possui_livros);
CALL sp_VerificarLivrosCategoria('Ficção Científica',@possui_livros);
CALL sp_VerificarLivrosCategoria('História', @possui_livros);
CALL sp_VerificarLivrosCategoria('Autoajuda', @possui_livros);

SELECT @possui_livros;


-- EX 5:
DELIMITER //

CREATE PROCEDURE sp_LivrosAteAno(IN ano_limite INT)
BEGIN
    -- Listar todos os livros publicados até o ano especificado
    SELECT Titulo, Ano_Publicacao
    FROM Livro
    WHERE Ano_Publicacao <= ano_limite;
END;
//

DELIMITER ;

CALL sp_LivrosAteAno(1999);

--no caso eu coloquei o 1999 só de exemplo

-- --------------------------------------------------------------------------------------------
-- EX 6:

DELIMITER //

CREATE PROCEDURE sp_TitulosPorCategoria(IN categoria_nome VARCHAR(200))
BEGIN

    DECLARE livro_titulo VARCHAR(255);

    DECLARE cursor_livros CURSOR FOR
        SELECT Titulo
        FROM Livro
        INNER JOIN Categoria ON Livro.Categoria_ID = Categoria.Categoria_ID
        WHERE Categoria.Nome = categoria_nome;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET livro_titulo = NULL;
    
    OPEN cursor_livros;
    read_loop: LOOP
        FETCH cursor_livros INTO livro_titulo;
        IF livro_titulo IS NULL THEN
            LEAVE read_loop;
        END IF;
        SELECT livro_titulo;
    END LOOP;
    CLOSE cursor_livros;
END;
//

DELIMITER ;

CALL sp_TitulosPorCategoria('Romance');

-- --------------------------------------------------------------------------------------------------------------------------


-- EX 7:

DELIMITER //

CREATE PROCEDURE sp_AdicionarLivro(
    IN titulo_livro VARCHAR(255),
    IN editora_id INT,
    IN ano_publicacao INT,
    IN numero_paginas INT,
    IN categoria_id INT
)
BEGIN
    
    IF titulo_livro IS NULL OR editora_id IS NULL OR ano_publicacao IS NULL OR numero_paginas IS NULL OR categoria_id IS NULL THEN
        SELECT 'Erro: Nenhum dos parâmetros pode ser nulo.' AS Status;
    ELSE
        IF EXISTS (SELECT 1 FROM Livro WHERE Titulo = titulo_livro) THEN
            SELECT 'Erro: O livro com esse título já existe na tabela.' AS Status;
        ELSE
            INSERT INTO Livro (Titulo, Editora_ID, Ano_Publicacao, Numero_Paginas, Categoria_ID)
            VALUES (titulo_livro, editora_id, ano_publicacao, numero_paginas, categoria_id);

            SELECT 'Livro adicionado com sucesso.' AS Status;
        END IF;
    END IF;
END;
//

DELIMITER ;

CALL sp_AdicionarLivro('Na sala dos espelhos: Autoimagem em transe ou beleza e autenticidade como mercadoria na era dos likes & outras encenações do eu', 1, 2016, 374, 1);

-- ---------------------------------------------------------------------------------------------------------------------------------------------


-- EX 8:
DELIMITER //

CREATE PROCEDURE sp_AutorMaisAntigo(OUT nome_autor VARCHAR(255))
BEGIN
    DECLARE data_nascimento_antiga DATE;
    DECLARE nome_autor_antigo VARCHAR(255);
    SET data_nascimento_antiga = NULL;
    DECLARE EXIT HANDLER FOR NOT FOUND SET nome_autor_antigo = NULL;
    
    DECLARE cursor_autor CURSOR FOR
    SELECT Nome, Data_Nascimento
    FROM Autor
    WHERE Data_Nascimento IS NOT NULL;

  
    OPEN cursor_autor;

    autor_loop: LOOP
        FETCH cursor_autor INTO nome_autor_antigo, data_nascimento_antiga;
        IF nome_autor_antigo IS NULL THEN
            LEAVE autor_loop;
        END IF;


        IF data_nascimento_antiga IS NULL OR data_nascimento_antiga > data_nascimento_antiga THEN
            SET data_nascimento_antiga = data_nascimento_antiga;
            SET nome_autor = nome_autor_antigo;
        END IF;
    END LOOP autor_loop;
    CLOSE cursor_autor;
END;
//

DELIMITER ;


CALL sp_AutorMaisAntigo(@nome_autor_mais_antigo);
SELECT @nome_autor_mais_antigo AS 'Nome do Autor Mais Antigo';

-- ---------------------------------------------------------------------------------------------------------------------------------------



-- EX 9:

-- A stored procedure sp_VerificarLivrosCategoria recebe um parâmetro chamado categoria_nome, que é o nome da categoria que queremos verificar.

-- Ela usa uma variável contador para contar quantos livros estão associados a essa categoria.

-- Através de uma consulta SQL, ela verifica quantos livros na tabela Livro estão relacionados com a categoria fornecida.

-- Se o contador for maior que zero, a stored procedure define a variável de saída possui_livros como 'Sim', o que significa que a categoria 
possui livros.

-- Caso contrário, se o contador for igual a zero, a variável de saída possui_livros é definida como 'Não', indicando que a categoria não possui livros associados.

-- A stored procedure retorna o valor da variável possui_livros.

Portanto, ao chamar a stored procedure sp_VerificarLivrosCategoria e fornecer o nome de uma categoria como parâmetro, você obterá 'Sim' se houver livros associados a essa categoria e 'Não' se não houver. Isso é útil para verificar facilmente se uma categoria está vazia ou não em seu banco de dados de livros.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- EX 10:

DELIMITER //

CREATE PROCEDURE sp_LivrosESeusAutores()
BEGIN
    -- Variáveis para armazenar informações do livro e do autor
    DECLARE livro_titulo VARCHAR(255);
    DECLARE autor_nome VARCHAR(255);
    DECLARE autor_sobrenome VARCHAR(255);
    
    -- Cursor para percorrer os livros e seus autores
    DECLARE cursor_livros CURSOR FOR
    SELECT Livro.Titulo, Autor.Nome, Autor.Sobrenome
    FROM Livro
    INNER JOIN Autor_Livro ON Livro.Livro_ID = Autor_Livro.Livro_ID
    INNER JOIN Autor ON Autor_Livro.Autor_ID = Autor.Autor_ID;

    -- Inicializar o cursor
    OPEN cursor_livros;

    -- Resultado da consulta
    SELECT 'Título do Livro', 'Nome do Autor', 'Sobrenome do Autor';

    -- Loop para listar os livros e autores
    livros_autor_loop: LOOP
        FETCH cursor_livros INTO livro_titulo, autor_nome, autor_sobrenome;
        IF livro_titulo IS NULL THEN
            LEAVE livros_autor_loop;
        END IF;
        
        -- Exibir os detalhes do livro e autor
        SELECT livro_titulo, autor_nome, autor_sobrenome;
    END LOOP livros_autor_loop;

    -- Fechar o cursor
    CLOSE cursor_livros;
END;
//

DELIMITER ;

-- Chamada da stored procedure sp_LivrosESeusAutores
CALL sp_LivrosESeusAutores();
