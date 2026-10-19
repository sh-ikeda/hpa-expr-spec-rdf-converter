BEGIN {
    FS = "\t"
    print "@prefix hpao: <http://med2rdf.org/hpa/ontology#> ."
    print "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
    print "@prefix skos: <http://www.w3.org/2004/02/skos/core#> ."
    print "@prefix owl: <http://www.w3.org/2002/07/owl#> ."
    print "@prefix obo: <http://purl.obolibrary.org/obo/> ."
    print "@prefix caloha: <http://purl.obolibrary.org/obo/caloha.obo#> ."
    print "@prefix dcterms: <http://purl.org/dc/terms/> ."
    print ""
}

## ID, label, and xref
{
    label2id[$2] = $1
    print "hpao:" $1 " a owl:Class ;"
    print "    dcterms:identifier \"" $1 "\" ;"
    if ($3 ~ /^((CL)|(UBERON))/)
        print "    skos:closeMatch obo:" gensub(":", "_", "g", $3) " ;"
    else if ($3 ~ /^TS/)
        print "    skos:closeMatch caloha:" gensub(":", "_", "g", $3) " ;"
    print "    rdfs:label \"" $2 "\" ."
    print ""
    next
}
