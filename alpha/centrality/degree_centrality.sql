-- Degree Centrality

DROP PROCEDURE degree_centrality;
CREATE PROCEDURE degree_centrality(IN entity VARCHAR, IN attribute VARCHAR, IN named_graph VARCHAR :='?g'){
    DECLARE q, graph VARCHAR;
    DECLARE meta, _dt any;
    DECLARE inx INTEGER; 
    IF(named_graph <> '?g'){
        named_graph := sprintf('<%s>',named_graph);
    };
    IF(regexp_match('(\\w+\:\\w+)','foaf:knows')){
        attribute := attribute;
    }
    ELSE{
        attribute := sprintf('<%s>',attribute);
    };
    q := sprintf('
                    SPARQL 
                    DEFINE output:valmode "LONG"  
                    SELECT 
                        COUNT(?p) 
                    WHERE 
                        { 
                            GRAPH %s 
                                    { 
                                        <%s> ?p ?o. 
                                        FILTER(?p = %s) 
                                    } 
                        }', named_graph, entity, attribute 
                );

    EXEC(q,null,null,null,0,meta,_dt);
    inx := 0;
    RETURN _dt[0][0];
};

SELECT degree_centrality('urn:a','foaf:knows');

SPARQL
SELECT
    ?s
    sql:degree_centrality(?s, 'foaf:knows') as ?degrees
FROM 
    <urn:analytics>
WHERE
    {
        ?s foaf:knows ?o.
    };

 