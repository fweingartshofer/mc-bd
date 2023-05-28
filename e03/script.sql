DROP SCHEMA IF EXISTS graph_demos CASCADE;
CREATE SCHEMA IF NOT EXISTS graph_demos;

-- simple recursion example from MariaDB documentation

CREATE TABLE IF NOT EXISTS folks
(
    id     BIGINT       NOT NULL,
    name   VARCHAR(100) NOT NULL,
    father BIGINT       NULL,
    mother BIGINT       NULL,
    PRIMARY KEY (id),
    CONSTRAINT father_fk FOREIGN KEY (father) REFERENCES folks (id),
    CONSTRAINT mother_fk FOREIGN KEY (mother) REFERENCES folks (id)
);

INSERT INTO folks (id, name, father, mother)
VALUES (100, 'Alex', 20, 30),
       (20, 'Dad', 10, null),
       (30, 'Mom', null, null),
       (10, 'Grandpa Bill', null, null),
       (98, 'Sister Amy', 20, 30);

-- demonstrates, that result set is ordered with id asc
SELECT *
FROM folks
ORDER BY id ASC;

-- demonstrate cte
WITH RECURSIVE anchestors AS (SELECT *
                              FROM folks
                              WHERE name = 'Alex'
                              UNION
                              SELECT f.*
                              FROM folks AS f
                                       JOIN anchestors AS a ON f.id = a.father OR f.id = a.mother)
SELECT *
FROM anchestors;

-- complex graph example

CREATE TABLE vertices
(
    vertex_id  BIGINT NOT NULL,
    alias      VARCHAR(255),
    label      VARCHAR(255),
    name       VARCHAR(255),
    type       VARCHAR(255),
    properties JSONB,
    PRIMARY KEY (vertex_id)
);

INSERT INTO vertices (vertex_id, alias, label, name, type)
VALUES (1, 'NAmerica', 'Location', 'North America', 'continent'),
       (2, 'Europe', 'Location', 'Europe', 'continent'),
       (3, 'USA', 'Location', 'United States', 'country'),
       (4, 'UK', 'Location', 'United Kingdom', 'country'),
       (5, 'England', 'Location', 'England', 'country'),
       (6, 'Austria', 'Location', 'Österreich', 'country'),
       (7, 'Idaho', 'Location', 'Idaho', 'state'),
       (8, 'London', 'Location', 'London', 'city'),
       (9, 'UpperAustria', 'Location', 'Oberösterreich', 'Bundesland'),
       (10, 'Waldviertel', 'Location', 'Waldviertel', 'Viertel'),
       (11, 'Grein', 'Location', 'Grein', 'city'),
       (12, 'Andrea', 'Person', 'Andrea', 'person'),
       (13, 'Bert', 'Person', 'Bert', 'person'),
       (14, 'Christian', 'Person', 'Christian', 'person');

CREATE TABLE edges
(
    edge_id     BIGINT NOT NULL,
    tail_vertex BIGINT REFERENCES vertices (vertex_id),
    head_vertex BIGINT REFERENCES vertices (vertex_id),
    label       VARCHAR(255),
    properties  JSONB,
    PRIMARY KEY (edge_id)
);

INSERT INTO edges (edge_id, tail_vertex, head_vertex, label)
VALUES (1, 3, 1, 'within'),
       (2, 4, 2, 'within'),
       (3, 5, 4, 'within'),
       (4, 6, 2, 'within'),
       (5, 7, 3, 'within'),
       (6, 8, 5, 'within'),
       (7, 9, 6, 'within'),
       (8, 10, 9, 'within'),
       (9, 11, 10, 'within'),
       (10, 12, 7, 'born_in'),
       (11, 12, 8, 'lives_in'),
       (12, 13, 11, 'born_in'),
       (13, 13, 8, 'lives_in'),
       (14, 14, 8, 'born_in'),
       (15, 12, 13, 'married'),
       (16, 13, 12, 'married');

WITH RECURSIVE
    in_usa(vertex_id) AS (SELECT vertex_id
                          FROM vertices
                          WHERE name = 'United States'
                          UNION
                          SELECT edges.tail_vertex
                          FROM edges
                                   JOIN in_usa
                                        ON edges.head_vertex = in_usa.vertex_id
                          WHERE edges.label = 'within'),
    in_europe(vertex_id) AS (SELECT vertex_id
                             FROM vertices
                             WHERE name = 'Europe'
                             UNION
                             SELECT edges.tail_vertex
                             FROM edges
                                      JOIN in_europe
                                           ON edges.head_vertex = in_europe.vertex_id
                             WHERE edges.label = 'within'),
    born_in_usa(vertex_id) AS (SELECT edges.tail_vertex
                               FROM edges
                                        JOIN in_usa
                                             ON edges.head_vertex = in_usa.vertex_id
                               WHERE edges.label = 'born_in'),
    lives_in_europe(vertex_id) AS (SELECT edges.tail_vertex
                                   FROM edges
                                            JOIN in_europe ON edges.head_vertex = in_europe.vertex_id
                                   WHERE edges.label = 'lives_in')
SELECT vertices.name
FROM vertices
         JOIN born_in_usa ON vertices.vertex_id = born_in_usa.vertex_id
         JOIN lives_in_europe ON vertices.vertex_id = lives_in_europe.vertex_id;