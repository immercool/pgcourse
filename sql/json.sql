CREATE TABLE books (
  book_id serial NOT NULL,
  data jsonb
);

INSERT INTO books VALUES (1, '{"title": "Sleeping Beauties", "genres": ["Fiction", "Thriller", "Horror"], "published": false}');
INSERT INTO books VALUES (2, '{"title": "Influence", "genres": ["Marketing & Sales", "Self-Help ", "Psychology"], "published": true}');
INSERT INTO books VALUES (3, '{"title": "The Dictator''s Handbook", "genres": ["Law", "Politics"], "authors": ["Bruce Bueno de Mesquita", "Alastair Smith"], "published": true}');
INSERT INTO books VALUES (4, '{"title": "Deep Work", "genres": ["Productivity", "Reference"], "published": true}');
INSERT INTO books VALUES (5, '{"title": "Siddhartha", "genres": ["Fiction", "Spirituality"], "published": true}');


--Query Data
SELECT data->'title' AS title FROM books;

--Filter Results
SELECT * FROM books WHERE data->'published' = 'false';

--Expand Data
SELECT jsonb_array_elements_text(data->'genres') AS genre
FROM books
WHERE book_id = 1;
