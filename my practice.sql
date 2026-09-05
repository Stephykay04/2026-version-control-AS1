CREATE TABLE Books (
id SERIAL PRIMARY KEY,
name VARCHAR(100), 
type VARCHAR(50),
pages INT
);

INSERT INTO Books (name, type, pages)
VALUES
('Friction', 'Drama', 30),
('CB', 'Fun', 20),
('The Journey', 'Adventure', 45),
('Love Story', 'Romance', 35),
('Mystery House', 'Mystery', 50);

 SELECT * FROM Books;