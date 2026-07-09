### usage: gawk -f rdfize_hpa_tisspec.awk -v col=COL hpa_[tissue,cell]_[uberon,caloha].tsv proteinatlas.tsv

BEGIN {
    FS = "\t"
    if(!col) {
        print "ERROR: Specify column number.\n -v col=19 for tissues\n -v col=23 for cells" > "/dev/stderr"
        exit 1
    }
    print "@prefix ensembl: <http://identifiers.org/ensembl/> ."
    print "@prefix refexo: <http://purl.jp/bio/01/refexo#> ."
    # print "@prefix obo: <http://purl.obolibrary.org/obo/> ."
    print "@prefix caloha: <http://purl.obolibrary.org/obo/caloha.obo#> ."
    print ""
}

FNR==NR {
    tis2caloha[$1] = $3
    next
}

FNR>=2 {
    ### use $19 for tissues, $23 for cells
    split(gensub("\"", "", "g", $col), tissues, ";")
    print "ensembl:" $3 " a refexo:HPA_ts_evaluated_gene ."
    for(t in tissues) {
        split(tissues[t], tissue, ":")
        if(!(tissue[1] in tis2caloha)) {
            print "ERROR: No CALOHA mapping found for \"" tissue[1] "\" (line " FNR ")" > "/dev/stderr"
            exit 1
        }
        # print "ensembl:" $3 " refexo:isPositivelySpecificTo obo:" tis2uberon[tissue[1]] " ."
        print "ensembl:" $3 " refexo:isPositivelySpecificTo caloha:" tis2caloha[tissue[1]] " ."
    }
}

