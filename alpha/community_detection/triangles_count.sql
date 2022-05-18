-- Triangles
-- Sum of triangles per entity

DROP PROCEDURE triangle_count;

CREATE PROCEDURE triangle_count(IN entity VARCHAR, IN attribute VARCHAR, IN named_graph VARCHAR := '?g'){
    DECLARE q VARCHAR;
    DECLARE meta, _dt ANY;
    DECLARE inx INTEGER;
    IF(named_graph <> '?g'){
        named_graph := sprintf('<%s>',named_graph);
    };
    IF(regexp_match('(\\w+\:\\w+)',attribute)){
        attribute := attribute;
    }
    ELSE{
        attribute := sprintf('<%s>',attribute);
    };
    
    q := sprintf('SPARQL DEFINE output:valmode "LONG" SELECT COUNT(?entity4) WHERE { GRAPH %s {<%s> %s/%s/%s ?entity4. FILTER(?entity4 = <%s>)} }', named_graph, entity, attribute, attribute, attribute, entity);

    EXEC(q,null,null,null,0,meta,_dt);
    inx := 0;
    RETURN _dt[0][0];
};

SPARQL 
SELECT
    ?person
    sql:triangle_count(?person, 'foaf:knows') as ?triangle_count
FROM <urn:analytics>
WHERE{
    ?person foaf:knows ?knowee. 
} ;