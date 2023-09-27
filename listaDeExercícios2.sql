EX 1:

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
