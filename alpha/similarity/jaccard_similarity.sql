-- Jaccard Similarity (J(A, B) = |A∩B| / |A∪B|)

DROP PROCEDURE jaccard_similarity_sp_long;
CREATE procedure jaccard_similarity_sp_long(IN source VARCHAR, IN property VARCHAR, IN target VARCHAR){

    -- Declare Variables

    -- a: Test Vector 1
    -- b: Test Vector 2
    -- n:  Values that exist in both vectors
    -- u1: Values that only exist in one vector

    DECLARE a, b, n, u1, q1, q2 ANY;
    DECLARE _inx int;
    DECLARE  ax, bx, jc any;

    -- Initialize _inx

    _inx := 0;

    -- Query Strings
    q1 := sprintf('SPARQL DEFINE output:valmode "LONG" SELECT DISTINCT ?o WHERE {<%s> %s ?o}', source, property);
    q2 := sprintf('SPARQL DEFINE output:valmode "LONG" SELECT DISTINCT ?o WHERE {<%s> %s ?o}', target, property);
    
    -- Get Source Data, and add to array a

    ax := DB.DBA.SPARQL_EVAL_TO_ARRAY (q1, null, null);

    VECTORBLD_INIT(a);

    WHILE(_inx < length(ax)){
        VECTORBLD_ACC(a,ax[_inx][0]);
        _inx := _inx + 1;
    };

    VECTORBLD_FINAL(a);

   --Reset Index

    _inx := 0;

    -- Get Target Data, and add to array b

    bx := DB.DBA.SPARQL_EVAL_TO_ARRAY (q2, null, null);

    VECTORBLD_INIT(b);

    WHILE(_inx < length(bx)){
        VECTORBLD_ACC(b,bx[_inx][0]);
        _inx := _inx + 1;
    };

    VECTORBLD_FINAL(b);

   --Reset Index

    _inx := 0;

-- Initialize New Vectors
        
    VECTORBLD_INIT(n);
    VECTORBLD_INIT(u1);

    -- Put matches in vector n

    WHILE(_inx < length(a)){
        IF(POSITION(a[_inx],b) > 0 ){
            VECTORBLD_ACC(n,a[_inx]);
        }

    -- Put unique values in vector u1

        else IF(POSITION(a[_inx],b) = 0 ){
            VECTORBLD_ACC(u1,a[_inx]);
        }

        _inx :=  _inx + 1;
    };
    
    -- Done with Vector n

    VECTORBLD_FINAL(n);

    -- Reset _inx

    _inx := 0;

    -- Put new unique values  from array B in u1

    WHILE(_inx < length(b)){
        IF(POSITION(b[_inx],a) = 0 ){

            IF(POSITION(b[_inx],n) = 0){
                VECTORBLD_ACC(u1,b[_inx]);
            }

        }

        _inx :=  _inx + 1;
    };
    
    -- Done with Vector u1

    VECTORBLD_FINAL(u1);

    -- Calculate Jaccard Similarity
    IF( length(n) > 0){
        jc := CAST(length(n) AS float) / (length(n) + length(u1));
    }
    ELSE IF(length(n) = 0){
        jc := CAST(0 AS float);
    };

    RETURN jc;
};

-- Test

SPARQL LOAD <http://dbpedia.org/resource/Eternals_(film)>;
SPARQL LOAD <http://dbpedia.org/resource/Salt_(2010_film)>;
SELECT jaccard_similarity_sp_long('http://dbpedia.org/resource/Eternals_(film)','<http://dbpedia.org/ontology/starring>', 'http://dbpedia.org/resource/Salt_(2010_film)');