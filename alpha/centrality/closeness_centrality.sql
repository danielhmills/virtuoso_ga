DROP PROCEDURE closeness_centrality;
CREATE PROCEDURE closeness_centrality(IN source VARCHAR, IN predicate VARCHAR, IN target VARCHAR := '?dest', IN min_steps INTEGER := 1, IN max_steps INTEGER := 0, IN named_graph VARCHAR := '?g'){
    DECLARE q, graph VARCHAR;
    DECLARE meta, _dt any;
    DECLARE inx INTEGER; 
    IF(named_graph <> '?g'){
        named_graph := sprintf('<%s>',named_graph);
    };
    IF(regexp_match('(\\w+\:\\w+)',predicate)){
        predicate := predicate;
    }
    ELSE{
        predicate := sprintf('<%s>',predicate);
    };

    IF(max_steps > 0){
        max_steps := sprintf('T_MAX ( %s ) ,',max_steps);
    }
    ELSE{
        max_steps := '';
    };
    q := sprintf(
        '
            SPARQL
            SELECT
            ?s 
            1/AVG(?dist_to_via) as ?centrality
            WHERE
            {
              GRAPH %s  
                {
                    ?s %s %s
                        OPTION (
                                TRANSITIVE , 
                                T_DISTINCT ,
                                T_IN ( ?s ) , 
                                T_OUT ( %s ) ,
                                T_MIN ( %s ) , 
                                %s 
                                T_STEP ( \'step_no\' ) AS ?dist_to_via
                                )
                        FILTER( ?s = <%s> )
                }
            }
        ', named_graph, predicate, target, target, min_steps, max_steps, source); 
        EXEC(q,null,null,null,0,meta,_dt);
        RETURN _dt[0][1];
};

SPARQL
SELECT DISTINCT
    ?s
sql:closeness_centrality(?s,'foaf:knows','?dest',1,0,'urn:analytics') as ?centrality
FROM <urn:analytics>
WHERE
    {
        ?s foaf:knows ?o.
    }
ORDER BY DESC(?centrality);