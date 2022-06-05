DROP PROCEDURE shortest_path;
CREATE PROCEDURE shortest_path(IN source VARCHAR, IN predicate VARCHAR, IN target VARCHAR, IN named_graph VARCHAR := '?g'){
    DECLARE q VARCHAR;
    DECLARE meta, _dt ANY;
    DECLARE inx INTEGER;
    IF(named_graph <> '?g'){
        named_graph := SPRINTF('<%s>',named_graph);
    };
    IF(predicate <> '?p'){
        IF(REGEXP_MATCH('(\\w+\:\\w+)',predicate)){
        predicate := predicate;
        }
        ELSE{
            predicate := SPRINTF('<%s>',predicate);
        };
    };

    q := SPRINTF('SPARQL 
                  SELECT 
                    group_concat(?via,\',\') as ?shortest_path 
                  WHERE 
                  {
                       GRAPH %s 
                       { 
                           ?s %s ?o OPTION(TRANSITIVE, 
                           T_IN(?s), 
                           T_OUT(?o), 
                           t_direction 3, 
                           t_distinct, 
                           t_shortest_only, 
                           t_step (?s) as ?via, 
                           t_step (\'path_id\') as ?path ). 
                           
                           FILTER (?s = <%s> && ?o = <%s>)
                       }
                  }', named_graph, predicate, source, target);
    DBG_PRINTF('Query: %s',q);
    EXEC(q,null,null,null,0,meta,_dt);
    RETURN _dt[0][0];   
};